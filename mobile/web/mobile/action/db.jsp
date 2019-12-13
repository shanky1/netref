<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.mysql.jdbc.jdbc2.optional.MysqlDataSource" %>

<%!
    static MysqlDataSource ds;
    static final String DB_SERVER = "localhost";
    static final int DB_SERVER_PORT = 3306;
    static final String DB_NAME = "netref";
    static final String DB_USER = "root";
    static final String DB_PASSWORD = "wg123";

    static long connectionExpirationTime = 60*1000*5;//will consume memory if kept for long time
//    int poolSize = 500;
    static int poolSize = 20;

    static boolean INITIALIZED = false;
    static Object LOCK = new Object();

    public static Connection getConnection() throws Exception {
        try {
            if(!INITIALIZED) {
                synchronized(LOCK) {
                    INITIALIZED = true;
                    initDBPool(connectionExpirationTime, poolSize);
                }
            }
            return borrowConnection();
        } catch(Exception sqle) {
            System.out.println ("Conn[DBConnection.getConnection]:"+ sqle.toString());
            throw sqle;
        }
    }

    public static void closeConnection(Connection connection){
        if (connection != null){
            returnConnection(connection);
        }
    }

    //IT CAN'T GO ABOVE 99
    //don't use up all the connections for the pool. we have the function that takes connections outside of the pool.
    private static int MAX_CONN = 30;
    private static int MAX_CONN_WAIT = 2000;//in millis

    private static void initDBPool(long expTime,int poolSize) {
        initPool(expTime, poolSize);
        ds = new MysqlDataSource();
        ds.setServerName(DB_SERVER);
        ds.setPort(DB_SERVER_PORT);
        ds.setDatabaseName(DB_NAME);
        ds.setUser(DB_USER);
        ds.setPassword(DB_PASSWORD);
        //Thread cleaner = new PoolCleanupThread(this);
        //cleaner.setDaemon(true);
        //cleaner.start();
    }

    static Object create() throws SQLException {
        try {
            Object obj = ds.getConnection();
            Long now = new Long( System.currentTimeMillis() );
            activeConnectionMap_lastTimeUsed.put(obj, now);
//System.out.println("SIZE OF UNLOCKED: "+unlocked.size()+"; SIZE OF LOCKED: "+locked.size() +"; MAX="+MAX_CONN);
            return obj;
        } catch(SQLException se) {
            System.out.println("ERROR -- SIZE OF UNLOCKED: "+unlocked.size()+"; SIZE OF LOCKED: "+locked.size() );
            se.printStackTrace();
            throw se;
        }
    }

    static boolean validate(Object o) {
        Connection conn = (Connection)o;
        try {
            if (conn.isClosed())
                return false;

            Long lasttime = (Long) activeConnectionMap_lastTimeUsed.get(conn);
            Long now = new Long( System.currentTimeMillis() );
            if (lasttime == null ||
//                    (now.longValue() - lasttime.longValue()) > 1000 * 3600) { // 1 hr (could be upto 8 hrs)
                    (now.longValue() - lasttime.longValue()) > 1000 * 10) { // it should be only 10 secs
//System.out.println("DBConnectionPool: testing connection since: " + now + "," + lasttime);
                Statement stmt = conn.createStatement();
                stmt.executeQuery("Select 1");
                stmt.close();
                activeConnectionMap_lastTimeUsed.remove(conn);
                activeConnectionMap_lastTimeUsed.put(conn, now);
            }
            return true;
        } catch (Throwable e) {
//            e.printStackTrace();
            System.out.println("DBConnectionPool: Possible stale connection");
            return false;
        }
    }

    static void expire(Object o) {
        Connection conn = (Connection)o;
        try {
            conn.close();
            activeConnectionMap_lastTimeUsed.remove(conn);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    static Hashtable wait_map = new Hashtable();
    public static synchronized Connection borrowConnection() throws Exception {
        try {
            if( threadsUsingConnection.contains(Thread.currentThread()) ) {
                throw (new SQLException(new java.util.Date()+"\t Thread already has an open connection. Please re-use the connection. Rewrite code."));
            }

            while( locked.size() >= MAX_CONN && unlocked.size()==0) { //the '>' should never happen but just incase
//                System.out.println("locked.size()>=MAX_CONN && unlocked.size()==0: is true waiting ...  "+Thread.currentThread());
                wait_map.put(Thread.currentThread(),new Long(System.currentTimeMillis()));
                //TODO Thread.this.wait(/*MAX_CONN_WAIT*/);
            }
            Connection conn = (Connection)checkOut();
//            System.out.println("SIZE OF UNLOCKED: "+unlocked.size()+"; SIZE OF LOCKED: "+locked.size() );
            threadsUsingConnection.add(Thread.currentThread());
            if( wait_map.contains(Thread.currentThread()) ) {
                Long start = (Long)wait_map.remove(Thread.currentThread());
                long now = System.currentTimeMillis();
                System.out.println(Thread.currentThread()+" waited for "+(now-start.longValue()));
            }
            return conn;
        } catch (Exception e) {
            e.printStackTrace();
            throw (Exception)e;
        }
    }

    public static synchronized void returnConnection(Connection conn){
        try {
            checkIn(conn);
            threadsUsingConnection.remove(Thread.currentThread());
            //TODO Thread.this.notify();
        } catch(Throwable t){
            t.printStackTrace();
            //logException("Error occurred while returning DB connection",t,true);
        }
    }
    static Vector threadsUsingConnection = new Vector();


    public static Connection getConnectionFromOutsideThePool() throws SQLException {
        return ds.getConnection();
    }

    public static void closeConnectionFromOutsideThePool(Connection conn) throws SQLException {
        conn.close();
    }

    private static final Hashtable activeConnectionMap_lastTimeUsed = new Hashtable();

    private static final Hashtable idleConnectionMap = new Hashtable();

    private static long expirationTime;
    protected static Hashtable locked, unlocked;

    protected static void initPool(long expTime, int poolSize){//TODO size of pool
        expirationTime = expTime;
        locked = new Hashtable();
        unlocked = new Hashtable();
    }

    static synchronized Object checkOut() throws Exception {
        long currTime = System.currentTimeMillis();
        Object next;
        if(unlocked.size()>0) {
            Enumeration unlockedObjects = unlocked.keys();
            while(unlockedObjects.hasMoreElements()){
                next = unlockedObjects.nextElement();
                if(validate(next)){
                    unlocked.remove(next);
                    locked.put(next, new Long(currTime));
                    return next;
                } else{
                    unlocked.remove(next);
                    expire(next);
                    next = null;
                }
            }
        }
        next = create();
        locked.put(next,new Long(currTime));
        return next;
    }

    static synchronized void checkIn(Object o) {
        locked.remove(o);
        unlocked.put(o,new Long(System.currentTimeMillis()));
    }

    static synchronized void cleanUp(){
        long currTime = System.currentTimeMillis();
        Object next;
        if(unlocked.size()>0){      //what abt locked objects
            Enumeration e = unlocked.keys();
            while(e.hasMoreElements()){
                next = e.nextElement();
                if(currTime - ((Long)unlocked.get(next)).longValue()>expirationTime || !validate(next)){
                    unlocked.remove(next);
                    expire(next);
                    next = null;
                }
            }
        }
    }

    private static Hashtable stmCache = new Hashtable();

    //no need to synchronize since HT is synchronized
    private static PreparedStatement getPsForConnection(Connection conn, String ps_string) throws SQLException {
        if(conn==null || ps_string==null) return null;
        Hashtable map = (Hashtable)stmCache.get(conn);
        if(map==null) return null;
        PreparedStatement ps = (PreparedStatement)map.get(ps_string);
        if(ps!=null) ps.clearParameters();
        return ps;
    }

    /**
     * Is ps is not in the cache then create it and put it and return the same.
     * No need to check for conn=null and ps_string==null because getPSConnection and putPsForConnection are checking them
     * @author Prabhat
     * @param conn
     * @param ps_string
     * @return
     * @throws SQLException
     */
    public static PreparedStatement getPs(Connection conn, String ps_string) throws SQLException {
        PreparedStatement ps = getPsForConnection(conn, ps_string);
        if(ps==null) {
            putPsForConnection(conn, ps_string, conn.prepareStatement(ps_string));
            ps=getPsForConnection(conn, ps_string);
        }
        return ps;
    }

    public static synchronized void putPsForConnection(Connection conn, String ps_string, PreparedStatement ps){
        if(conn==null ) throw new IllegalArgumentException("Connection is null.");
        if(ps_string==null||ps_string.trim().length()==0)  throw new IllegalArgumentException("ps_string is null or of 0 size."+ps_string);
        Hashtable map = (Hashtable)stmCache.get(conn);

        if(map==null) {
            map = new Hashtable();
        }
        map.put(ps_string,ps);

        stmCache.put(conn, map);
    }
%>

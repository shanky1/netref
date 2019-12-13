<%@ page import="java.io.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>

<%!
    public static boolean LOG = true;
    public static boolean HAS_LOG = false;
    public static boolean HAS_EXCEPTIONS = false;
    public static boolean HAS_MISC_LOG = false;

    //	public static boolean flag = Constants.CREATE_LOG;
    private static StringBuffer logBuffer = new StringBuffer();
    private static StringBuffer exceptionsBuffer = new StringBuffer();
    private static StringBuffer miscLogBuffer = new StringBuffer();

    private static String line_sep = System.getProperty("line.separator");
    public static String[] mail_to = {};
    public static String[] mail_cc = {};
    public static String mail_hostName = "";
    public static String mail_from = "";

    public synchronized static void pr(String str) {
        logBuffer.append(new java.util.Date());
        logBuffer.append("     ");
        logBuffer.append(str);
        logBuffer.append(line_sep);
        HAS_LOG = true;
    }

    public synchronized static void pr(String str1, String str2) {
        logBuffer.append(new java.util.Date());
        logBuffer.append("  ");
        logBuffer.append(str1);
        logBuffer.append("  ");
        logBuffer.append(str2);
        logBuffer.append(line_sep);
        HAS_LOG = true;
    }

    public synchronized static void logException( Throwable ex ) {
        logException("", ex, false);
    }

    public synchronized static void logException( String message, Throwable ex ) {
        logException(message, ex, false);
    }

    public synchronized static void logException(String message, Throwable ex, boolean emailClient) {
        String str = "//************************  EXCEPTION  *************************//" + line_sep;
        exceptionsBuffer.append(str);
        exceptionsBuffer.append(new java.util.Date());
        exceptionsBuffer.append("  ");
        exceptionsBuffer.append(message + line_sep);

        StringWriter sw = new StringWriter();

        if(ex!=null) {
            ex.printStackTrace(new PrintWriter(sw));
            str = sw.toString();
            exceptionsBuffer.append(str);
            pr(message, str);
        }

        str = line_sep + "//************************  END EXCEPTION  *************************//" + line_sep;
        exceptionsBuffer.append(str);
        exceptionsBuffer.append(line_sep);
        HAS_EXCEPTIONS = true;

/*
        if (emailClient) {
            sendMail(message,sw.toString());
        }
*/
        try { sw.close(); } catch (IOException e) { e.printStackTrace();  }
    }

    static Queue to_be_mailed_queue = new ArrayDeque();
    static MailerThread mailer_thread = null;
    public synchronized static void sendMail(final String message, final String content) {
        if(mailer_thread==null || !mailer_thread.isAlive()) {
            mailer_thread=new MailerThread();
            mailer_thread.start();
        }
        String[] m_c = {message,content};
        synchronized(to_be_mailed_queue) {
            to_be_mailed_queue.add(m_c);
            to_be_mailed_queue.notifyAll();
        }

    }

    public synchronized static void logException( String message) {
        logException(message, null, false);
    }

    public synchronized static void logMisc( String message) {
        miscLogBuffer.append(new java.util.Date());
        miscLogBuffer.append("  ");
        miscLogBuffer.append(message);
        miscLogBuffer.append(line_sep);
        HAS_MISC_LOG = true;
    }

    public synchronized static String getLog() {
        String s = logBuffer.toString();
        logBuffer.setLength(0);
        HAS_LOG = false;
        return s;
    }

    public synchronized static String getMiscLog() {
        String s = miscLogBuffer.toString();
        miscLogBuffer.setLength(0);
        HAS_MISC_LOG = false;
        return s;
    }

    public synchronized static String getExceptions() {
        String s = exceptionsBuffer.toString();
        exceptionsBuffer.setLength(0);
        HAS_EXCEPTIONS = false;
        return s;
    }

    static class MailerThread extends Thread {
        public MailerThread (){
            super("MailerThread");
        }
        public void run() {
            while(true) {
                try {
                    String[] message_and_content = null;
                    synchronized(to_be_mailed_queue) {
                        if(to_be_mailed_queue.isEmpty()){
                            try { to_be_mailed_queue.wait(); } catch (InterruptedException e) { e.printStackTrace(); }
                        }
                        message_and_content = (String[])to_be_mailed_queue.poll();
                        if(message_and_content==null || message_and_content.length==0) continue;
                    }
                    String message = message_and_content[0];
                    String content = message_and_content[1];
//                    MailClient mclient = new MailClient();
                    //todo why this complicated check?
                    if (mail_cc==null || mail_cc.length==0 || mail_cc[0]==null || mail_cc[0].equals("")) mail_cc = (String[]) null;
                    if (mail_to!=null && mail_to.length!=0 && mail_to[0]!=null && !mail_to[0].equals("") &&
                            mail_hostName!=null && !mail_hostName.equals("") &&
                            mail_from!=null && !mail_from.equals("")) {
                        //Doing this to pause if there are too many alerts to be sent.
                        Thread.sleep(2000);
                    }
                } catch(Throwable t) {
                    System.out.println("Exception in Sending mail to"+t.getMessage());
//                    t.printStackTrace();
                }
            }
        }
    }

    //TODO LogWriter was a Thread subclass - Need to create a LogWriter Thread

    static class LogWriter extends Thread {
        private BufferedWriter logFile_Writer = null;
        private BufferedWriter exceptions_LogFile_Writer = null;
        private BufferedWriter misc_LogFile_Writer = null;

        private File exceptionsFile = null;
        private File logFile = null;
        private File miscLogFile = null;

        private String currentLogDir = null;

        private String hr="", prev_hr="";

        private static final long MAX_LOG_FILE_SIZE = 5*1000*1000;//5MB

        private static final long LOG_SLEEP = 5*1000;//5MB
        private static String LOG_DIR = "D:/coref/logs";
        private static String LOG_FILE = "log";

        public void run() {
            hr = "";
            prev_hr = hr;

            while(true) {
                hr = sdf_date_hr.format(new java.util.Date());
                try {
                    if(!hr.equals(prev_hr) ) {
                        flushAndCloseWriters();
                        resetCurrentLogDirAndFile();
                    }
                } catch(Throwable t) {t.printStackTrace();}

                try {
                    writeToLogFiles();
                } catch(Throwable t) {t.printStackTrace();}

                prev_hr = hr;
                try { Thread.sleep(LOG_SLEEP*1000); } catch(Throwable t){}
            }
        }

        private boolean renameToRetry(File orig_file, File bak_file) {
            for (int i=0; i<3; i++) {
                if (orig_file.renameTo(bak_file)){
                    return true;
                }
                System.gc();
                try { Thread.sleep(50); } catch (InterruptedException t) {}
            }
            return orig_file.renameTo(bak_file);
        }

        private void writeToLogFiles() {
            if(HAS_LOG) {
                String log = getLog();
                writeLog(log);
            }

            if(HAS_EXCEPTIONS) {
                String log = getExceptions();
                writeExceptions(log);
            }

            if(HAS_MISC_LOG) {
                String log = getMiscLog();
                writeMiscLog(log);
            }
        }

        private void rolloverLogFile() throws IOException {
            java.util.Date dt = new java.util.Date();
            currentLogDir = LOG_DIR+"/"+sdf_date.format(dt)+"/";
            File dir = new File(currentLogDir);
            if(!dir.exists()) {
                dir.mkdirs();
            }
            String lf = currentLogDir+"/"+sdf_hr.format(dt)+"_"+LOG_FILE;

            logFile_Writer.flush();
            logFile_Writer.close();
            File bak_file = new File(lf+"."+sdf_hr_min.format(dt));
            boolean success = renameToRetry(logFile, bak_file);
            logFile = new File(lf);
            FileOutputStream fos = new FileOutputStream(logFile, !success);
            logFile_Writer = new BufferedWriter(new OutputStreamWriter(fos) );

            PrintStream ps = null;
            ps = new PrintStream(fos);
            System.setOut(ps);
            System.out.println("log FILE backed up as: " + bak_file.getAbsolutePath() );
        }

        private void rolloverExceptionsFile() throws IOException {
            java.util.Date dt = new java.util.Date();
            currentLogDir = LOG_DIR+"/"+sdf_date.format(dt)+"/";
            File dir = new File(currentLogDir);
            if(!dir.exists()) {
                dir.mkdirs();
            }
            String lf = currentLogDir+"/"+sdf_hr.format(dt)+"_"+EXCEPTION_FILE_PREFIX+LOG_FILE;

            exceptions_LogFile_Writer.flush();
            exceptions_LogFile_Writer.close();
            File bak_file = new File(lf+"."+sdf_hr_min.format(dt));
            boolean success = renameToRetry(exceptionsFile, bak_file);
            exceptionsFile = new File(lf);
            FileOutputStream fos = new FileOutputStream(exceptionsFile, !success);
            exceptions_LogFile_Writer = new BufferedWriter(new OutputStreamWriter(fos) );

            PrintStream ps = new PrintStream(fos);
            System.setErr(ps);

            System.err.println("exceptions FILE backed up as: " + bak_file.getAbsolutePath());
        }

        private void rolloverMiscLogFile() throws IOException {
            java.util.Date dt = new java.util.Date();
            currentLogDir = LOG_DIR+"/"+sdf_date.format(dt)+"/";
            File dir = new File(currentLogDir);
            if(!dir.exists()) {
                dir.mkdirs();
            }
            String lf = currentLogDir+"/"+sdf_hr.format(dt)+"_"+MISC_LOG_FILE_PREFIX+LOG_FILE;

            misc_LogFile_Writer.flush();
            misc_LogFile_Writer.close();
            File bak_file = new File(lf+"."+sdf_hr_min.format(dt));
            boolean success = renameToRetry(miscLogFile, bak_file);
            miscLogFile = new File(lf);
            FileOutputStream fos = new FileOutputStream(miscLogFile, !success);
            misc_LogFile_Writer= new BufferedWriter(new OutputStreamWriter(fos) );

            System.out.println("Misc FILE backed up as: " + bak_file.getAbsolutePath());
        }

        private void flushAndCloseWriters() throws IOException {
            if(logFile_Writer!=null) {
                logFile_Writer.flush();
                logFile_Writer.close();
            }
            if(exceptions_LogFile_Writer!=null) {
                exceptions_LogFile_Writer.flush();
                exceptions_LogFile_Writer.close();
            }
            if(misc_LogFile_Writer!=null) {
                misc_LogFile_Writer.flush();
                misc_LogFile_Writer.close();
            }
        }

        private void resetCurrentLogDirAndFile() throws IOException{
            java.util.Date dt = new java.util.Date();
            currentLogDir = LOG_DIR+"/"+sdf_date.format(dt)+"/";
            File dir = new File(currentLogDir);
            if(!dir.exists()) {
                dir.mkdirs();
            }

            String logfile_name = currentLogDir+"/"+sdf_hr.format(dt)+"_"+LOG_FILE;
            logFile = new File(logfile_name);
            FileOutputStream fos = new FileOutputStream(logFile,true);
            logFile_Writer = new BufferedWriter(new OutputStreamWriter(fos) );
            PrintStream ps = new PrintStream(fos);
            System.setOut(ps);

            logfile_name = currentLogDir+"/"+sdf_hr.format(dt)+"_"+EXCEPTION_FILE_PREFIX+LOG_FILE;
            exceptionsFile= new File(logfile_name);
            fos = new FileOutputStream(exceptionsFile,true);
            exceptions_LogFile_Writer = new BufferedWriter(new OutputStreamWriter(fos) );
            ps = new PrintStream(fos);
            System.setErr(ps);

            logfile_name = currentLogDir+"/"+sdf_hr.format(dt)+"_"+MISC_LOG_FILE_PREFIX+LOG_FILE;
            miscLogFile= new File(logfile_name);
            fos = new FileOutputStream(miscLogFile,true);
            misc_LogFile_Writer = new BufferedWriter(new OutputStreamWriter(fos) );
        }

        private void writeLog(String log) {
            try {
                logFile_Writer.write(log,0,log.length());
                logFile_Writer.flush();
                if(logFile.length() >= MAX_LOG_FILE_SIZE){
                    rolloverLogFile();
                }
            } catch( Throwable t){t.printStackTrace();}
        }

        private void writeExceptions(String log) {
            try {
                exceptions_LogFile_Writer.write(log,0,log.length());
                exceptions_LogFile_Writer.flush();
                if(exceptionsFile.length() >= MAX_LOG_FILE_SIZE){
                    rolloverExceptionsFile();
                }
            } catch( Throwable t){t.printStackTrace();}
        }

        private void writeMiscLog(String log) {
            try {
                misc_LogFile_Writer.write(log,0,log.length());
                misc_LogFile_Writer.flush();
                if(miscLogFile.length() >= MAX_LOG_FILE_SIZE){
                    rolloverMiscLogFile();
                }
            } catch( Throwable t){t.printStackTrace();}
        }

        //**************  STATIC ****************//

        static SimpleDateFormat sdf = new SimpleDateFormat("MM_dd_yyyy_hh_mm_sss");
        static SimpleDateFormat sdf_hr_min = new SimpleDateFormat("hh_mm");
        static SimpleDateFormat sdf_date = new SimpleDateFormat("MM_dd_yyyy");
        static SimpleDateFormat sdf_date_hr = new SimpleDateFormat("MM_dd_yyyy_hh aaa");
        static SimpleDateFormat sdf_hr = new SimpleDateFormat("aaa");//new SimpleDateFormat("hh aaa");

        private static final String EXCEPTION_FILE_PREFIX="err_";
        private static final String MISC_LOG_FILE_PREFIX="misc_";
    }

    static LogWriter SINGLETON = null;

    static {
        //TODO initiate the LogWriter Thread

        SINGLETON = new LogWriter();
        if(LOG) {
            SINGLETON.start();
        }
    }
%>

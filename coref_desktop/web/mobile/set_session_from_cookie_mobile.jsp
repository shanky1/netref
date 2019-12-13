<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="action/util.jsp" %>

<%
//    System.out.println("Request handler 'set_session_from_cookie_mobile' was called");
    String mobile_value = request.getParameter("coref_cookie_login_mobile_value");

    org.json.JSONArray user_details_json = new org.json.JSONArray();

//    int userId = getUserIdForLogin_Mobile(mobile_value);
    ArrayList<HashMap<String, Integer>> user_details_al = getUserDetailsForLogin_Mobile(mobile_value);

    int userId = -1;

    if(user_details_al == null) {
        out.print("failed");
        return;
    }

    Iterator<HashMap<String, Integer>> iterator = user_details_al.iterator();
    if (iterator.hasNext()) {
        HashMap<String, Integer> hm = iterator.next();

        if(hm != null && hm.containsKey("user_id")) {
            userId = hm.get("user_id");
        }
    }

    if(userId > 0) {
        session.setAttribute("user_id", userId+"");
        session.setAttribute("login_type", "mobile_login");

        //Convert contacts list from database to the json format and return
        user_details_json = new org.json.JSONArray(user_details_al);

        out.print(user_details_json);
    } else {
        out.print("failed");
    }
%>

<%!
    final static String sql_getUserId_ForMobile = "SELECT user_id FROM users WHERE mobile = ?";

    private long getUserIdForLogin_Mobile(String mobile_value) {

        Connection conn =  null;
        long user_id = -1;

        try {
            conn = getConnection();

            byte[] enc_mobile = processEncrypt(mobile_value);

            PreparedStatement selectUser = getPs(conn, sql_getUserId_ForMobile);
            selectUser.setBytes(1, enc_mobile);

            ResultSet rs = selectUser.executeQuery();
            if (rs.next()) {
                user_id = rs.getLong(1);
            }
        } catch(Throwable t) {
            t.printStackTrace();
        } finally{
            closeConnection(conn);
        }

        return user_id;
    }

    final static String sql_getUserDetails_ForMobile = "SELECT user_id, user_type FROM users WHERE mobile = ?";

    public ArrayList<HashMap<String, Integer>> getUserDetailsForLogin_Mobile(String mobilenum) {
        Connection con = null;
        PreparedStatement getUD = null;
        ResultSet rs = null;

        int userId = -1;
        int userType = 1;

        ArrayList ar = new ArrayList();

        try {
            con = getConnection();

            byte[] mobile_bytes = processEncrypt(mobilenum);

            getUD = getPs(con, sql_getUserDetails_ForMobile);
            getUD.setBytes(1, mobile_bytes);

            rs = getUD.executeQuery();

            if (rs.next()) {
                HashMap hm = new HashMap();
                userId = rs.getInt("user_id");
                userType = rs.getInt("user_type");
                hm.put("user_id", userId);
                hm.put("user_type", userType);
                ar.add(hm);
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            closeConnection(con);
        }
        return ar;
    }
%>

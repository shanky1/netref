<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="action/util.jsp" %>

<%
//    System.out.println("Request handler 'set_session_from_cookie' was called");

    String mobile_deviceid = request.getParameter("coref_cookie_skip_mobile_id");

    long user_id = getUserIdForSkip_Mobile(mobile_deviceid);

    if(user_id > -1) {
        session.setAttribute("user_id",user_id+"");
        session.setAttribute("login_type","mobile_login");
        out.print(user_id);
    } else {
        out.print("falied");
    }
%>

<%!
    final static String sql_getUserId_ForMobileDevice = "SELECT user_id FROM users WHERE device_id = ?";

    private long getUserIdForSkip_Mobile(String mobile_deviceid) {

        Connection conn =  null;
        long user_id = -1;

        try {
            conn = getConnection();

            PreparedStatement selectUser = getPs(conn, sql_getUserId_ForMobileDevice);
            selectUser.setString(1, mobile_deviceid);

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
%>

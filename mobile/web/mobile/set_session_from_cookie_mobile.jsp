<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="action/util.jsp" %>

<%
//    System.out.println("Request handler 'set_session_from_cookie' was called");

    String mobile_value = request.getParameter("netref_cookie_login_mobile_value");

    long user_id = getUserIdForLogin_Mobile(mobile_value);

    if(user_id > -1) {
        session.setAttribute("user_id",user_id+"");
        session.setAttribute("login_type","mobile_login");
        out.print(user_id);
    } else {
        out.print("falied");
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
%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="action/util.jsp" %>

<%
//    System.out.println("Request handler 'set_session_from_cookie' was called");

    String emailid = request.getParameter("netref_cookie_login_value");

    long user_id = getUserIdForLogin(emailid);

    if(user_id > -1) {
        session.setAttribute("user_id",user_id+"");
        session.setAttribute("login_type","fb_login");
        out.print("success");
    } else {
        out.print("falied");
    }
%>

<%!
    final static String sql_getUserId_ForEmail = "SELECT user_id FROM users WHERE email = ?";

    private long getUserIdForLogin(String email) {
        Connection conn =  null;
        long user_id = -1;

        try {
            conn = getConnection();

            byte[] email_enc = processEncrypt(email);

            PreparedStatement selectUser = getPs(conn, sql_getUserId_ForEmail);
            selectUser.setBytes(1, email_enc);

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

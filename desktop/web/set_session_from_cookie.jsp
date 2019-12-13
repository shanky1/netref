<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
//    System.out.println("Request handler 'set_session_from_cookie' was called");

    String emailid = request.getParameter("netref_cookie_login_value");

    long user_id = getUserIdForLogin(emailid);

    if(user_id > -1) {
        session.setAttribute("user_id",user_id+"");
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
            PreparedStatement selectUser=conn.prepareStatement(sql_getUserId_ForEmail);
            selectUser.setString(1, email);

            ResultSet rs = selectUser.executeQuery();
            if (rs.next()) {
                user_id = rs.getLong(1);
            }

            rs.close();
            selectUser.close();

        } catch(Throwable t) {
            t.printStackTrace();
        } finally{
            closeConnection(conn);
        }

        return user_id;
    }
%>

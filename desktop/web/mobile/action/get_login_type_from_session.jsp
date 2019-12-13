<%@ page import="java.util.Date" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    System.out.println(new Date()+"\t Request handler 'get_login_type_from_session' was called");

    String login_type = (String)session.getAttribute("login_type");

    String user_id = (String)session.getAttribute("user_id");

    String status = "no_login_type_session";

    if(user_id == null) {
        status = "session_expired";
    } else if(login_type != null) {
        status = login_type;
    } else {
        status= "no_login_type_session";
    }

    out.print(status);
%>

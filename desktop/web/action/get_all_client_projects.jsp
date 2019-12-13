<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="../util.jsp" %>

<%
    String client_id = (String)session.getAttribute("user_id");

    String message = getAllprojectsforclient(client_id);

//    System.out.println("tasks: "+message);

    if (message != null) {
        out.print(message);
    } else {
        out.print(message);
    }
%>

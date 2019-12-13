<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="../util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");
   // String message = getAllActiveFls(user_id);

//    System.out.println("message: "+message);

    if (message != null) {
        out.print(message);
    } else {
        out.print(message);
    }
%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="../util.jsp" %>

<%
    String message = getAllDevelopersshare();

//    System.out.println("message: "+message);

    if (message != null) {
        out.print(message);
    } else {
        out.print(message);
    }
%>

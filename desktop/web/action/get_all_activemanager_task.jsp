<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="../util.jsp" %>

<%
    String manager_id = request.getParameter("manager_id");

    String message = getAllTasksForManager(manager_id);

//    System.out.println("tasks: "+message);

    if (message != null) {
        out.print(message);
    } else {
        out.print(message);
    }
%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="../util.jsp" %>

<%
    String developer_id = request.getParameter("developer_id");

    String message = getAllTasksForDeveloper(developer_id);

//    System.out.println("tasks: "+message);

    if (message != null) {
        out.print(message);
    } else {
        out.print(message);
    }
%>

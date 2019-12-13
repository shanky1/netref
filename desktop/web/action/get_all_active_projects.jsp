<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="../util.jsp" %>

<%
    String fl_userid = request.getParameter("fl_userid");

//    System.out.println("developer_id in get all active projects: "+developer_id);

    String message = getAllTasksForDevelopers(fl_userid);

    /*System.out.println("message: "+message);*/

    if (message != null) {
        out.print(message);
    } else {
        out.print(message);
    }
%>

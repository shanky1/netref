<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>


<%
    String professional_id = request.getParameter("professional_id");
    String from_user_id = request.getParameter("from_user_id");

    String status = "failed";

    if(from_user_id == null) {
        status = "session_expired";
    } else {
        status = addNotifications(professional_id, from_user_id);
    }

    out.print(status);
%>

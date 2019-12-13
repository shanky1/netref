<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%

    String user_id = (String)session.getAttribute("user_id");

    String activity_id = request.getParameter("activity_id");

    String status = "failed";

    if(user_id == null) {
        status = "session_expired";
    } else {
        status = deletePost(user_id, activity_id);
    }

    out.print(status);
%>

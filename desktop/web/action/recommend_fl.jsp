<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="../util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String user_id = (String)session.getAttribute("user_id");

    String activity_id = request.getParameter("activity_id");
    String fl_userid = request.getParameter("fl_userid");
    String recommend = request.getParameter("recommend");

    String status = "failed";

    if(user_id == null) {
        status = "session_expired";
    } else {
        status = recommendFL(user_id, fl_userid, activity_id, recommend);
    }

    out.print(status);
%>

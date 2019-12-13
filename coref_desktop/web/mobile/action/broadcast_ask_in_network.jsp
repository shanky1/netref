<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String user_id = (String)session.getAttribute("user_id");

    String activity_id = request.getParameter("activity_id");
    String owner_id = request.getParameter("owner_id");

    String status = "failed";

    if(user_id == null) {
        status = "session_expired";
    } else {
        status = broadcastAskInNetwork(user_id, activity_id, owner_id);
    }

    out.print(status);
%>

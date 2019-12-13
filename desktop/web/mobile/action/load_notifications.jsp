<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>
<%
   String to_user_id = (String)session.getAttribute("user_id");

    String msg = "";

    if(to_user_id == null) {
        msg = "session_expired";
        out.print(msg);
    } else {
/*
        msg = loadFreelancers(from_user_id);
        out.print(msg);
*/
        ArrayList notifications_list_al = notifications_AL(to_user_id);

        org.json.JSONArray notification_list_json = new org.json.JSONArray(notifications_list_al);

        out.print(notification_list_json);
    }
%>

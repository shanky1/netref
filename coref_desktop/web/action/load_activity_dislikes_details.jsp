<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String from_user_id = (String)session.getAttribute("user_id");
    String activity_id = request.getParameter("activity_id");

    String msg = "";

    if(from_user_id == null) {
        msg = "session_expired";
        out.print(msg);
    } else {
        ArrayList my_activity_dislike_details_list_al = getPost_dislike_details(activity_id);

        org.json.JSONArray my_activity_dislike_details_list_json = new org.json.JSONArray(my_activity_dislike_details_list_al);

        out.print(my_activity_dislike_details_list_json);
    }
%>

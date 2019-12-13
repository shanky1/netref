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
        ArrayList activity_resp_list_al = getResponses_ForPost(activity_id);

        org.json.JSONArray activity_resp_list_json = new org.json.JSONArray(activity_resp_list_al);

        out.print(activity_resp_list_json);
    }
%>

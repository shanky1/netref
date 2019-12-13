<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String user_id = (String)session.getAttribute("user_id");

    String activity_id = request.getParameter("activity_id");
    String msg = "";

    if(user_id == null) {
        msg = "session_expired";
        out.print(msg);
    } else {
        ArrayList loadpost_list_al = loadPost_AL(user_id,activity_id);

        org.json.JSONArray loadpost_list_json = new org.json.JSONArray(loadpost_list_al);

        out.print(loadpost_list_json);
    }
    out.print(msg);
%>

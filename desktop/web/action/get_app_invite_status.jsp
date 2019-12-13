<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");

    org.json.JSONArray app_invite_contact_json;

    // Always get it from database
    ArrayList appInviteStatus = getAppInviteStatus(user_id);
    // System.out.println("appInviteStatus : "+appInviteStatus);
    app_invite_contact_json = new org.json.JSONArray(appInviteStatus);

    out.print(app_invite_contact_json);
%>
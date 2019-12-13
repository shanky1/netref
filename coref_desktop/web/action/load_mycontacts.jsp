<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String from_user_id = (String)session.getAttribute("user_id");

    String msg = "";

    if(from_user_id == null) {
        msg = "session_expired";
        out.print(msg);
    } else {
        ArrayList mycontacts_list_al = loadMyContacts_AL(from_user_id);

        org.json.JSONArray mycontacts_list_json = new org.json.JSONArray(mycontacts_list_al);

        out.print(mycontacts_list_json);
    }
%>

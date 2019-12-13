<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String from_user_id = (String)session.getAttribute("user_id");
    String company_id = (String)session.getAttribute("company_id");

    String msg = "";

    if(from_user_id == null) {
        msg = "session_expired";
        out.print(msg);
    } else {
        ArrayList post_list_al = loadPostRequirementActivities_AL(from_user_id, company_id);

        org.json.JSONArray post_list_json = new org.json.JSONArray(post_list_al);

        out.print(post_list_json);
    }
%>

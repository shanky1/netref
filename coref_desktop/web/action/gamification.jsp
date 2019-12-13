<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>
<%
    String emailid = (String)session.getAttribute("email");
    String posted_by = (String)session.getAttribute("user_id");

    String msg = "";

    if(posted_by == null) {
        msg = "session_expired";
        out.print(msg);
    } else {
/*
        msg = loadFreelancers(from_user_id);
        out.print(msg);
*/
        ArrayList gamification_list_al = gamification_AL(posted_by);

        org.json.JSONArray gamification_list_json = new org.json.JSONArray(gamification_list_al);

        out.print(gamification_list_json);
    }
%>

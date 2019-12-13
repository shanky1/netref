<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>
<%
    String emailid = (String)session.getAttribute("email");
    String from_user_id = (String)session.getAttribute("user_id");

    String msg = "";

    if(from_user_id == null) {
        msg = "session_expired";
        out.print(msg);
    } else {
/*
        msg = loadFreelancers(from_user_id);
        out.print(msg);
*/
        ArrayList referral_list_al = loadReferrals_AL(from_user_id);

        org.json.JSONArray referral__list_json = new org.json.JSONArray(referral_list_al);

        out.print(referral__list_json);
    }
%>

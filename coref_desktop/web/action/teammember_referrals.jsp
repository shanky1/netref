<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String from_user_id = (String)session.getAttribute("user_id");
    String contact_user_id = request.getParameter("contact_user_id");

    String msg = "";

    if(from_user_id == null) {
        msg = "session_expired";
        out.print(msg);
    } else {
        ArrayList teammember_referral_list_al = teamMember_Referrals_AL(contact_user_id);

        org.json.JSONArray teammember_referral_list_json = new org.json.JSONArray(teammember_referral_list_al);

        out.print(teammember_referral_list_json);
    }
%>

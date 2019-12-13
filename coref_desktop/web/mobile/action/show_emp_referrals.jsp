<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String from_user_id = (String)session.getAttribute("user_id");

    String emp_userid = request.getParameter("emp_userid");
    String emp_name = request.getParameter("emp_name");

    String msg = "";

    if(from_user_id == null) {
        msg = "session_expired";
    } else {
//        ArrayList emp_referral_list_al = loadEMPReferrals_AL(from_user_id, emp_userid, emp_name);
        ArrayList emp_referral_list_al = loadReferrals_AL(emp_userid);

        org.json.JSONArray emp_referral_list_json = new org.json.JSONArray(emp_referral_list_al);

        out.print(emp_referral_list_json);
    }

    out.print(msg);
%>

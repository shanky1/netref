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
/*
        msg = loadFreelancers(from_user_id);
        out.print(msg);
*/
        ArrayList topreferals_list_al = topreferals_AL(company_id);

        org.json.JSONArray topreferals_list_json = new org.json.JSONArray(topreferals_list_al);

        out.print(topreferals_list_json);
    }
%>

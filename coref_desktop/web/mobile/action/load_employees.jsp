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
        ArrayList emp_list_al = loadEMPs_AL(from_user_id);

        org.json.JSONArray emp_list_json = new org.json.JSONArray(emp_list_al);

        out.print(emp_list_json);
    }
%>

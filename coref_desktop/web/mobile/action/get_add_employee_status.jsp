<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");

    org.json.JSONArray add_employee_contact_json;

    // Always get it from database
    ArrayList addEmployeeStatus = getAddEmployeeStatus(user_id);
    add_employee_contact_json = new org.json.JSONArray(addEmployeeStatus);

    out.print(add_employee_contact_json);
%>

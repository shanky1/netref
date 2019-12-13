<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    ArrayList professions_al = getSuggestedProfessions();

    org.json.JSONArray professions_json = new org.json.JSONArray(professions_al);

    out.print(professions_json);
%>

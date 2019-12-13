<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    ArrayList keywords_al = getSuggestedKeywords();

    org.json.JSONArray keywords_json = new org.json.JSONArray(keywords_al);

    out.print(keywords_json);
%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");

    session.setAttribute("max_rsid", "0");

    int max_rsid = getMaxRSID(user_id);

    if (max_rsid > 0) {
        session.setAttribute("max_rsid", max_rsid + "");
        out.println(max_rsid);
    }
%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String from_user_id = (String)session.getAttribute("user_id");
    String search_by = request.getParameter("search_by");
    String search_value = request.getParameter("search_value");

    String msg = "failed";

    if(from_user_id == null) {
        msg = "session_expired";
    } else {
        msg = getSearchResults(search_by, search_value, from_user_id);
    }

    out.print(msg);
%>
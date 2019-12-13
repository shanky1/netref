<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%

    String from_user_id = (String)session.getAttribute("user_id");
    String comments = request.getParameter("comments");
    String company_id = (String)session.getAttribute("company_id");
    String msg = "";

    if(from_user_id == null) {
        msg = "session_expired";
        out.print(msg);
    } else {
 
        ArrayList getSuggestions_forAsk_list_al = getSuggestions_forAsk(comments,company_id);

        org.json.JSONArray getSuggestions_forAsk_list_json = new org.json.JSONArray(getSuggestions_forAsk_list_al);

        out.print(getSuggestions_forAsk_list_json);
    }
%>

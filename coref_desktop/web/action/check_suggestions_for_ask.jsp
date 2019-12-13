<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%

    String from_user_id = (String)session.getAttribute("user_id");
    String comments = request.getParameter("comments");
    //String activity_id = request.getParameter("activity_id");

    int post_ststus = 0;

    if(from_user_id == null) {
        out.print("session_expired");
        return;
    } else {
        ArrayList checkSuggestions_forAsk_list_al = checkSuggestions_forAsk(comments);

        org.json.JSONArray checkSuggestions_forAsk_list_json = new org.json.JSONArray(checkSuggestions_forAsk_list_al);

        out.print(checkSuggestions_forAsk_list_json);

           }
%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String from_user_id = (String)session.getAttribute("user_id");
    String form_str = "";

    if(from_user_id == null) {
        out.print("session_expired");
        return;
    }

    //Remove profile_doc, profile_doc_uploaded_time session values while opening the refer a friend form
    if(session.getAttribute("profile_doc") != null) {
        session.removeAttribute("profile_doc");
    }
    if(session.getAttribute("profile_doc_uploaded_time") != null) {
        session.removeAttribute("profile_doc_uploaded_time");
    }

    form_str = getReferAFriendForm();

    if (form_str != null) {
        out.print(form_str);
    } else {
        out.print(form_str);
    }
%>

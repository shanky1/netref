<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if(session.getAttribute("user_id") != null) {
        session.removeAttribute("user_id");
    }
    if(session.getAttribute("lin_publicProfileUrl") != null) {
        session.removeAttribute("lin_publicProfileUrl");
    }
    if(session.getAttribute("company_id") != null) {
        session.removeAttribute("company_id");
    }
    if(session.getAttribute("lin_profilePictureUrl") != null) {
        session.removeAttribute("lin_profilePictureUrl");
    }

    out.print("success");
%>

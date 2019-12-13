<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if(session.getAttribute("user_id") != null) {
        session.removeAttribute("user_id");
    }

    out.print("success");
%>

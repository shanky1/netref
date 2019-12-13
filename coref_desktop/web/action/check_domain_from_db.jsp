<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String user_id = (String)session.getAttribute("user_id");

    String uType = "";        //0 - new, 1 - client, 2 - freelancer

    if(user_id != null) {
        uType = checkDomain(user_id);
    }


    out.print(uType);
%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="../util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String user_id = (String)session.getAttribute("user_id");
    String user_type = request.getParameter("user_type");

    boolean status = false;
    String ret = "failed";

    if(user_id != null && user_type != null) {
        status = setUserType(user_id, user_type);
    }

    if(status) {
        ret = "success";
        session.setAttribute("user_type",user_type);
    }

    out.print(ret);
%>

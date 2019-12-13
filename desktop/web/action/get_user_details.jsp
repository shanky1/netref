<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="../util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String user_id = (String)session.getAttribute("user_id");
    String fb_photo_path = (String)session.getAttribute("fb_photo_path");
    String name = (String)session.getAttribute("name");

    String msg = "";

    if(fb_photo_path != null && name != null) {
        msg = "<img height='25px;' width='25px;' src='"+fb_photo_path+"'/>";
        msg += " "+name;
    }

    out.print(msg);
%>

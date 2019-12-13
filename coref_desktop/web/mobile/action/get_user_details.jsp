<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String user_id = (String)session.getAttribute("user_id");
    String fb_photo_path = (String)session.getAttribute("fb_photo_path");
//    String name = (String)session.getAttribute("name");

    String name = getProfileName(user_id);

    String msg = "";

    if(fb_photo_path == null || fb_photo_path.trim().length() <= 0) {
        msg = "<img height='45px;' width='45px;' class='img-circle' src='images/profile.jpg'/>";
        msg += "<p style='font-size:15px;display:inline'>&nbsp;&nbsp;"+name+"</p>";
    } else {
        msg = "<img height='45px;' width='45px;' class='img-circle'  src='"+fb_photo_path+"'/>";
        msg += "<p style='font-size:15px;display:inline'>&nbsp;&nbsp;"+name+"</p>";
    }

    out.print(msg);
%>

<%@include file="util.jsp" %>

<%
    String profession = request.getParameter("profession");
    String expertise = request.getParameter("expertise");
    String experience = request.getParameter("experience");
    String linkedin = request.getParameter("linkedin");
    String location = request.getParameter("location");
    String from_user_id = (String)session.getAttribute("user_id");

    if (from_user_id == null) {
        out.print("session_expired");
        return;
    }

     if(linkedin.indexOf("https://") < 0 && linkedin.indexOf("http://") < 0)
         linkedin = "https://"+linkedin;

    int status = addOrUpdateFLskills(profession,expertise, experience, linkedin, location, "", from_user_id);     //about yourself is empty from here

    if(status > 0) {
        out.print("success");
    } else {
        out.print("failed");
    }
%>

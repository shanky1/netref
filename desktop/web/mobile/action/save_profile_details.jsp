<%@include file="util.jsp" %>

<%
    String profile_name = request.getParameter("profile_name");
    String profile_profession = request.getParameter("profile_profession");
    String profile_expertise = request.getParameter("profile_expertise");
    String profile_experience = request.getParameter("profile_experience");
    String profile_linkedin = request.getParameter("profile_linkedin");
    String profile_location = request.getParameter("profile_location");
    String profile_about = request.getParameter("profile_about");

    String from_user_id = (String)session.getAttribute("user_id");

    if (from_user_id == null) {
        out.print("session_expired");
        return;
    }

    if(profile_linkedin != null && profile_linkedin.length() > 0 && !profile_linkedin.startsWith("https://") && !profile_linkedin.startsWith("http://"))
        profile_linkedin = "https://"+profile_linkedin;

    String status = saveProfileDetails(from_user_id, profile_name, profile_profession, profile_expertise, profile_experience, profile_linkedin,profile_location, profile_about);

    out.print(status);
%>

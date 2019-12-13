<%@include file="util.jsp" %>

<%
    String profile_name = request.getParameter("profile_name");
    String profile_expertise = request.getParameter("profile_expertise");
    String profile_linkedin = request.getParameter("profile_linkedin");
    String hr_consent = request.getParameter("hr_consent");

    String from_user_id = (String)session.getAttribute("user_id");

    if (from_user_id == null) {
        out.print("session_expired");
        return;
    }

    if(hr_consent == null) {
        hr_consent = "0";
    }

    if(profile_linkedin != null && profile_linkedin.length() > 0 && !profile_linkedin.startsWith("https://") && !profile_linkedin.startsWith("http://"))
        profile_linkedin = "https://"+profile_linkedin;

    String status = saveProfileDetails(from_user_id, profile_name, profile_expertise, profile_linkedin, hr_consent);

    out.print(status);
%>

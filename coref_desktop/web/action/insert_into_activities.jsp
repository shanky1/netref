<%@include file="util.jsp" %>

<%
    String contactprofile_linkedin = request.getParameter("contactprofile_linkedin");
    String contact_user_id = request.getParameter("contact_user_id");
    String contactprofile_name = request.getParameter("contactprofile_name");
    String contactprofile_skills = request.getParameter("contactprofile_skills");
    String from_user_id = (String)session.getAttribute("user_id");
    String post_type = "refer";

    if (from_user_id == null) {
        out.print("session_expired");
        return;
    }

    int status_suggest = referTeamMember(from_user_id, contact_user_id, contactprofile_linkedin, contactprofile_name, contactprofile_skills, post_type);

    if(status_suggest > 0) {
        out.print("success");
    } else {
        out.print("falied");
    }
%>

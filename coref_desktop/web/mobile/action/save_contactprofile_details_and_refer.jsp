<%@include file="util.jsp" %>

<%
    String contactprofile_linkedin = request.getParameter("contactprofile_linkedin");
    String contactprofile_fb = request.getParameter("contactprofile_fb");
    String contactprofile_skills = request.getParameter("contactprofile_skills");
    String contact_user_id = request.getParameter("contact_user_id");

    String from_user_id = (String)session.getAttribute("user_id");

    if (from_user_id == null) {
        out.print("session_expired");
        return;
    }

    int status_save = addOrUpdateContactProfileDetails(contact_user_id, contactprofile_linkedin, contactprofile_fb, contactprofile_skills);
    int status_refer = referContactToHR(from_user_id, contact_user_id);

    if(status_save > 0 && status_refer > 0) {
        out.print("success");
    } else {
        out.print("falied");
    }
%>

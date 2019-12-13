<%@include file="util.jsp" %>

<%
    String profile_name = request.getParameter("profile_name");
    String user_id = (String)session.getAttribute("user_id");

    int status = updateProfileDetails(profile_name, user_id);

    if(status > 0) {
        out.print("success");
    } else {
        out.print("failed");
    }
%>

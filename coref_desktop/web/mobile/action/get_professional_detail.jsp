<%@include file="util.jsp" %>

<%
    String professional_id = request.getParameter("fl_userid");
    String from_user_id = (String)session.getAttribute("user_id");

    String profile_details = getProfessionalDetails(professional_id,from_user_id);

    out.print(profile_details);
%>

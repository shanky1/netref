<%@include file="util.jsp" %>

<%
    String professional_id = request.getParameter("fl_userid");

    String profile_details = getProfessionalDetails(professional_id);

    out.print(profile_details);
%>

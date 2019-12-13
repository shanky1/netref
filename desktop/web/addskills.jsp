<%@include file="util.jsp" %>

<%
    String skills=request.getParameter("skills");
    String experience=request.getParameter("experience");
    String user_id = request.getParameter("user_id");

    int status= registerContractorskills(skills, experience, user_id);

    if(status > 0)
        response.sendRedirect("contractor.html");
%>

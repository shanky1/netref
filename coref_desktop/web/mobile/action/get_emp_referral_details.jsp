<%@include file="util.jsp" %>

<%
    String emp_userid = request.getParameter("emp_userid");
    String emp_name = request.getParameter("emp_name");

    String profile_details = getEmpReferralDetails(emp_userid, emp_name);

    out.print(profile_details);
%>

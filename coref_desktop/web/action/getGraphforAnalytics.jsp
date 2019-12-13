<%@include file="util.jsp" %>

<%
    String company_id = (String)session.getAttribute("company_id");

    ArrayList detail = getGraphforAnalytics(company_id);
//
    out.print(detail);

%>

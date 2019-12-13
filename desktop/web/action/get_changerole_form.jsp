<%@include file="../util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");

    String status = getUserRole(user_id);

    out.print(status);
%>

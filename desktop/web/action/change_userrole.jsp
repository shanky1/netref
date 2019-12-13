<%@include file="../util.jsp" %>

<%
    String user_role = request.getParameter("user_role");
    String user_id = (String)session.getAttribute("user_id");

    boolean status = changeUserRole(user_id, user_role);

    if(status) {
        out.print("success");
    } else {
        out.print("failed");
    }
%>

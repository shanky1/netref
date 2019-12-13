<%@include file="util.jsp" %>

<%
    String rs_id = request.getParameter("rs_id");
    String contact_user_id = request.getParameter("contact_user_id");
    String contact_name = request.getParameter("contact_name");

    int status = UpdateContactDetails(rs_id, contact_user_id, contact_name);

    if(status > 0) {
        session.setAttribute("updated_flag","true");
    }

   out.print(status);
%>

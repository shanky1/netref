<%@include file="util.jsp" %>

<%

    String contact_user_id = request.getParameter("contact_user_id");
    String user_id = (String)session.getAttribute("user_id");
   System.out.println(contact_user_id+" "+user_id+" "+contact_user_id);

    int status = deleteConcatDetails(contact_user_id,user_id);

   out.print(status);
%>

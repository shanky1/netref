<%@include file="util.jsp" %>

<%
    String manager_name=request.getParameter("manager_name");
    String manager_email=request.getParameter("manager_email");
    String user_id="28";

//    System.out.println(" "+manager_name+" "+manager_email);

    int status = registerManager(manager_name, manager_email, user_id);

    if(status>0)
        response.sendRedirect("freelancer.html");
%>

<%@include file="util.jsp" %>


<%
    String proj_title=request.getParameter("proj_title");
    String proj_description=request.getParameter("proj_description");
    String user_id = (String)session.getAttribute("user_id");


//    System.out.println(" "+devtasktitle+" "+devtaskdescription);

    int status= registerDeveloperTask(proj_title, proj_description, user_id);
    if(status>0)

        response.sendRedirect("freelancer.html");
//out.print("You are successfully registered");

%>
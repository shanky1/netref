<%@include file="util.jsp" %>

<%
int status=registerUser(obj);
if(status>0)  
out.print("You are successfully registered");  
response.sendRedirect("index.jsp");
%>  
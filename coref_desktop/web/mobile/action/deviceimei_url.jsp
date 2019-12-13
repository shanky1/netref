<%@include file="util.jsp" %>

<%
    String deviceIMEI = request.getParameter("deviceIMEI");

    if(deviceIMEI != null) {
        session.setAttribute("deviceIMEI", deviceIMEI);

        System.out.println(new java.util.Date()+"\t successfully set the deviceIMEI: "+deviceIMEI+" to session");
    }
%>

<%@ page import="java.util.Date" %>
<%@ page import="javax.json.*" %>

<%@ include file="util.jsp"%>

<%
    String ipAddress = request.getHeader("X-FORWARDED-FOR");

    if (ipAddress == null) {
        ipAddress = request.getRemoteAddr();
    }

    JsonReader jsonReader = Json.createReader(new InputStreamReader(request.getInputStream()));
    JsonArray contact_list = jsonReader.readArray();
    jsonReader.close();

    final JsonArray contact_list_final = contact_list;

    session.setAttribute(ipAddress, contact_list_final.toString());

    System.out.println(new Date()+"\t postcontacts_to_db_ios -> done with setting contact list for "+ipAddress+" in session: "+contact_list_final.size());

    out.print("success");
%>

<%@include file="util.jsp" %>

<%
    String country_code = request.getParameter("country_code");
    String phonenum = request.getParameter("phonenum");

    String deviceIMEI = request.getParameter("deviceIMEI");

    System.out.println(new Date()+"\t register_user_phone -> deviceIMEI: "+deviceIMEI);

    if(deviceIMEI == null) {
        deviceIMEI = "";
    }

//    int user_id = registerPhoneNumberIfNotExists(country_code, phonenum);
    int user_id = registerPhoneNumberIfNotExists(country_code, phonenum, deviceIMEI);

    out.print(user_id);
%>

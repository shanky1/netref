<%@include file="util.jsp" %>

<%
    String country_code = request.getParameter("country_code");
    String phonenum = request.getParameter("phonenum");

    String ipAddress = request.getHeader("X-FORWARDED-FOR");

    if (ipAddress == null) {
        ipAddress = request.getRemoteAddr();
    }

    String deviceID = "";
    String device_uuid_ios = "";
    String deviceIMEI_android = "";

    if(session.getAttribute(ipAddress+"_uuid") != null) {
        device_uuid_ios = (String)session.getAttribute(ipAddress+"_uuid");
    }

    if(request.getParameter("deviceIMEI") != null) {
        deviceIMEI_android = request.getParameter("deviceIMEI");
    }

    String deviceType = request.getParameter("deviceType");

    if(deviceType != null && deviceType.equalsIgnoreCase("ios")) {
        deviceID = device_uuid_ios;
    } else if(deviceType != null && deviceType.equalsIgnoreCase("android")) {
        deviceID = deviceIMEI_android;
    }

    System.out.println(new Date()+"\t register_user_phone -> deviceID: "+deviceID);

//    int user_id = registerPhoneNumberIfNotExists(country_code, phonenum);
    int user_id = registerPhoneNumberIfNotExists(country_code, phonenum, deviceID);

    out.print(user_id);
%>

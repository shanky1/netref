<%@ page import="java.io.PrintWriter" %>
<%@ include file="util.jsp"%>

<%
    PrintWriter output = response.getWriter();

    String country_code = request.getParameter("country_code");
    String phonenum = request.getParameter("phonenum");

    String mobilenum = country_code+""+phonenum;

    String userId_str = request.getParameter("user_id");

    long userId = Long.parseLong(userId_str);

    String verification_code = generateVerificationCode();

//        Check number of credits available

//    int sms_available_credits = checkSMSAvailableCredits();       //TODO, WORKING, commented out
    int sms_available_credits = 1;

    if(sms_available_credits > 0) {

//        Send verification code to mobile

        try {
            String sms_status = "failed";

//        String mobilenum_hash = hashpw(mobilenum, gensalt());
            byte[] mobile_bytes = processEncrypt(mobilenum);

            if(server_type.equalsIgnoreCase("test")) {
                //send message only once
                boolean verification_status = getverificationSentStatusForTestNumber();      //checking if the message has already sent for the current day, and not sending again
                //true - send the message for the current day; false - do not send the message

                if(verification_status) {
                    System.out.println(new Date()+"\t smscode -> sending verification code to test_user_id: "+test_user_id+" on behalf of userId: "+userId);
                    sms_status = sendVerificationCodeToMobile_Twilio(test_mobile_number, verification_code);
                } else {
                    System.out.println(new Date()+"\t smscode -> verification code already sent for today to test_user_id: "+test_user_id);
                    sms_status = "queued";
                }
            } else {
                System.out.println(new Date()+"\t smscode -> sending verification code to userId: "+userId);
                sms_status = sendVerificationCodeToMobile_Twilio(mobilenum, verification_code);
            }

            System.out.println(new Date()+"\t smscode -> userId: "+userId_str+", sms_status: "+sms_status+", verification_code: "+verification_code);

            if(sms_status.equalsIgnoreCase("queued") || sms_status.equalsIgnoreCase("test_queued")) {
                boolean status = insertMobile(userId, mobile_bytes, verification_code);

                if(status) {
                    output.println("Successfully sent the verification code to: "+mobilenum);
                    System.out.println(new Date()+"\t smscode -> Successfully sent the verification code to userId: "+userId);
                } else {
                    output.println("Could not send the verification code to: "+mobilenum);
                    System.out.println(new Date()+"\t smscode -> Could not send the verification code to userId: "+userId);
                }
            } else {
                output.println("Could not send the verification code to: "+mobilenum);
                System.out.println(new Date()+"\t smscode -> Could not send the verification code to userId: "+userId);
            }
        } catch(Exception e) {
            output.println("Could not send the verification code to: "+mobilenum);
            System.out.println(new Date()+"\t smscode -> Could not send the verification code to userId: "+userId);
        }
    } else {
        output.println("Could not send the verification code to: "+mobilenum);
        System.out.println(new Date()+"\t smscode -> Could not send the verification code to userId: "+userId);
    }
%>

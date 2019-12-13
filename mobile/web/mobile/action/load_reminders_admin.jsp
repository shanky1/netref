<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="reminder_util.jsp" %>

<%
    String reminder_value = request.getParameter("rem_type");

    String msg = "";

    if(reminder_value.equalsIgnoreCase("invited")){
        System.out.println("invited");
       msg = reminderInvited_user();
    } else if(reminder_value.equalsIgnoreCase("notregistered")){
        System.out.println("notregistered");
        msg = inviteNotRegistered_Admin();
    } else if(reminder_value.equalsIgnoreCase("registered")){
        System.out.println("Registered");
        msg = loadInvitedRegistered_Admin();
    } else if(reminder_value.equalsIgnoreCase("notactive")){
        System.out.println("notactive");
        msg = loadInActive_Admin();
    }

    out.print(msg);
%>

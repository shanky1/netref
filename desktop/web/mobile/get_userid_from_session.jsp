<%@ page import="java.util.Date" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
//    System.out.println(new Date()+"\t Request handler 'get_userid_from_session' was called");

    String user_id_str = (String)session.getAttribute("user_id");
    long user_id = -1;

    if(user_id_str != null) {
        try {
            user_id = Long.parseLong(user_id_str);
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        }
    }

    out.print(user_id);
%>

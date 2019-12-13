<%@ page import="java.util.Date" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    System.out.println(new Date()+"\t Request handler 'get_userid_from_session' was called");

    String client_user_id_str = (String)session.getAttribute("user_id");
    String client_user_type = (String)session.getAttribute("user_type");
    String company_id = (String)session.getAttribute("company_id");

//    System.out.println(new Date()+"\t company_id from session: "+company_id);

    long client_user_id = -1;

    if(client_user_id_str != null) {
        try {
            client_user_id = Long.parseLong(client_user_id_str);
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        }
    }

    if(client_user_type == null) {
        client_user_type = "1";
    }

    out.print(client_user_id+"|"+client_user_type);
%>

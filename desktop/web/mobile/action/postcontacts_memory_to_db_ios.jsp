<%@ page import="java.util.Date" %>
<%@ page import="javax.json.*" %>

<%@ include file="util.jsp"%>

<%
    String user_id = (String)session.getAttribute("user_id");

    if(user_id == null) {
        out.print("session_expired");
        return;
    }

    String ipAddress = request.getHeader("X-FORWARDED-FOR");

    if (ipAddress == null) {
        ipAddress = request.getRemoteAddr();
    }

    String contactslist_json = (String)session.getAttribute(ipAddress);

    if(contactslist_json == null) {
        //contact list is empty. Do nothing
        return;
    }

    final String contactslist_json_final = contactslist_json;
    final String user_id_final = user_id;
    final String ipAddress_final = ipAddress;

    Thread thread = new Thread(new Runnable() {
        //        @Override
        public void run() {
            try {
                String name = "";
                String phNo = "";
                String email = "";

                JsonReader reader = Json.createReader(new StringReader(contactslist_json_final));
                JsonArray contact_list = reader.readArray();

                System.out.println(new Date()+"\t postcontacts_memory_to_db_ios -> reading contactslist_json from "+ipAddress_final+": "+contact_list.size());

                boolean res = postContactsToDB_iOS(user_id_final, contact_list);
            } catch(Exception pe) {
                System.out.println(new Date()+"\t "+pe);
            }
//            System.out.println("End time: "+new Date());
        }
    });

    thread.start();

    out.print("success");
%>

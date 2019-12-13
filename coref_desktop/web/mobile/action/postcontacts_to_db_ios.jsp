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

    //Get the Device ID and put it in the session - Added on 19sept2016
    {
        boolean uuid_found = false;
        for(int i = 0; i < contact_list.size(); i++) {
            javax.json.JsonObject contacts_obj = null;
            contacts_obj = contact_list.getJsonObject(i);

            if(contacts_obj.size() < 2) {
                continue;
            }

            try {
                String name = contacts_obj.getString("name");
                String number = contacts_obj.getString("number");

                if(!name.equalsIgnoreCase("_uuid")) {
                    continue;
                } else {
                    uuid_found = true;
                    session.setAttribute(ipAddress+"_uuid", number);
                    System.out.println(new Date()+"\t postContactsToDB_iOS -> Successfully received the device id "+number+" for the ipAddress: "+ipAddress);
                    break;
                }
            } catch (Exception e) {
                System.out.println(new Date()+"\t postContactsToDB_iOS -> Could not get/set the device id for the ipAddress: "+ipAddress);
                e.printStackTrace();
            }
        }

        if(!uuid_found) {
            System.out.println(new Date()+"\t postContactsToDB_iOS -> Could not receive the device id for the ipAddress: "+ipAddress);
        }
    }

    final JsonArray contact_list_final = contact_list;

    session.setAttribute(ipAddress, contact_list_final.toString());

    System.out.println(new Date()+"\t postcontacts_to_db_ios -> done with setting contact list for "+ipAddress+" in session: "+contact_list_final.size());

    out.print("success");
%>

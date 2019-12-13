<%@include file="util.jsp" %>
<%@include file="encryption_util.jsp" %>

<%
    String from_user_id = (String)session.getAttribute("user_id");

    String email_addresses = request.getParameter("email_address");
    String invite = request.getParameter("invite");
    String company_id = (String)session.getAttribute("company_id");

    System.out.println(new Date()+"\t add_team_members.jsp -> company_id from session: "+company_id);

    String status = "";
    String from_profile_name = "";

    if(session.getAttribute("profileName") != null) {         //Get it from session
        from_profile_name = (String)session.getAttribute("profileName");
    }

    if (from_user_id == null) {
        out.print("session_expired");
        return;
    }

    String[] email_addressArray = email_addresses.split(",");

    Connection con = null;

    try {
        String company_id_enc = encode(company_id);

        con = getConnection();

        for(int i = 0; i < email_addressArray.length; i++) {
            String tm_email = email_addressArray[i].trim();
            int to_user_id = addTeamMembers(con, from_user_id, tm_email);

            if(to_user_id > 0) {
                if(invite.equals("1")) {
                    inviteTeamMember(from_profile_name, tm_email, company_id_enc);
                    status += "Successfully added and invited: "+tm_email+"<br>";
                } else {
                    status += "Successfully added: "+tm_email+"<br>";
                }
            } else {
                status += "Could not add: "+tm_email+"<br>";
            }
        }
        out.print(status);
    } catch(Exception se) {
        System.err.print(new Date()+"\t "+se.getMessage());
        out.print("failed");
    } finally {
        if(con != null ) {
            closeConnection(con);
        }
    }
%>

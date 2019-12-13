<%@include file="util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");
    String company_id = (String)session.getAttribute("company_id");
    String msg = "failed";
    String profilePictureUrl = "";
    String profileName = "";
    String company ="";
    String status = "";
    PreparedStatement ps = null;
    ResultSet rs = null;
    Connection con = null;
    if(user_id == null) {
        msg = "session_expired";
    } else {
        if(session.getAttribute("lin_profilePictureUrl") != null) {         //Get it from session
            System.out.println(new Date()+"\t getting lin_profilePictureUrl from session for user_id: "+user_id);
            profilePictureUrl = (String)session.getAttribute("lin_profilePictureUrl");
        } else {                                                            //Get it from database
            System.out.println(new Date()+"\t getting lin_profilePictureUrl from database for user_id: "+user_id);
            profilePictureUrl = getLinProfilePictureUrl(user_id);
        }
	
        if(session.getAttribute("profileName") != null) {         //Get it from session
            System.out.println(new Date()+"\t getting firstName from session for user_id: "+user_id);
            profileName = (String)session.getAttribute("profileName");
        }
        try {
            con = getConnection();
            String sql_CheckUserMap = "select * from companies where company_id = ?";

            ps = getPs(con, sql_CheckUserMap);
            ps.setString(1, company_id);
            System.out.println(new Date()+"\t sql_CheckUserMap -> ps: "+ps);
            rs = ps.executeQuery();
            if(rs.next()) {
                company = rs.getString("domain_name");
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
        msg = profilePictureUrl + "|"+ profileName+ "|"+ company ;
    }

    out.print(msg);
%>

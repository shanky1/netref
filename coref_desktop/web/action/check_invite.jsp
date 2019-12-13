<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>
<%@include file="encryption_util.jsp" %>
<%

    String tm_email = request.getParameter("check_email");

    String status = "";
    PreparedStatement ps = null;
    ResultSet rs = null;
    Connection con = null;

    try {
        con = getConnection();
        String sql_CheckUserMap = "select * from users u, users_mapping b where u.user_id = b.to_user_id and u.email = ?";

        ps = getPs(con, sql_CheckUserMap);
        ps.setString(1, tm_email);
        System.out.println(new Date()+"\t sql_CheckUserMap -> ps: "+ps);
        rs = ps.executeQuery();
        if(rs.next()) {
            System.out.println("success");
            String sql_GetcompanyDetails = "\n" +
                    "select u.name,u.user_id,c.domain_name from users u, users_mapping b,companies c,user_company_map d where b.to_user_id = (select user_id from users where  email = ?) and  b.from_user_id = d.user_id and c.company_id = d.company_id\n" +
                    "and  b.from_user_id = u.user_id";

            ps = getPs(con, sql_GetcompanyDetails);
            ps.setString(1, tm_email);
            System.out.println(new Date()+"\t sql_GetcompanyDetails -> ps: "+ps);
            rs = ps.executeQuery();

            if(rs.next()) {
                String from_profile_name = rs.getString("name");
                String company_id = rs.getString("domain_name");
                String company_id_enc = encode(company_id);
                System.out.println(from_profile_name);
                System.out.println(company_id);
                System.out.println(company_id_enc);
                inviteTeamMember(from_profile_name, tm_email, company_id_enc);
                status += "Successfully sent the invitation to: "+tm_email+"<br>";
            }
        } else {
            status += "You are not invited by any of the team<br>";
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

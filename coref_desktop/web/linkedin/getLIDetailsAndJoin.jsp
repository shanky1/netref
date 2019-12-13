<%@ page import="java.io.InputStreamReader"%>
<%@ page import="java.io.BufferedReader"%>
<%@ page import="org.apache.commons.httpclient.NameValuePair"%>
<%@ page import="org.apache.commons.httpclient.methods.GetMethod" %>
<%@ page import="org.apache.commons.httpclient.methods.PostMethod"%>
<%@ page import="org.apache.commons.httpclient.HttpClient"%>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.io.StringReader" %>
<%@ page import="javax.json.Json" %>
<%@ page import="javax.json.JsonReader" %>
<%@ page import="javax.json.JsonObject" %>
<%@ page import="com.sun.xml.internal.bind.v2.TODO" %>
<%@ page  contentType="text/html; charset=UTF-8"
          pageEncoding="UTF-8"%>
<%@ include file="../action/db.jsp"%>

<%@ page session="true"%>

<!DOCTYPE html>
<html>
<head>
    <title>Linkedin</title>
</head>
<body>

<%!
    String clientId = "86enw01rzt6kfs";             //Shankar's Coref
    String clientscrete = "MbtZgxN9inVdMGx5";

    String redirectURL = "../join.html";
%>

<%
    // getting user consent code. We will use this code to obtain Autherization code. Ie access code
    String code = request.getParameter("code");

    try {

        HttpClient client = new HttpClient();
        PostMethod post = new PostMethod("https://www.linkedin.com/oauth/v2/accessToken");
        post.addRequestHeader("Host", "www.linkedin.com");
        post.addRequestHeader("Content-Type", "application/x-www-form-urlencoded");

        NameValuePair[] data = {
                new NameValuePair("code", code),
                new NameValuePair("client_id", clientId),
                new NameValuePair("client_secret", clientscrete),
                new NameValuePair("redirect_uri", "http://coref.co/coref/linkedin/getLIDetailsAndJoin.jsp"),
                new NameValuePair("grant_type", "authorization_code")
        };

        post.setRequestBody(data);
        client.executeMethod(post);

        BufferedReader b = new BufferedReader(new InputStreamReader(post.getResponseBodyAsStream()));
        StringBuilder sb = new StringBuilder();
        String str = null;

        while ((str = b.readLine()) != null) {
            sb.append(str);
        }

        JSONObject access_token = new JSONObject(sb.toString());

        // We will use contact api now to get profile details. We also need to pass access_token with the request
        //so that server identify it a valid request

//        String get_connection_details = "https://api.linkedin.com/v1/people/~?format=json";
        String get_connection_publicprofile = "https://api.linkedin.com/v1/people/~:(public-profile-url)?format=json";
        String get_connection_friends = "https://api.linkedin.com/v1/people/~/connections?format=json";

        String get_connection_details = "https://api.linkedin.com/v1/people/~:(id,first-name,last-name,picture-url,public-profile-url,email-address,headline)?format=json";

        String get_connection_url = get_connection_details;

        String tk2 = access_token.getString("access_token");

        GetMethod profile_get = new GetMethod(get_connection_url);
        profile_get.addRequestHeader("Host", "api.linkedin.com");
        profile_get.addRequestHeader("Connection", "Keep-Alive");
        profile_get.addRequestHeader("Content-Type", "pplication/x-www-form-urlencodeda");
        profile_get.addRequestHeader("Authorization", "Bearer "+tk2);

        client.executeMethod(profile_get);

        BufferedReader profile_br = new BufferedReader(new InputStreamReader(profile_get.getResponseBodyAsStream()));
        StringBuilder profile_sb = new StringBuilder();
        String profile_str = null;

        while ((profile_str = profile_br.readLine()) != null) {
            profile_sb.append(profile_str);
        }

//        System.out.println(new Date()+"\t Profile details: "+profile_sb.toString());

        JsonReader reader = Json.createReader(new StringReader(profile_sb.toString()));
        JsonObject profile_obj = reader.readObject();

        String lin_publicProfileUrl = "https://www.linkedin.com/";
        String firstName = "";
        String lastName = "";
        String headline = "";
        String emailAddress = "";
        String lin_profilePictureUrl = "";

        try {
            lin_publicProfileUrl = profile_obj.getString("publicProfileUrl");
        } catch(Exception e) {
            System.out.println(new Date()+"\t Could not get the linkedin public profile Url");
        }
        try {
            lin_profilePictureUrl = profile_obj.getString("pictureUrl");
        } catch(Exception e) {
            System.out.println(new Date()+"\t Could not get the linkedin profile picture Url");
        }

        try {
            firstName = profile_obj.getString("firstName");
        } catch(Exception e) {
            System.out.println(new Date()+"\t Could not get firstname");
        }

        try {
            lastName = profile_obj.getString("lastName");
        } catch(Exception e) {
            System.out.println(new Date()+"\t Could not get lastName");
        }

        try {
            headline = profile_obj.getString("headline");
        } catch(Exception e) {
            System.out.println(new Date()+"\t Could not get headline");
        }
        try {
            emailAddress = profile_obj.getString("emailAddress");
        } catch(Exception e) {
            System.out.println(new Date()+"\t Could not get headline");
        }

//        System.out.println(new Date()+"\t firstName: "+firstName+", lastName: "+lastName+", headline: "+headline+", lin_publicProfileUrl: "+lin_publicProfileUrl+", emailAddress: "+emailAddress);

        String userDetails = insertOrUpdateUserDetails(firstName, lastName, emailAddress, lin_publicProfileUrl, lin_profilePictureUrl);

        String[] userDetails_split = userDetails.split("\\|");

        int userId = Integer.parseInt(userDetails_split[0]);
        int userType = Integer.parseInt(userDetails_split[1]);

        if (userId > 0) {
            session.setAttribute("user_id", userId+"");
            session.setAttribute("user_type", userType+"");
            session.setAttribute("lin_publicProfileUrl", lin_publicProfileUrl);
            session.setAttribute("lin_profilePictureUrl", lin_profilePictureUrl);
            session.setAttribute("profileName", firstName+" "+lastName);

            redirectURL = "../join.html";

            String company_id_str = (String)session.getAttribute("company_id");

            int company_id = Integer.parseInt(company_id_str);

            if(company_id > 0) {
                int map_status = mapCompanyToUser(userId+"", company_id);                //We are going to map user to company_id
                redirectURL = "../index.html";
            }
            System.out.println(new Date()+"\t getLIDetailsAndJoin -> user_id: "+userId+", company_id: "+company_id+", redirecting to: "+redirectURL);
%>
<script>
    window.location = "<%=redirectURL%>";
</script>

<%
} else {
%>

<script>
    window.location = "../login.html";
</script>

<%
    }
} catch (Exception e) {
    e.printStackTrace();
    request.setAttribute("errorstatus", "unable to get the information.");
%>
<script>
    window.location = "../join.html";
</script>
<%
    }
%>

</body>
</html>

<%!
    public String insertOrUpdateUserDetails(String firstName, String lastName, String emailAddress, String lin_publicProfileUrl, String lin_profilePictureUrl) {
        ResultSet rs = null;
        Connection conn = null;
        PreparedStatement ps = null;
        PreparedStatement ps_checkEmail = null;
        ResultSet rsEmail = null;
        int userId = -1;
        int userType = 1;       //1 - Employee; 2 - HR

        boolean updateUserDetails = true;               //Lets decide if we need to update linked in details, if any

        try {
            conn = getConnection();
            String sql_checkEmail = "select * from users where email = ?";
            ps_checkEmail = conn.prepareStatement(sql_checkEmail);
            ps_checkEmail.setString(1, emailAddress);
            rsEmail = ps_checkEmail.executeQuery();

            if (rsEmail.next()) {               //User already exists, get the userId
                userId = rsEmail.getInt(1);
                userType = rsEmail.getInt("user_type");

                if(updateUserDetails) {
                    //User already exist, update linkedin name and profile image url, profile public url
                    String sql_updateUserDetails = "update users set name = ?, lin_public_profile_url = ?, lin_profile_picture_url = ? WHERE user_id = ?";

                    ps = conn.prepareStatement(sql_updateUserDetails);
                    ps.setString(1, firstName+" "+lastName);
                    ps.setString(2, lin_publicProfileUrl);
                    ps.setString(3, lin_profilePictureUrl);
                    ps.setInt(4, userId);

                    ps.executeUpdate();
                }
            } else {                            //User doesn't exist, insert and get the userId
                String sql_insertUserDetails = "insert into users(email, name, lin_public_profile_url, lin_profile_picture_url) values (?, ?, ?, ?)";

                ps = conn.prepareStatement(sql_insertUserDetails, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, emailAddress);
                ps.setString(2, firstName+" "+lastName);
                ps.setString(3, lin_publicProfileUrl);
                ps.setString(4, lin_profilePictureUrl);

                int id = ps.executeUpdate();
                if(id == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next())
                        userId = rs.getInt(1);
                }
            }
        } catch (Throwable t) {
            t.printStackTrace();
        } finally {
            try {
                if (ps != null) ps.close();
                if (rs != null) rs.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            if(conn != null)
                closeConnection( conn);
        }
        return userId+"|"+userType;
    }

//    TODO, same function as in the util.jsp. Added here again because of some classes are in multiple packages

    final String sql_checkcompany_map = "select * from user_company_map where user_id = ? and company_id = ?";
    final String sql_insertcompany_map = "insert into user_company_map (user_id, company_id) values (?, ?)";

    public int mapCompanyToUser(String user_id, int company_id) {
        int status = 0;

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();
//            Map company_id to user, if not exists

            ps = getPs(con, sql_checkcompany_map);
            ps.setString(1, user_id);
            ps.setInt(2, company_id);

            rs = ps.executeQuery();

            if(rs.next()) {
//                User to company mapping already exists. Do nothing
            } else {
                ps = getPs(con, sql_insertcompany_map);

                ps.setString(1, user_id);
                ps.setInt(2, company_id);

                status = ps.executeUpdate();
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }
%>

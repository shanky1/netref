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
<%@ page  contentType="text/html; charset=UTF-8"
          pageEncoding="UTF-8"%>
<%@ include file="../action/db.jsp"%>

<!DOCTYPE html>
<html>
<head>
    <title>Linkedin details</title>
</head>
<body>

<%!
    String clientId = "81in7bsts2vce8";
    String clientscrete = "HzjkQAvdJ2SzMuO7";
    List<Map<String,Object>> LIConnectionsList = new ArrayList<Map<String,Object>>();
%>

<%
    String from_user_id = (String)session.getAttribute("user_id");

    if (from_user_id == null) {
%>
<script>
    window.location = "../mobilehr.html";
</script>
<%
    }

    // getting user consent code. We will use this code to obtain Autherization code. Ie access code
    String code = request.getParameter("code");

    HttpClient client = new HttpClient();
    PostMethod post = new PostMethod("https://www.linkedin.com/oauth/v2/accessToken");
    post.addRequestHeader("Host", "www.linkedin.com");
    post.addRequestHeader("Content-Type", "application/x-www-form-urlencoded");

    NameValuePair[] data = {
            new NameValuePair("code", code),
            new NameValuePair("client_id", clientId),
            new NameValuePair("client_secret", clientscrete),
            new NameValuePair("redirect_uri", "http://50.16.185.228/coref/mobile/linkedin/getLIConnectionsHR.jsp"),
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

    try {
        // We will use contact api now to get profile details. We also need to pass access_token with the request
        //so that server identify it a valid request

        String get_connection_details = "https://api.linkedin.com/v1/people/~?format=json";
        String get_connection_publicprofile = "https://api.linkedin.com/v1/people/~:(public-profile-url)?format=json";
        String get_connection_friends = "https://api.linkedin.com/v1/people/~/connections?format=json";

        String get_connection_url = get_connection_publicprofile;

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

        try {
            lin_publicProfileUrl = profile_obj.getString("publicProfileUrl");
        } catch(Exception e) {
            System.out.println(new Date()+"\t Could not get the linkedin public profile Url");
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

//        System.out.println(new Date()+"\t firstName: "+firstName+", lastName: "+lastName+", headline: "+headline+", lin_publicProfileUrl: "+lin_publicProfileUrl);

        saveLINPublicProfileUrl(from_user_id, lin_publicProfileUrl);
    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("errorstatus", "unable to get the information.");
    }
%>

<script>
    window.location = "../mobilehr.html?redirected_from=lin";
</script>

</body>
</html>

<%!
    final String sql_updateProfileURL = "update employee_details set linkedin = ? where user_id = ?";

    public void saveLINPublicProfileUrl(String from_user_id, String lin_publicProfileUrl) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = getConnection();
            ps = getPs(con, sql_updateProfileURL);

            ps.setString(1, lin_publicProfileUrl);
            ps.setString(2, from_user_id);

            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }
%>

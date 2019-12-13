<%-- 
    Document   : Fbhnadler
    Created on : May 30, 2015, 8:41:06 AM
    Author     : kundan
--%>

<%@page import="javax.json.JsonObject"%>
<%@page import="javax.json.JsonReader"%>
<%@page import="javax.json.Json"%>
<%@page import="java.io.ByteArrayInputStream"%>
<%@page import="org.scribe.model.Response"%>
<%@page import="org.scribe.model.Verb"%>
<%@page import="org.scribe.model.OAuthRequest"%>
<%@page import="org.scribe.model.Verifier"%>
<%@page import="org.scribe.model.Token"%>
<%@page import="org.scribe.oauth.OAuthService"%>
<%@ page import="com.restfb.DefaultFacebookClient" %>
<%@ page import="com.restfb.FacebookClient" %>
<%@ page import="com.restfb.types.User" %>
<%@ page import="com.restfb.exception.FacebookException" %>
<%@ page import="java.util.List" %>

<%@ include file="util.jsp"%>

<head>
    <script type="text/javascript">
        function setCookieForFBLoginAndRedirect(netref_cookie_login_val, redirectURL) {
            var cookie_name = "netref_cookie_login";
            var cookie_value = netref_cookie_login_val;
            var days = 365;

            var date = new Date();
            var time = date.getTime()+(days*24*60*60*1000);
            date.setTime(time);
            var expires = "; expires="+date.toGMTString();

            var cookie_set = cookie_name+"="+cookie_value+expires+"; path=/";

            document.cookie = cookie_set;

            window.location = redirectURL;
        }
    </script>
</head>

<%
    String FPROTECTED_RESOURCE_URL = "https://graph.facebook.com/me?fields=id,name,first_name,last_name,email,gender,birthday,picture{url}";

    // Check error code
    String code = request.getParameter("code");
    if(code == null || code.trim().equals("")){
        HttpSession sess = request.getSession();
        sess.invalidate();
        response.sendRedirect(request.getContextPath());
        return;
    }
    // User is authenticated. Get details to insert into database

    HttpSession sess = request.getSession();
    OAuthService service = (OAuthService)sess.getAttribute("fboauth2Service");

    if(service == null) {
        out.println("<br><br><center>Session is expired. Please <a href='register.html'>re-login</a> and try again or contact support.</center>");
        return;
    }

    //END

    //Construct the access token
    Token token = service.getAccessToken(Token.empty(), new Verifier(code));

    //Save the token for the duration of the session
    sess.setAttribute("token", token);

//      //Perform a proxy login
//      try {
//         request.login("fred", "fredfred");
//         
//      } catch (ServletException e) {
//         //Handle error - should not happen
//      }

    //Now do something with it - get the user's G+ profile
    OAuthRequest oReq = new OAuthRequest(Verb.GET,FPROTECTED_RESOURCE_URL);

    service.signRequest(token, oReq);
    Response oResp = oReq.send();

    //Read the result

    JsonReader reader = Json.createReader(new ByteArrayInputStream(oResp.getBody().getBytes()));
    JsonObject profile = reader.readObject();

    System.out.println("--------");
    System.out.println("logged in user profile: "+profile);
    System.out.println("--------");

//  Get friend details
    FacebookClient facebookClient = new DefaultFacebookClient(token.getToken());
    com.restfb.Connection<User> friends1 = null;

    try {
        friends1 = facebookClient.fetchConnection("me/friends", User.class);
    } catch (FacebookException e) {
        e.printStackTrace();
    }

    List<User> friendsList1 = friends1.getData();

    String first_name = profile.getString("first_name");
    String last_name = profile.getString("last_name");
    String email = "";

    if(profile.containsKey("email")) {
        email = profile.getString("email");
    } else {
        email = profile.getString("id");
    }

    String name = (first_name != null ? first_name : "")+" "+(last_name != null ? last_name : "");
    String gender = profile.getString("gender");

    String fb_photo_path = parsePictureURL(profile.toString());
    String fb_app_id = profile.getString("id");

    sess.setAttribute("email",email);

    if(gender.equalsIgnoreCase("male")) {
        gender = "M";
    } else if(gender.equalsIgnoreCase("female")) {
        gender = "F";
    }

    boolean iu = insertUserIfNotExist(email, name, gender, fb_photo_path, fb_app_id);

    String redirectURL = "register.html";

    if(iu) {
        long userId = getUserId(email);
        boolean insert_fb_friends = insertUserFBFriendsIfNotExist(userId, fb_app_id, friendsList1);
        sess.setAttribute("user_id",userId+"");
        sess.setAttribute("fb_photo_path",fb_photo_path);
        sess.setAttribute("name",name);
        sess.setAttribute("first_name",first_name);
        sess.setAttribute("last_name",last_name);

        redirectURL = "enter.html";
    }
%>

<script type="text/javascript">
    setCookieForFBLoginAndRedirect('<%=email%>','<%=redirectURL%>');
</script >

<%!
    private String parsePictureURL(String profile) {

        //TODO, Unable to get the picture from the JSon object directly. So parsing in the kludgy way

        String picURL = "";

        int index_start = profile.indexOf("https://");

        int index_end = profile.indexOf("\"", index_start);

        picURL = profile.substring(index_start, index_end);

        return picURL;
    }
%>

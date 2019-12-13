<%@page import="org.scribe.builder.api.FacebookApi"%>
<%@page import="org.scribe.oauth.OAuthService"%>
<%@page import="org.scribe.builder.ServiceBuilder"%>

<%
    // College labs APP id changed to netref
    String FapiKey = "178898775511847";
    String FapiSecret = "e0dd8c3ce91128fa1dcdc4f031b8713d";
    String FcallBackURL="http://netref.co/netref/mobile/Fbhandler.jsp";

    OAuthService service = new ServiceBuilder()
            .provider(FacebookApi.class)
            .apiKey(FapiKey)
            .apiSecret(FapiSecret)
            .callback(FcallBackURL)
            .scope("public_profile,email,user_friends")
            .debug()
            .build();

    session.setAttribute("fboauth2Service", service);

    response.sendRedirect(service.getAuthorizationUrl(null));
%>

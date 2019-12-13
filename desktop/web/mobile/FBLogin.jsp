<%@page import="org.scribe.builder.api.FacebookApi"%>
<%@page import="org.scribe.oauth.OAuthService"%>
<%@page import="org.scribe.builder.ServiceBuilder"%>

<%
    // College labs APP id changed to netref
    String FapiKey = "107693579580192";
    String FapiSecret = "c83c9198ab562ff14f700e5d215a99ce";
    String FcallBackURL="http://50.16.185.228/netref/mobile/Fbhandler.jsp";

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

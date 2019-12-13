
<%
  String req_url = request.getRequestURL().toString();
  
  //System.out.println("req_url: "+req_url);
  //System.out.println("indexOf("+req_url+"): "+req_url.indexOf(req_url));
  
  if(req_url==null || req_url.length()==0) {
        response.setStatus(301);
	response.setHeader( "Location", "netref/register.html" );
	response.setHeader( "Connection", "close" );
    }
    
    

%>


<%@ page import="org.jsoup.nodes.Document" %>
<%@ page import="org.jsoup.Connection" %>
<%@ page import="org.jsoup.Jsoup" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.net.URLConnection" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>

<%
    String urlString = "https://linkedin.com/in/sudipta-bhaumik-53a062a8";
    String res = scrapLIN_jsoup(urlString);

    out.println(res);
%>

<%!
    public static String scrapLIN_jsoup(String urlString) {
        try {
            URL urlObj = new URL(urlString);
            URLConnection con = urlObj.openConnection();

            con.setDoOutput(true); // we want the response
//                con.setRequestProperty("User-Agent", "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9.2.2) Gecko/20100316 Firefox/3.6.2");
//                con.setRequestProperty("User-Agent", "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0");
//                con.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36");
            con.setRequestProperty("User-agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36");
            con.setRequestProperty("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
            con.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
            con.setRequestProperty("Accept-Encoding", "gzip, deflate, br");
            con.setRequestProperty("Connection", "keep-alive");
            con.connect();

            BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));

            StringBuilder response = new StringBuilder();
            String inputLine;

            String newLine = System.getProperty("line.separator");
            while ((inputLine = in.readLine()) != null)
            {
                response.append(inputLine + newLine);
            }

            in.close();

             return response.toString();
        }
        catch (Exception e)
        {
            e.printStackTrace();
            return null;
        }
    }
%>

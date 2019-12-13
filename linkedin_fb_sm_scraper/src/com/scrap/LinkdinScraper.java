package com.scrap;
import com.jaunt.UserAgent;
import org.jsoup.Connection;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;
import java.util.Date;

public class LinkdinScraper {
    public static void main(String[] args) {
        try {
            String urlString = "https://linkedin.com/in/sudipta-bhaumik-53a062a8";
            System.out.println("****1. readUrl****");
            readUrl(urlString);
            System.out.println("****2. scrapLIN_jsoup****");
            scrapLIN_jsoup(urlString);
            System.out.println("****3. scrapLIN_URL****");
            scrapLIN_URL(urlString);
        } catch (Exception e){
            e.printStackTrace();
            System.out.println(new Date() + "" + e.getMessage());
        }
    }

    public static void readUrl(String urlString) {
        UserAgent userAgent = new UserAgent();

        try {
            userAgent.visit(urlString);

            System.out.println(userAgent.doc.innerHTML());
        } catch(Exception e){
            e.printStackTrace();
        }
    }

    public static void scrapLIN_jsoup(String urlString) {
        try {
            Document document = null;
            Connection.Response response = Jsoup
                    .connect(urlString)
//                    .userAgent("Mozilla/5.0 (Windows NT 6.1; WOW64; rv:5.0) Gecko/20100101 Firefox/5.0")
//                    .userAgent("Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3")
                    .userAgent("Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36")
                    .method(Connection.Method.GET)
                    .execute();

            document =  Jsoup
                    .connect(urlString)
//                    .userAgent("Mozilla/5.0 (Windows NT 6.1; WOW64; rv:5.0) Gecko/20100101 Firefox/5.0")
//                    .userAgent("Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3")
                    .userAgent("Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36")
                    .timeout(1000*5) //it's in milliseconds, so this means 5 seconds.
                    .get();

//            Document document = response.parse();

            System.out.println(document);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void scrapLIN_URL(String urlString) {
        try {
            URL urlObj = new URL(urlString);
            URLConnection con = urlObj.openConnection();

            con.setDoOutput(true); // we want the response
//                con.setRequestProperty("User-Agent", "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9.2.2) Gecko/20100316 Firefox/3.6.2");
//                con.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36");
//                con.setRequestProperty("User-Agent", "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0");
//                con.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36");
            con.setRequestProperty("User-agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36");
            con.setRequestProperty("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
            con.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
            con.setRequestProperty("Accept-Encoding", "gzip, deflate, br");
            con.setRequestProperty("Connection", "keep-alive");
            con.setRequestProperty("Host", "www.linkedin.com");
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

            System.out.println(response.toString());
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }
}

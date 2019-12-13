package com.es;

import java.io.*;
import java.net.URL;

/**
 * Created by ds-i7-2 on 9/30/2016.
 */

public class ReadURL {
    public static void main(String args[]) {
        String url_str = "http://docs.oracle.com/javase/tutorial/networking/urls/readingURL.html";
        String file_path = "F:\\satya_code\\elasticsearch-2.4.0\\tryouts\\es_profile_2.txt";

        String clusterIdFromURL = getClusterIdFromURL(url_str);
        System.out.println("clusterIdFromURL: "+clusterIdFromURL);

        String clusterIdFromFS = getClusterIdFromFS(file_path);
        System.out.println("clusterIdFromFS: "+clusterIdFromFS);
    }

    static String getClusterIdFromURL(String url_str) {
        String clusterId = null;

        try {
            URL oracle = new URL(url_str);
            BufferedReader in = new BufferedReader(
                    new InputStreamReader(oracle.openStream()));

            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                clusterId = inputLine;
            }
            in.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return clusterId;
    }

    static String getClusterIdFromFS(String file_path) {
        String clusterId = null;

        try {
            InputStream inputStream = new FileInputStream(file_path);
            BufferedReader in = new BufferedReader(
                    new InputStreamReader(inputStream));

            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                clusterId = inputLine;
            }
            in.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return clusterId;
    }
}

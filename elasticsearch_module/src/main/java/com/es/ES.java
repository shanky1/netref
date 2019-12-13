package com.es;

import java.io.*;
import java.net.InetAddress;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;
import java.util.concurrent.ExecutionException;

import org.elasticsearch.action.admin.indices.create.CreateIndexResponse;
import org.elasticsearch.action.admin.indices.delete.DeleteIndexRequest;
import org.elasticsearch.action.admin.indices.delete.DeleteIndexResponse;
import org.elasticsearch.action.admin.indices.mapping.put.PutMappingResponse;
import org.elasticsearch.action.bulk.BulkResponse;
import org.elasticsearch.action.index.IndexRequest.OpType;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.Client;
import org.elasticsearch.client.transport.TransportClient;
import org.elasticsearch.common.io.stream.OutputStreamStreamOutput;
import org.elasticsearch.common.transport.InetSocketTransportAddress;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.SearchHits;
import org.elasticsearch.search.sort.SortBuilders;
import org.elasticsearch.search.sort.SortOrder;

public class ES {

    private static final String index = "website";
    private static final String type = "blog";
    static String dir_path = "F:\\satya_code\\es_java_maven\\es_chrome_plugin\\profiles_extracted";

    @SuppressWarnings({ "resource" })
    public static void main(String[] args) throws InterruptedException, ExecutionException {
        Client client = null;
        try {
            client = TransportClient.builder().build()
                    .addTransportAddress(new InetSocketTransportAddress(InetAddress.getByName("localhost"), 9300));

//            recreateIndex(client);

//            doIndex(client);
//            doIndexFromFiles(client);

//            searchAll(client);
//            Thread.sleep(5000 * 1);
//            searchAll(client);

//            searchProps(client);

            searchKeyWord(client, "construtora");
//            searchHightlight(client);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (client != null) {
                client.close();
            }
        }
    }

    private static void recreateIndex(Client client) throws InterruptedException, ExecutionException, IOException {
        if (client.admin().indices().prepareExists(index).execute().actionGet().isExists()) {
            DeleteIndexResponse deleteIndexResponse = client.admin()
                    .indices()
                    .delete(new DeleteIndexRequest(index))
                    .actionGet();
//            System.out.println("delete index : " + deleteIndexResponse);
        }

        CreateIndexResponse createIndexResponse = client.admin()
                .indices()
                .prepareCreate(index)
                .execute()
                .actionGet();
//        System.out.println("create index : " + createIndexResponse);

/*
        String mappingJsonStr = "" +
                "{" +
                "    \"dynamic_templates\": {" +
                "        \"props_tpl\" : {" +
                "            \"path_match\":\"props.*\"," +
                "            \"mapping\": {" +
                "                \"type\": \"{dynamic_type}\"," +
                "                \"index\": \"{not_analyzed}\"" +
                "            }" +
                "        }" +
                "    }," +
                "    \"properties\": {" +
                "        \"title\" : {" +
                "            \"type\":\"string\"," +
                "            \"index\": \"analyzed\"," +
                "            \"analyzer\": \"standard\"" +
                "        }," +
                "        \"origin\" : {" +
                "            \"type\":\"string\"," +
                "            \"index\": \"analyzed\"," +
                "            \"analyzer\": \"standard\"" +
                "        }," +
                "        \"description\" : {" +
                "            \"type\":\"string\"," +
                "            \"index\": \"analyzed\"," +
                "            \"analyzer\": \"standard\"" +
                "        }," +
                "        \"sales_count\" : {" +
                "            \"type\":\"long\"" +
                "        }," +
                "        \"price\" : {" +
                "            \"type\":\"long\"" +
                "        }" +
                "    }" +
                "}";
        PutMappingResponse putMappingResponse = client.admin()
                .indices()
                .preparePutMapping(index)
                .setType(index)
                .setSource(mappingJsonStr)
                .execute()
                .actionGet();
        System.out.println("create mapping : " + putMappingResponse);
        putMappingResponse.writeTo(new OutputStreamStreamOutput(System.out));
*/
    }

    @SuppressWarnings({ "rawtypes", "unchecked" })
    private static void doIndexFromFiles(final Client client) {
        File folder = null;

        try {
            folder = new File(dir_path);

            for (final File fileEntry : folder.listFiles()) {
                if (fileEntry.isDirectory()) {
                    //skip sub folder
                } else {
                    String file_path = fileEntry.getAbsolutePath();

                    if(!file_path.endsWith(".txt")) {
                        continue;
                    }

                    System.out.println(file_path);

                    String str = null;

                    try {
                        str = new String(Files.readAllBytes(Paths.get(file_path)));

                        Map s_str = new LinkedHashMap();
                        s_str.put("about", str);

                        BulkResponse bulkResponse = client.prepareBulk()
                                .add(client.prepareIndex(index, type).setSource(s_str).setOpType(OpType.INDEX).request())
                                .execute()
                                .actionGet();

                        if (bulkResponse.hasFailures()) {
                            System.err.println("index docs [ERROR] : " + bulkResponse.buildFailureMessage());
                        } else {
                            System.out.println("index docs : " + bulkResponse);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void doIndex(final Client client) {
        Map s11 = new LinkedHashMap();
        s11.put("title", "MISSHA1");
        s11.put("origin", "Bangalore");
        s11.put("description", "Desc1");
        s11.put("sales_count", 748);
        s11.put("price", 9680);
/*
        Map props = new LinkedHashMap();
        props.put("??", "150*200cm");
        props.put("??", "??");
        s11.put("props", props);
*/

        Map s12 = new LinkedHashMap();
        s12.put("title", "MISSHA2");
        s12.put("origin", "Mysore");
        s12.put("description", "Desc2");
        s12.put("sales_count", 666);
        s12.put("price", 1080);
/*
        props = new LinkedHashMap();
        props.put("??", "170*220cm");
        props.put("??", "??");
        s12.put("props", props);
*/

        Map s21 = new LinkedHashMap();
        s21.put("title", "MISSHA3");
        s21.put("origin", "Bellary");
        s21.put("description", "Desc3");
        s21.put("sales_count", 666);
        s21.put("price", 990);
/*
        props = new LinkedHashMap();
        props.put("??", "180*200cm");
        props.put("??", "??");
        s21.put("props", props);
*/

        Map s22 = new LinkedHashMap();
        s22.put("title", "MISSHA4");
        s22.put("origin", "Mangalore");
        s22.put("description", "Desc4");
        s22.put("sales_count", 777);
        s22.put("price", 8800);
/*
        props = new LinkedHashMap();
        props.put("??", "200*220cm");
        props.put("??", "??");
        s22.put("props", props);
*/

        BulkResponse bulkResponse = client.prepareBulk()
                .add(client.prepareIndex(index, type).setId("11").setSource(s11).setOpType(OpType.INDEX).request())
                .add(client.prepareIndex(index, type).setId("12").setSource(s12).setOpType(OpType.INDEX).request())
                .add(client.prepareIndex(index, type).setId("21").setSource(s21).setOpType(OpType.INDEX).request())
                .add(client.prepareIndex(index, type).setId("22").setSource(s22).setOpType(OpType.INDEX).request())
                .execute()
                .actionGet();

        if (bulkResponse.hasFailures()) {
            System.err.println("index docs [ERROR] : " + bulkResponse.buildFailureMessage());
        } else {
            System.out.println("index docs : " + bulkResponse);
        }

    }

    private static void searchAll(Client client) {
        SearchResponse response = client.prepareSearch(index)
                .setQuery(QueryBuilders.matchAllQuery())
                .setSize(100)
                .setExplain(true)
                .execute()
                .actionGet();

        System.out.println(new java.util.Date()+"\t searchAll : " + response);
        System.out.println("--------------------------");
    }

    static List <String> list = new ArrayList<String>();

    static {
        list.add("srikanth gv");
        list.add("sridhar js");
        list.add("ajay ds");
        list.add("pankaj verma");
        list.add("aravind kj");
        list.add("Kuldeep Singh");
        list.add("Marcelo");
        list.add("Venecia A Thomas");
    }

    private static void searchKeyWord(Client client, String keyword) {
        SearchResponse response = client.prepareSearch(index)
                .setQuery(QueryBuilders.matchQuery("_all", keyword))
                .execute()
                .actionGet();

/*        References
*        http://elasticsearch-users.115913.n3.nabble.com/Iterator-over-whole-result-set-Java-API-td1072855.html
*        http://www.javased.com/index.php?api=org.elasticsearch.search.SearchHit
*/

        SearchHits hits = response.getHits();

        Iterator<SearchHit> hits_itr = hits.iterator();
        HashMap<String, Object> hm = new HashMap<String, Object>();

        int cnt = 0;

        while (hits_itr.hasNext()) {
            cnt++;
            SearchHit searchHit = hits_itr.next();

            Map<String, Object> map = searchHit.getSource();
            String map_id = searchHit.getId();

            System.out.println("----" + (cnt) + "----\n");

            for (Map.Entry<String, Object> entry : map.entrySet()) {
//                String key = entry.getKey();                          //NOT used for now
                Object value = entry.getValue();

                for (String contact_name : list) {
                    System.out.println("contact_name: "+contact_name);
//                    String[] contact_name_split = contact_name.split(" ");

//                    for (String contact_name_temp : contact_name_split) {
//                        System.out.println("contact_name_temp: "+contact_name_temp);
                    if(value.toString().toLowerCase().contains(contact_name.toLowerCase())) {
                        if(!hm.containsKey(map_id)) {
                            hm.put(map_id, value);
                        }
                    }
//                    }
                }
            }
            System.out.println(hm);
        }
    }

/*
    private static void searchRange(Client client) {

        SearchResponse response = client.prepareSearch(index)
                .setQuery(QueryBuilders.filteredQuery(
                        QueryBuilders.matchAllQuery(),
                        FilterBuilders.rangeFilter("price").gte(1200)))
                .execute()
                .actionGet();

        System.out.println("searchRange: " + response);
    }
*/

    private static void searchOrdered(Client client) {

        SearchResponse response = client.prepareSearch(index)
                .setQuery(QueryBuilders.matchAllQuery())
                .addSort(SortBuilders.fieldSort("sales_count").order(SortOrder.DESC))
                .addSort(SortBuilders.fieldSort("price"))
                .execute()
                .actionGet();

        System.out.println("searchOrdered: " + response);
    }

    private static void searchHightlight(Client client) {

        SearchResponse response = client.prepareSearch(index)
                .setQuery(QueryBuilders.matchQuery("_all", "Bangalore"))
                .addHighlightedField("title")
                .addHighlightedField("origin")
                .execute()
                .actionGet();

        System.out.println(new Date()+"\t searchHightlight : " + response);
        System.out.println("--------------------------");
    }

    private static void searchProps(Client client) {

        SearchResponse response = client.prepareSearch(index)
//                .setQuery(QueryBuilders.matchQuery("??", "??"))
//                .setQuery(QueryBuilders.termQuery("employer", "devsqua"))
                .setQuery(QueryBuilders.matchQuery("employer", "devsquare"))
//                .setQuery(QueryBuilders.matchQuery("_all", "??"))
//                .setQuery(QueryBuilders.matchQuery("props.??", "??"))
                .setExplain(true)
                .addHighlightedField("*")
                .execute()
                .actionGet();

        System.out.println(new Date()+"\t searchProps : " + response);
        System.out.println("--------------------------");
    }
}

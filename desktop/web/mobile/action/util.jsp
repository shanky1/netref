<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.restfb.types.User" %>
<%@ page import="java.text.ParseException" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.twilio.sdk.TwilioRestClient" %>
<%@ page import="com.twilio.sdk.resource.instance.Account" %>
<%@ page import="com.twilio.sdk.resource.instance.Message" %>
<%@ page import="com.twilio.sdk.resource.factory.MessageFactory" %>
<%@ page import="org.apache.http.NameValuePair" %>
<%@ page import="org.apache.http.message.BasicNameValuePair" %>
<%@ page import="com.twilio.sdk.TwilioRestException" %>
<%@ page import="com.sun.org.apache.xml.internal.security.utils.Base64" %>
<%@ include file="db.jsp"%>
<%@ include file="log.jsp"%>
<%@ include file="dec_enc.jsp"%>

<%!
    SimpleDateFormat DAY_MONTH_FORMATTER = new SimpleDateFormat("EEE, MMM d");
    static ArrayList<String[]> contactList_Util;
    static int SET_CONTACTS_INITIAL_LOADING_LIMIT = 10;
    static int SK_USER_ID = 227;
    static String CONTACT_IMAGE_PATH = "D:\\netref\\web\\mobile\\user_contact_images";
    static String PROFILE_IMAGE_PATH = "D:\\netref\\web\\mobile\\profile_images";
    static String server_type = "test";
    static String test_mobile_number = "+919901424531";
    static String test_user_id = "163";

    static HashMap iOSContactList;

    final String sql_getAllFLofFriends = "SELECT rs.to_user_id, rs.to_contact_name, profession, expertise, experience, linkedin " +
            "    FROM relationship rs LEFT JOIN skills s " +
            "    ON rs.to_user_id = s.user_id " +
            "    where rs.from_user_id = ? and rs.advanced_relation_type = 3"; //filtered @devsqure.com id not to display real id's

    public String showFLList(String friend_userid) {
        Connection con = null;
        PreparedStatement getFLList = null;
        ResultSet rs = null;
        String course_list = "";

        String freelancer_name = null;
        String freelancer_email = null;
        String profession = null;
        String expertise = null;
        String experience =  null;
        String linkedin = null;
        String fl_userid = null;
        String tr = null;

        try {
            con = getConnection();
            getFLList = getPs(con, sql_getAllFLofFriends);
            getFLList.setString(1, friend_userid);

            rs = getFLList.executeQuery();

            if(rs != null){
                while (rs.next()) {
                    profession = rs.getString("profession");
                    expertise = rs.getString("expertise");
                    experience = rs.getString("experience");
                    linkedin = rs.getString("linkedin");
                    fl_userid = rs.getString("to_user_id");

                    try {
                        byte[] freelancer_name_enc = rs.getBytes("to_contact_name");

//                        byte[] freelancer_email_ba = processDecrypt(freelancer_email_enc);
                        byte[] freelancer_name_ba = processDecrypt(freelancer_name_enc);

//                        freelancer_email = new String(freelancer_email_ba);
                        freelancer_name = new String(freelancer_name_ba);

                        tr = getFlListString(friend_userid, fl_userid, freelancer_name, freelancer_email, profession, expertise, experience, linkedin);

                        course_list += tr;
                    } catch(Exception e) {
                        System.out.println(new Date()+"\t "+e.getMessage());
                        e.printStackTrace();
                    }
                }
                return course_list;
            } else {
                course_list = "0";
                return course_list;
            }

        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return "An error occurred while getting freelancer list. Please try again.";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    final String sql_getdatetime = "select * from activities where activity_id = ? and category = \"asks\" and status = 1 ";
    final String sql_getdatetimeactivities = "select * from activities where activity_id = ?";
    final String sql_getDateTimeActivityResponse = "select * from activities_responses where activity_id = ?";

    final String sql_getAskResponsesList = "select u.email, u.name, u.fb_photo_path, ar.activity_id, ar.comments, ar.recommended_on from activities_responses ar, users u where ar.recommended_by = u.user_id and ar.activity_id = ? order by ar.recommended_on DESC";

    final String sql_checkAskResponse = "select * from activities_responses where activity_id = ? and recommended_by = ?";
    final String sql_checkNotifications = "select * from notifications where from_user_id = ? and to_user_id = ?";
    final String sql_postAskResponse = "insert into activities_responses (activity_id, fl_userid, recommended_by, comments) values (?, ?, ?, ?)";
    final String sql_postNotifications = "insert into notifications (from_user_id, to_user_id) values (?, ?)";
    final String sql_updateAskResponse = "update activities_responses set comments = ? where activity_id = ? and fl_userid = ? and recommended_by = ?";
    final String sql_updateNotifications = "update notifications set to_user_id = ?  and to_user_id = ? where from_user_id = ? and to_user_id = ?";

    final String sql_getFLSkills = "select * from skills where user_id = ?";
    final String sql_checkFLSkills = "select * from skills where user_id = ?";
    final String sql_insertFLSkills = "insert into skills (profession, expertise, experience, linkedin, about, location, user_id) values (?, ?, ?, ?, ?, ?, ?)";
    final String sql_updateFLSkills = "update skills set profession = ?, expertise = ?,experience = ?, linkedin = ?, about = ?, location=? where user_id = ?";
    final String sql_postCommentsInNetwork = "insert into activities (posted_by, fl_userid, category, comments) values (?, ?, ?, ?)";

    final String sql_checkBroadcastInNetwork = "select * from activities_broadcast where broadcasted_by = ? and activity_id = ? and owner_id = ?";
    final String sql_postBroadcastInNetwork = "insert into activities_broadcast (broadcasted_by, activity_id, owner_id) values (?, ?, ?)";

    public String getSearchResults(String search_by, String search_value, String user_id) {     //TODO, remove this. NOT used this function now. implemented it in javascript search only
        String fl_userid = "";
        String fl_email = "";
        String profession = "";
        String expertise = "";
        String experience = "";
        String linkedin = "";
        String fb_photo_path = "";
        String fb_user_id = "";
        String fl_name = "";

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        search_value = search_value.replaceAll(","," ");

        String search_str = "";

        if(search_value != null && search_value.trim().length() > 0) {
            String[] search_value_arr = search_value.split(" ");

            for (int i = 0; i < search_value_arr.length; i++) {
                if(i == search_value_arr.length - 1) {
                    search_str += search_by+" like '%"+search_value_arr[i].trim()+"%'";
                } else {
                    search_str += search_by+" like '%"+search_value_arr[i].trim()+"%' or ";
                }
            }
        }

        String friendUserIds = "";
        int cnt = 0;

        try {
            con = getConnection();

            final String sql_getFriendsUserIds = "select to_user_id from relationship where from_user_id = "+user_id+" and advanced_relation_type = 1";

            ps = getPs(con, sql_getFriendsUserIds);
            rs = ps.executeQuery();

            while (rs.next()) {
                String to_user_id = rs.getString("to_user_id");
                if(cnt == 0) {
                    friendUserIds += to_user_id;
                } else {
                    friendUserIds += ", "+to_user_id;
                }
                cnt++;
            }

            if(cnt == 0) {
                friendUserIds = "NULL";
            }

//  displays logged in user fl's and friend's fl's

            String sql_searchFLs = "select t2.profession, t2.expertise, t2.experience, t2.linkedin, t2.from_user_id, t2.to_user_id, t2.advanced_relation_type, t2.email, t2.user_id, t2.fb_photo_path, t2.fb_user_id, t2.name from " +
                    "( "+
                    "select s.profession, s.expertise, s.experience, s.linkedin, r.from_user_id, r.to_user_id, r.advanced_relation_type, u.email, u.user_id, u.fb_photo_path, u.fb_user_id, r.to_contact_name as name "+
                    "from users u, relationship r left join skills s " +
                    "on s.user_id = r.to_user_id "+(search_str.trim().length() > 0 ? "and ("+search_str+")" : " ")+" where r.advanced_relation_type = 3 and u.user_id = r.to_user_id and r.from_user_id = ? "+(search_str.trim().length() > 0 ? "and ("+search_str+")" : " ")+
                    "UNION "+
                    "select s.profession, s.expertise, s.experience, s.linkedin, r.from_user_id, r.to_user_id, r.advanced_relation_type, u.email, u.user_id, u.fb_photo_path, u.fb_user_id, r.to_contact_name as name "+
                    "from users u, relationship r left join skills s " +
                    "on s.user_id = r.to_user_id "+(search_str.trim().length() > 0 ? "and ("+search_str+")" : " ")+" where r.from_user_id in ("+friendUserIds+") and u.user_id = r.to_user_id and r.advanced_relation_type = 3 "+(search_str.trim().length() > 0 ? "and ("+search_str+")" : " ")+
                    "UNION "+
                    "select s.profession, s.expertise, s.experience, s.linkedin, r.from_user_id, r.to_user_id, r.advanced_relation_type, u.email, u.user_id, u.fb_photo_path, u.fb_user_id, r.to_contact_name as name "+
                    "from skills s, relationship r, users u  " +
                    "where advanced_relation_type = 3 and u.user_id = r.to_user_id and r.from_user_id = "+SK_USER_ID+" and s.user_id = r.to_user_id "+(search_str.trim().length() > 0 ? "and ("+search_str+")" : " ")+
                    ") as t2 group by t2.to_user_id ";

            ps = getPs(con, sql_searchFLs);
            ps.setString(1, user_id);

            rs = ps.executeQuery();

            while(rs.next()) {
                fl_userid = rs.getString("user_id");
                fl_email = rs.getString("email");
                profession = rs.getString("profession");
                expertise = rs.getString("expertise");
                experience = rs.getString("experience");
                linkedin = rs.getString("linkedin");
                fb_photo_path = rs.getString("fb_photo_path");
                fb_user_id = rs.getString("fb_user_id");

                try {
                    byte[] fl_name_enc = rs.getBytes("name");
                    byte[] fl_name_ba = processDecrypt(fl_name_enc);
                    fl_name = new String(fl_name_ba);

                    msg += getSearchResultsString(fl_userid, fl_email, profession, expertise, experience, linkedin, fb_photo_path, fb_user_id, fl_name);
                } catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                    continue;
                }
            }
        } catch(Exception se) {
            System.err.println(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String loadActivities(String user_id) {
        String activity_id = "";
        String fl_userid = "";
        String fl_name = "";
        String category = "";
        String comments = "";
        String posted_by_photo = "";
        String posted_on = "";
        String posted_by = "";
        String owner_id = "";

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        String sql_loadActivities = "" +
                "select u.user_id, u.email, u.name, u.fb_photo_path, a.activity_id, a.fl_userid, a.category, a.comments, a.posted_on, a.posted_by, a.posted_by as owner_id " +
                "from relationship rs, users u, activities a " +
                "where rs.to_user_id = u.user_id and u.user_id = a.posted_by and rs.from_user_id = ? and a.status = 1 and rs.advanced_relation_type = 4 " +

                "union " +

                "select u.user_id, u.email, u.name, u.fb_photo_path, ab.activity_id, -1 as fl_userid, 'broadcast' as category, a.comments, ab.broadcasted_on, ab.broadcasted_by, ab.owner_id " +
                "from relationship rs, users u, activities_broadcast ab, activities a " +
                "where rs.to_user_id = u.user_id and u.user_id = ab.broadcasted_by and ab.activity_id = a.activity_id and rs.from_user_id = ? and a.status = 1 and rs.advanced_relation_type = 4 " +

                "order by posted_on DESC";

        try {
            con = getConnection();

            ps = getPs(con, sql_loadActivities);

            ps.setString(1, user_id);
            ps.setString(2, user_id);

            System.out.println(new Date()+"\t loadActivities -> ps: "+ps);

            rs = ps.executeQuery();

            Vector fl_list = getFLVectorList(con, user_id);

            while(rs.next()) {
                posted_by_photo = rs.getString("fb_photo_path");
                activity_id = rs.getString("activity_id");
                category = rs.getString("category");
                comments = rs.getString("comments");
                posted_on = rs.getString("posted_on");
                posted_by = rs.getString("posted_by");
                owner_id = rs.getString("posted_by");

                byte[] fl_name_enc = rs.getBytes("name");

                try {
                    byte[] fl_name_ba = processDecrypt(fl_name_enc);
                    fl_name = new String(fl_name_ba);
                } catch (Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                }

                if(category.equalsIgnoreCase("asks") || category.equalsIgnoreCase("broadcast")) {
                    msg += loadActivitiesAsksString(con, activity_id, posted_by_photo, fl_name, comments, posted_on, posted_by, owner_id, fl_list);
                }
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

//    final String sql_getFLVectorList = "select rs.to_user_id, rs.to_contact_name from users u, relationship rs where u.user_id = rs.to_user_id and rs.from_user_id = ? and rs.advanced_relation_type = 4 and active_status = 1";

    final String sql_getFLVectorList = "select rs.to_user_id, rs.to_contact_name, sk.profession from users u, relationship rs, skills sk " +
            "where u.user_id = rs.to_user_id and rs.to_user_id = sk.user_id and rs.from_user_id = ? and rs.advanced_relation_type = 4 and active_status = 1";

    public Vector getFLVectorList(Connection con, String userid) {
        PreparedStatement getFL = null;
        ResultSet rs = null;
        Vector fl_list = new Vector();

        try {
            getFL = getPs(con, sql_getFLVectorList);
            getFL.setString(1, userid);

            rs = getFL.executeQuery();

            while (rs.next()) {
                String to_user_id = rs.getString("to_user_id");
                byte[] to_contact_name_enc = rs.getBytes("to_contact_name");
                String profession = rs.getString("profession");

                try {
                    byte[] to_contact_name_ba = processDecrypt(to_contact_name_enc);
                    String to_contact_name = new String(to_contact_name_ba);

                    if(profession == null || profession.trim().length() <= 0) {
                        continue;
                    }

                    fl_list.add(to_user_id+"||"+to_contact_name);
                } catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                    continue;
                }
            }
            return fl_list;
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return fl_list;
        }
    }

    public ArrayList loadFriends_AL(String user_id) {
        String friend_userid = "";
        String friend_email = "";
        String friend_name = "";
        String friend_photo_path = "";

        String msg = "";
        ArrayList friend_list = new ArrayList();

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        String sql_loadFBFriends = "select u.user_id, rs.to_contact_name as friend_name, u.email, u.fb_photo_path " +
                "from users u, relationship rs where rs.to_user_id = u.user_id and rs.from_user_id = ? and rs.advanced_relation_type = 4 and active_status = 1" ;

        try {
            con = getConnection();
            ps = getPs(con, sql_loadFBFriends);
            ps.setString(1, user_id);
            rs = ps.executeQuery();

            while(rs.next()) {
                friend_userid = rs.getString("user_id");
                friend_photo_path = rs.getString("fb_photo_path");

                try {
                    byte[] friend_name_enc = rs.getBytes("friend_name");
                    byte[] friend_name_ba = processDecrypt(friend_name_enc);
                    friend_name = new String(friend_name_ba);

                    HashMap hm = new HashMap();
                    hm.put("friend_userid", friend_userid);
                    hm.put("friend_name", friend_name);
                    hm.put("friend_photo_path", friend_photo_path);

                    friend_list.add(hm);

//                    msg += loadFBFriendsString(con, friend_userid, friend_email, friend_name, friend_photo_path);
                } catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                    return friend_list;
                }
            }
        } catch(Exception se) {
            System.err.print(new Date()+"\t "+se.getMessage());
            return friend_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return friend_list;
    }

    public String loadSKFriend() {
        String friend_userid = "";
        String friend_email = "";
        String friend_name = "";
        String friend_photo_path = "";

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        String sql_loadskFriend = "select * from users where user_id = "+SK_USER_ID;

        try {
            con = getConnection();

            ps = getPs(con, sql_loadskFriend);
            rs = ps.executeQuery();

            while(rs.next()) {
                friend_userid = rs.getString("user_id");
                friend_photo_path = rs.getString("fb_photo_path");

                try {
                    friend_name = "SK";

                    msg += loadskFriendString(friend_userid, friend_email, friend_name, friend_photo_path);
                } catch(Exception e) {
//                    e.printStackTrace();
                    System.out.println(new Date() + "\t loadSKFriend -> " + e.getMessage());
                }
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public ArrayList loadFreelancers_AL(String from_user_id) {
        String profession = "";
        String expertise = "";
        String experience = "";
        String linkedin = "";
        String fb_photo_path = "";
        String fb_user_id = "";
        String fl_userid = "";
        String fl_name = "";
        Connection con = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        ResultSet rs = null;
        String course_list = "";
        String friendUserIds = "";
        int cnt = 0;
        ArrayList profession_list = new ArrayList();

        try {
            con = getConnection();

            final String sql_getFriendsUserIds = "select to_user_id from relationship where from_user_id = "+from_user_id+" and advanced_relation_type = 4 and active_status = 1";

            ps1 = getPs(con, sql_getFriendsUserIds);
            rs = ps1.executeQuery();

            while (rs.next()) {
                String to_user_id = rs.getString("to_user_id");
                if(cnt == 0) {
                    friendUserIds += to_user_id;
                } else {
                    friendUserIds += ", "+to_user_id;
                }
                cnt++;
            }

            if(cnt == 0) {
                friendUserIds = "NULL";
            }

            final String sql_loadfreelancers = "select t2.profession, t2.expertise,t2.experience, t2.linkedin, t2.from_user_id, t2.to_user_id, t2.advanced_relation_type, t2.email, t2.user_id, t2.fb_photo_path, t2.fb_user_id, t2.to_contact_name from " +
                    "( " +

//            My Professionals

                    "SELECT s.profession, s.expertise, s.experience, s.linkedin, rs.from_user_id, rs.to_user_id, rs.advanced_relation_type, u.email, u.user_id, u.fb_photo_path, u.fb_user_id, rs.to_contact_name " +
                    "FROM users u LEFT JOIN skills s " +
                    "ON u.user_id = s.user_id " +
                    "JOIN relationship rs " +
                    "where u.user_id = rs.to_user_id and rs.advanced_relation_type = 4 and (rs.from_user_id = "+from_user_id+" OR rs.from_user_id = "+SK_USER_ID+") and active_status = 1 GROUP BY rs.to_user_id " +

                    " UNION " +

//          Plus  My friend's' Professionals

                    "SELECT s.profession, s.expertise, s.experience, s.linkedin, rs.from_user_id, rs.to_user_id, rs.advanced_relation_type, u.email, u.user_id, u.fb_photo_path, u.fb_user_id, rs.to_contact_name " +
                    "FROM users u LEFT JOIN skills s " +
                    "ON u.user_id = s.user_id " +
                    "JOIN relationship rs " +
                    "where rs.from_user_id in ("+friendUserIds+") and u.user_id = rs.to_user_id and rs.advanced_relation_type = 4 and active_status = 1 GROUP BY rs.to_user_id " +
                    ") " +
                    "as t2 group by t2.to_user_id ";

            ps2 = getPs(con, sql_loadfreelancers);

            rs = ps2.executeQuery();

            while (rs.next()) {
                profession = rs.getString("profession");
                expertise = rs.getString("expertise");
                experience = rs.getString("experience");
                linkedin = rs.getString("linkedin");
                fb_photo_path = rs.getString("fb_photo_path");
                fb_user_id = rs.getString("fb_user_id");
                fl_userid = rs.getString("user_id");

                try {
                    byte[] fl_name_enc = rs.getBytes("to_contact_name");
                    byte[] fl_name_ba = processDecrypt(fl_name_enc);
                    fl_name = new String(fl_name_ba);

                    profession = profession != null ? profession : "";
                    expertise = expertise != null ? expertise : "";
                    experience = experience != null ? experience : "";
                    linkedin = linkedin != null ? linkedin : "";
                    fb_photo_path = fb_photo_path != null ? fb_photo_path : "";
                    fb_user_id = fb_user_id != null ? fb_user_id : "";

                    if(profession.trim().length() <= 0) {
                        continue;
                    }

                    HashMap hm = new HashMap();
                    hm.put("fl_userid", fl_userid);
                    hm.put("fl_name", fl_name);
                    hm.put("profession", profession);
                    hm.put("expertise", expertise);
                    hm.put("experience", experience);
                    hm.put("linkedin", linkedin);
                    hm.put("fb_photo_path", fb_photo_path);
                    hm.put("fb_user_id", fb_user_id);

                    profession_list.add(hm);
                } catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                    continue;
                }
            }

        return profession_list;
    } catch (Exception e) {
        System.out.println(new Date()+"\t "+e.getMessage());
        e.printStackTrace();
        return null;
    } finally {
        if(con != null ) {
            closeConnection(con);
        }
    }
}
    final String sql_load_notifications = "select * from users a, notifications b where b.from_user_id = a.user_id and b.to_user_id = ?";
    public ArrayList notifications_AL(String to_user_id) {
        String fl_name = "";
        String fl_phone = "";
        String fb_photo_path = "";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String course_list = "";
        String friendUserIds = "";
        int cnt = 0;
        ArrayList notification_list = new ArrayList();

        try {
            con = getConnection();
            ps = getPs(con, sql_load_notifications);
            ps.setString(1, to_user_id);
            rs = ps.executeQuery();
            while (rs.next()) {
                fb_photo_path = rs.getString("fb_photo_path");
                try {
                    byte[] fl_name_enc = rs.getBytes("name");
                    byte[] fl_name_ba = processDecrypt(fl_name_enc);
                    fl_name = new String(fl_name_ba);

                    byte[] fl_phone_enc = rs.getBytes("mobile");
                    byte[] fl_phone_ba = processDecrypt(fl_phone_enc);
                    fl_phone = new String(fl_phone_ba);
                    System.out.println(fl_name);
                    HashMap hm = new HashMap();
                    hm.put("fl_phone", fl_phone);
                    hm.put("fl_name", fl_name);
                    hm.put("fb_photo_path", fb_photo_path);


                    notification_list.add(hm);
                } catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                    continue;
                }
            }

            return notification_list;
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String loadAskList(String user_id) {
        String activity_id = "";
        String comments = "";
        String posted_on = "";
        String posted_by_photo = "";
        String posted_by = "";
        String name = "";
        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        String sql_loadAskList = "select * from activities a,users u where posted_by = ? and a.posted_by= u.user_id and category = \"asks\" and status = 1 order by posted_on DESC";

        try {
            con = getConnection();

            ps = getPs(con, sql_loadAskList);
            ps.setString(1, user_id);
            rs = ps.executeQuery();

            while(rs.next()) {
                activity_id = rs.getString("activity_id");
                comments = rs.getString("comments");
                posted_on = rs.getString("posted_on");
                posted_by_photo = rs.getString("fb_photo_path");
                byte[] name_enc = rs.getBytes("name");
                posted_by = rs.getString("posted_by");

                try {
                    byte[] name_ba = processDecrypt(name_enc);

                    name = new String(name_ba);

                    msg += loadAskListString(con, user_id, activity_id, comments, posted_on, posted_by_photo, name, posted_by);
                } catch (Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                }
            }
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String loadReminders(String from_user_id) {
        String from_name = "";
        String to_name = "";
        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        //get the records for whom invitations are already sent but not registered yet
        String sql_loadReminders = "select ui.* from user_invitations ui, users u where ui.to_userid = u.user_id and u.registered = 0 and ui.from_userid = ? and ui.invitation_status = 1";

        try {
            con = getConnection();

            ps = getPs(con, sql_loadReminders);
            ps.setString(1, from_user_id);
            rs = ps.executeQuery();

            while(rs.next()) {
                byte[] from_name_enc = rs.getBytes("from_name");
                byte[] to_name_enc = rs.getBytes("to_name");
                String to_userid = rs.getString("to_userid");
                String connection = rs.getString("connection");
                String invitation_sent_time = rs.getString("invitation_sent_time");

                try {
                    byte[] from_name_ba = processDecrypt(from_name_enc);

                    from_name = new String(from_name_ba);
                } catch (Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                }
                try {
                    byte[] to_name_ba = processDecrypt(to_name_enc);

                    to_name = new String(to_name_ba);
                } catch (Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                }

                if(from_name != null && from_name.trim().length() > 0) {
                    msg += loadRemindersString(from_user_id, from_name, to_userid, to_name, invitation_sent_time, connection);
                }
            }
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.println(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    //    final String sql_getProfileDetails = "select u.name as profile_name, u.profile_image_file_name, s.* from users u, skills s where u.user_id = s.user_id and s.user_id = ?";
    final String sql_getProfileDetails = "SELECT u.name as profile_name, u.profile_image_file_name, u.businessdetails_image_file_name, s.* " +
            "            FROM users u LEFT JOIN skills s " +
            "            ON u.user_id = s.user_id " +
            "            where u.user_id = ?";

    public ArrayList getProfileDetails_AL(String from_user_id) {
        String profile_name = "";
        String profile_image_file_name = "";
        String businessdetails_image_file_name = "";
        String profile_profession = "";
        String profile_expertise = "";
        String profile_experience = "";
        String profile_linkedin = "";
        String profile_location = "";
        String profile_about = "";

        ArrayList profile_details = new ArrayList();

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_getProfileDetails);
            ps.setString(1, from_user_id);
            rs = ps.executeQuery();

            if (rs.next()) {
                profile_image_file_name = rs.getString("profile_image_file_name");
                businessdetails_image_file_name = rs.getString("businessdetails_image_file_name");
                profile_profession = rs.getString("profession");
                profile_expertise = rs.getString("expertise");
                profile_experience = rs.getString("experience");
                profile_linkedin = rs.getString("linkedin");
                profile_location = rs.getString("location");
                profile_about = rs.getString("about");

                try {
                    byte[] profile_name_enc = rs.getBytes("profile_name");
                    byte[] profile_name_ba = processDecrypt(profile_name_enc);
                    profile_name = new String(profile_name_ba);
                }  catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
//                    e.printStackTrace();
                }

                try {
                    profile_name = profile_name != null ? profile_name : "";
                    profile_profession = profile_profession != null ? profile_profession : "";
                    profile_experience = profile_experience != null ? profile_experience : "";
                    profile_linkedin = profile_linkedin != null ? profile_linkedin : "";
                    profile_location = profile_location != null ? profile_location : "";
                    profile_about = profile_about != null ? profile_about : "";

                    HashMap hm = new HashMap();
                    hm.put("from_user_id", from_user_id);
                    profile_image_file_name = getprofileimagestatus(from_user_id, profile_image_file_name);
                    hm.put("profile_image_file_name", profile_image_file_name);
                    businessdetails_image_file_name = getprofileimagestatus(from_user_id, businessdetails_image_file_name);
                    hm.put("businessdetails_image_file_name", businessdetails_image_file_name);
                    hm.put("profile_name", profile_name);
                    hm.put("profile_profession", profile_profession);
                    hm.put("profile_expertise", profile_expertise);
                    hm.put("profile_experience", profile_experience);
                    hm.put("profile_linkedin", profile_linkedin);
                    hm.put("profile_location", profile_location);
                    hm.put("profile_about", profile_about);

                    profile_details.add(hm);
                } catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                }
            }
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.print(new Date()+"\t "+se.getMessage());
            return profile_details;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return profile_details;
    }

    public String getFLskills(String user_id, String from) {
        String profession = "";
        String expertise = "";
        String experience = "";
        String linkedin = "";

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_getFLSkills);
            ps.setString(1, user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                profession = rs.getString("profession");
                expertise = rs.getString("expertise");
                experience = rs.getString("experience");
                linkedin = rs.getString("linkedin");
            }

            profession = profession != null ? profession : "";
            expertise = expertise != null ? expertise : "";
            experience = experience != null ? experience : "";
            linkedin = linkedin != null ? linkedin : "";

            msg = getSkillsForm(profession, expertise, experience, linkedin, from);
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.print(new Date()+"\t "+se.getMessage());
            return msg;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String getSkillsForm(String profession, String expertise, String experience, String linkedin, String from) {

        String ret = " <div class='row' style='margin-bottom:12px;'>" +
                "                        <div class='col-xs-4 pull-left' align='left'>" +
                "                            <h5 for='title' class='pull-right' style='font-size:15px;margin-top:10px'>Profession:</h5></div>" +
                "                        <div class='col-xs-7' style='margin-left:1%'>" +
                "                            <input type='text' class='form-control' style='max-width: 300px' id='profession' name='profession' value='"+profession+"'>" +
                "                        </div>" +
                "                    </div>" +
                "                    </div>"  +
                "                     <div class='row' style='margin-bottom:12px;'>" +
                "                         <div class='col-xs-4 pull-left' align='left'>" +
                "                              <h5 for='title' class='pull-right' style='font-size:15px;margin-top:10px'>Expertise:</h5></div>" +
                "                          <div class='col-xs-7' style='margin-left:1%'>" +
                "                              <input type='text' class='form-control' style='max-width: 300px' id='expertise' name='expertise' value='"+expertise+"'>" +
                "                            </div>" +
                "                     </div>" +
                "                     <div class='row' style='margin-bottom:12px;'>" +
                "                         <div class='col-xs-4 pull-left' align='left'>" +
                "                              <h5 for='title' class='pull-right' style='font-size:15px;margin-top:10px'>Experience:</h5></div>" +
                "                          <div class='col-xs-7' style='margin-left:1%'>" +
                "                              <input type='text' class='form-control' style='max-width: 300px' id='experience' name='experience' value='"+experience+"'>" +
                "                            </div>" +
                "                     </div>" +
                "                   <div class='row' style='margin-bottom:12px;'>" +
                "                        <div class='col-xs-4 pull-left' align='left'>" +
                "                            <h5 for='title' class='pull-right' style='font-size:15px;margin-top:10px'>LinkedIn:</h5></div>" +
                "                        <div class='col-xs-7' style='margin-left:1%'>" +
                "                            <input type='text' class='form-control' style='max-width: 300px' id='linkedin' name='linkedin' value='"+linkedin+"'>" +
                "                        </div>" +
                "                    </div>" +
                "                    <div id='add_skills_form_status' align='center'></div>" +
                "                    <div class='modal-footer' style='padding-top: 0px;'>" +
                "                        <center>" +
                "                           <button class='btn btn-info' style='background-color:#2C93FF;' type='submit' onclick='saveProfessionDetails(\""+from+"\");'>Add</button>&nbsp;&nbsp;" +
                "                           <button class='btn btn-secondary active' data-toggle='button' data-dismiss='modal'>Cancel</button>" +
                "                        </center>" +
                "                    </div>" +
                "                    <input type='hidden' name='user_id' class='form-control' id='user_id' value='0'>";

        return ret;
    }

    final String sql_getProfileName = "select * from users where user_id = ?";

    public String getProfileName(String user_id) {
        String profile_name = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_getProfileName);
            ps.setString(1, user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                byte[] profile_name_enc = rs.getBytes("name");

                byte[] profile_name_ba = processDecrypt(profile_name_enc);

                profile_name = new String(profile_name_ba);
            }

            return profile_name;

        } catch(Exception se) {
            return profile_name;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String checkProfileName(String user_id) {
        String profile_name = "";

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_getProfileDetails);
            ps.setString(1, user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                byte[] profile_name_enc = rs.getBytes("name");

                byte[] profile_name_ba = processDecrypt(profile_name_enc);

                profile_name = new String(profile_name_ba);
            }

            if(profile_name == null || profile_name.trim().length() <= 0) {
                msg = getProfileDetailsForm(profile_name, "from_header");
            } else {
                msg = "profilename_already_set";
            }
        } catch(Exception se) {
            msg = getProfileDetailsForm(profile_name, "from_header");
            return msg;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String getProfileDetails(String user_id, String from) {
        String profile_name = "";

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_getProfileDetails);
            ps.setString(1, user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                byte[] profile_name_enc = rs.getBytes("name");

                byte[] profile_name_ba = processDecrypt(profile_name_enc);

                profile_name = new String(profile_name_ba);
            }

            msg = getProfileDetailsForm(profile_name, from);

        } catch(Exception se) {
            msg = getProfileDetailsForm(profile_name, from);
            return msg;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public boolean isProfileNameSet(String user_id) {
        String profile_name = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_getProfileDetails);
            ps.setString(1, user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                byte[] profile_name_enc = rs.getBytes("profile_name");

                byte[] profile_name_ba = processDecrypt(profile_name_enc);

                profile_name = new String(profile_name_ba);
            }

            if(profile_name == null || profile_name.trim().length() <= 0) {
                return false;
            } else {
                return true;
            }
        } catch(Exception se) {
            return false;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String getProfileDetailsForm(String name, String from) {

        String ret = "<div class='row'>" +
                "   <div class='col-xs-4' align='left'>" +
                "       <h5 for='name' class='pull-right' style='font-size:15px;margin-top:10px'>Name:</h5>" +
                "   </div>" +
                "   <div class='col-xs-7' style='margin-left:1%'>" +
                "       <input type='text' class='form-control' id='profile_name' style='max-width: 300px' name='profile_name' value='"+name+"'>" +
                "   </div>" +
                "</div>" +
                "<div id='add_profile_form_status' align='center'>" +
                "</div>" +

                "<div class='modal-footer' style='margin-top: 0px;'>" +
                "   <center>" +
                "       <button onclick='saveProfileDetails(\""+from+"\");' class='btn btn-info' type='submit' style='background-color:#2C93FF;'>Save</button>&nbsp;&nbsp;" +
                "       <button class='btn btn-secondary active' data-toggle='button' data-dismiss='modal'>Close</button>" +
                "   </center>" +
                "</div>";

        return ret;
    }

    public String deletepost(String user_id, String activity_id) {
        String  msg =  "<div class='modal-dialog'>" +
                "            <div class='modal-content' style='max-width: 550px'>" +
                "                <div class='modal-header' style='background-color:#2C93FF;border-radius: 5px 5px 0px 0px; padding: 10px;'>" +
                "                    <button type='button' class='close' data-dismiss='modal' style='color: white' aria-hidden='true'>&times;</button>" +
                "                    <h3 class='modal-title text-center' style='margin-bottom: 0px;height:15px;color: white;text-align-center' >Delete Post</h3></br>" +
                "                </div>" +
                "                <div class='modal-body'> " +
                "   <p align='center' style='margin-top:5%'>Are you sure you wish to delete this post?</p>" +
                "       <div id='add_cledit_status' align='center' style='display:none'></div>" +
                "         <div class='modal-footer' style='margin-top:-2%;display:inline'>" +
                "          <center>" +
                "             <button id='activity_id' class='btn  btn-info'  style='background-color:#2C93FF' data-toggle='button' type='submit' onclick='DeletePost("+activity_id+");'>Delete post</button>&nbsp;&nbsp;" +
                "             <button class='btn btn-secondary active' data-toggle='button' data-dismiss='modal'>Cancel</button>" +
                "          </center>" +
                "        </div>";
        return msg;
    }

    public String getSearchResultsString(String fl_userid, String fl_email, String profession,String expertise, String experience, String linkedin_url, String fl_photo_path, String fb_user_id,String fl_name) throws SQLException {

        fl_photo_path = (fl_photo_path != null && fl_photo_path.trim().length() > 0 ? fl_photo_path : "images/profile.jpg");

        String linkedin_str1 = "<button class='btn btn-info btn-simple btn-fill   btn-sm' style='cursor: pointer;padding: 0px 5px' data-original-title='Linkedin profile' type='button' title='' rel='tooltip'  onclick=\"window.open('"+linkedin_url+"', '_blank')\"><i class='fa fa-linkedin'></i> </button>";
        String linkedin_str = (linkedin_url != null && linkedin_url.trim().length() > 0 ? linkedin_str1 : "");

        String ret = "<dl style='word-wrap: break-word;padding:0px'>" +
                "<dd class='pos-left clearfix'>" +
                "<div class='events' style='margin-top:1%;line-height:1.0;background-color:#ffffff; box-shadow: 0.09em 0.09em 0.09em 0.05em  #fef7f7;'>" +
                "<p class='pull-left' tyle='margin-left:-3px;margin-bottom: 0px'>    " +
                "<img class='img-circle' style='max-width:45px' src="+fl_photo_path+"> " +
                "</p>"+
                "<div class='events-body ' style='margiun-right:0px;'>" +
                "<div align='left' class='pull-left' style='width:90%;margin-bottom:2px'>    <h2 style='margin-top:0px;margin-bottom:3px;font-size:15px;color:#8F3F3F;margin-left:8px'>"+(fl_name != null && fl_name.trim().length() > 0 ? fl_name  : "N/A")+" &nbsp;"+(linkedin_str)+"</h5>"+
                "<p style='margin-bottom:0px;font-family:monospace;overflow:auto; font-size-adjust: 0.58;line-height:1.1;font-size:12px;margin-left:8px' >" +
                "Profession:&nbsp;"+(profession != null && profession.trim().length() > 0 ? profession  : "N/A")+"<br>" +
                "Expertise:&nbsp;"+(expertise != null && expertise.trim().length() > 0 ? expertise  : "N/A")+"<br>" +
                "Experience:"+(experience != null && experience.trim().length() > 0 ? experience  : "N/A")+"<br>" +
                "</div>" +
                "<div class='pull-right'  style='width:10%;background-color:#ffffff;margin-top:40px '>" +
                "<button  data-toggle='modal' type='button' id='showworkedwith_"+fl_userid+"_search'  class='btn btn-default btn-simple btn-lg pull-right' style='padding: 1px 5px;background-color:#ffffff;margin-top:-25px' onclick='showsearchFLclients("+fl_userid+");'><i class='fa fa-angle-right' style='color:#808080;font-size:25px'></i></button>" +
                "<button  data-toggle='modal' type='button' id='hideworkedwith_"+fl_userid+"_search'  class='btn btn-default btn-simple btn-lg pull-right' style='padding: 1px 5px; display: none;background-color:#e1e2cf;margin-top:-18px' onclick='hideFLclients("+fl_userid+");'><i class='fa fa-caret-up fa-lg' style='color:#22A7F0'></i></button> </td>" +
                "</div>" +"</div>" +
                "</div>" +
                "</div>" +
                "</dd>" +
                "<div  id='showflcl_"+fl_userid+"_search' class='text-left' style='max-width: 98%;margin-top: %;'></div>"+
                "</dl>";
        return ret;
    }

    public String datetime(Connection con, String activity_id) {
        PreparedStatement ps = null;
        ResultSet rs = null;

        String recommend_date ="";
        String converted_time =" ";

        try {
            ps = getPs(con, sql_getdatetime);
            ps.setString(1, activity_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                String my_string = rs.getString("posted_on");
                String [] my_date_time = null;
                my_date_time = my_string.split(" ");
                String Date_str=my_date_time[0];

                SimpleDateFormat originalFormat = new SimpleDateFormat("MM-dd-yyyy HH:mm:ss");
                SimpleDateFormat targettimeFormat = new SimpleDateFormat("HH:mm");

                Date date;
                try {
                    date = originalFormat.parse(my_string);
                    String test_create_time = targettimeFormat.format(date);
                    converted_time = convert24Hoursto12HoursFormat (test_create_time);
                    String checkZerohours[] = converted_time.split(":");
                    if( checkZerohours[0].equalsIgnoreCase("0")){
                        converted_time  = "12:"+checkZerohours[1];
                    }
                } catch (ParseException ex) {
                    ex.printStackTrace();
                }
                recommend_date += Date_str+"&nbsp;<i class='fa fa-clock-o' style='font-size:10px'>&nbsp;"+converted_time+"</i>";
            }
        } catch(Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        }
        return recommend_date;
    }

    public String  datetimeactivities(Connection con, String activity_id) {
        PreparedStatement ps = null;
        ResultSet rs = null;

        String recommend_dateactivities ="";
        String converted_timeactivities =" ";

        try {
            ps = getPs(con, sql_getdatetimeactivities);
            ps.setString(1, activity_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                String my_string = rs.getString("posted_on");
                String [] my_date_time = null;
                my_date_time = my_string.split(" ");
                String Date_str=my_date_time[0];

                SimpleDateFormat originalFormat = new SimpleDateFormat("MM-dd-yyyy HH:mm:ss");
                SimpleDateFormat targettimeFormat = new SimpleDateFormat("HH:mm");

                Date date;
                try {
                    date = originalFormat.parse(my_string);
                    String test_create_time = targettimeFormat.format(date);
                    converted_timeactivities = convert24Hoursto12HoursFormat (test_create_time);
                    String checkZerohours[] = converted_timeactivities.split(":");
                    if( checkZerohours[0].equalsIgnoreCase("0")){
                        converted_timeactivities  = "12:"+checkZerohours[1];
                    }
                } catch (ParseException ex) {
                    ex.printStackTrace();
                }
                recommend_dateactivities += Date_str+"&nbsp;&nbsp;<i class='fa fa-clock-o'></i> "+converted_timeactivities;
            }
        } catch(Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        }
        return recommend_dateactivities;
    }

    public String dateTimeActivityResponse(Connection con, String activity_id) {
        PreparedStatement ps = null;
        ResultSet rs = null;

        String recommend_dateactivityresponse ="";
        String converted_timeactivityresponse =" ";

        try {
            ps = getPs(con, sql_getDateTimeActivityResponse);
            ps.setString(1, activity_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                String my_string = rs.getString("recommended_on");
                String [] my_date_time = null;
                my_date_time = my_string.split(" ");
                String Date_str=my_date_time[0];

                SimpleDateFormat originalFormat = new SimpleDateFormat("MM-dd-yyyy HH:mm:ss");
                SimpleDateFormat targettimeFormat = new SimpleDateFormat("HH:mm");

                Date date;
                try {
                    date = originalFormat.parse(my_string);
                    String test_create_time = targettimeFormat.format(date);
                    converted_timeactivityresponse = convert24Hoursto12HoursFormat (test_create_time);
                    String checkZerohours[] = converted_timeactivityresponse.split(":");
                    if( checkZerohours[0].equalsIgnoreCase("0")){
                        converted_timeactivityresponse  = "12:"+checkZerohours[1];
                    }
                } catch (ParseException ex) {
                    ex.printStackTrace();
                }
                recommend_dateactivityresponse += Date_str+"&nbsp;&nbsp;<i class='fa fa-clock-o'></i> "+converted_timeactivityresponse;
            }
        } catch(Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        }
        return recommend_dateactivityresponse;
    }

    public String convert24Hoursto12HoursFormat(String time) {
        String ret = null;
        try {

            if (time.equalsIgnoreCase("12:00")) {
                return time+" PM";
            }
            final SimpleDateFormat sdf = new SimpleDateFormat("H:mm");
            final Date dateObj = sdf.parse(time);

            ret = new SimpleDateFormat("K:mm a").format(dateObj);

        } catch (final ParseException e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        }
        return ret;
    }

    public String loadActivitiesAsksString(Connection con, String activity_id, String posted_by_photo, String fl_name, String comments, String posted_on, String posted_by, String owner_id, Vector fl_list) {
        posted_by_photo = (posted_by_photo != null && posted_by_photo.trim().length() > 0 ? posted_by_photo : "images/profile.jpg");

        String Date_str1 = datetimeactivities(con, activity_id);
        String dropdownStr = "";
        String category_to_display = "asks";

        Iterator it = fl_list.iterator();

        String fl_list_str = "<select id = 'ask_response_"+activity_id+"_"+owner_id+"' name='ask_response_"+activity_id+"_"+owner_id+"' class='form-control pull-center' style='max-width: 50%; display: inline; padding: 1px; margin-top: -1%;border: 1px solid #66cccc;'>";

        while(it.hasNext()) {
            String val = (String)it.next();

            if(val != null) {
                String[] val_split = val.split("\\|\\|");

                if(val_split.length == 2) {
                    String pros_user_id = val_split[0];
                    String pros_contact_name = val_split[1];

                    fl_list_str += "<option value='"+pros_user_id+"'>"+pros_contact_name+"</option>";
                }
            }
        }
        fl_list_str += "</select>";

        String ret = "" +
                "<dl id='ask' style='margin-bottom:0px; width: 99%;'>" +
                "   <dd class='pos-left clearfix' >" +
                "               <div class='events' style='margin-top:0px;display:inline;background-color:#ffffff;padding-right: 7px; box-shadow: 0.09em 0.09em 0.09em 0.05em #888888;'>" +
                "                <p class='pull-right' style='display:inline;margin-left:-6%;margin-top:-2%'> " +
                "                   <img class='events-object img-circle' src='images/post.png' style='max-width:25px;margin-right: 8%;'> </p> " +
                "                <p class='pull-left' style='margin-left:2%;margin-bottom: 0px'>" +
                "               <img class='img-circle' style='max-width:45px' src='"+posted_by_photo+"' class='events-object img-rounded'>" +
                "            </p>" +
                "            <div class='events-body' style='margin-bottom:2%;margin-top: 1%'>" +
                "               <div align='left' style='margin-left:9px'>" +
                "                   <h3 class='events-heading text-left' style='display: inline;font-size: 15px'>"+fl_name+"  </h3>" +
                "                   <span class='text-muted' style='font-size: 12px'>"+category_to_display+" </span><br>" +
                "                   <p class='text-left text-muted' style='font-size: 11px; margin: 0 0 5px;'>"+Date_str1+"</p>" +
                "               </div>" +
                "            </div>" +
                "            <div class='events-body' style='line-height:1.2'>"+
                "            <div>    " +
                "               <p align ='left' class='pull-left' style='font-size: 12px;line-height:1.3;display:inline;margin-bottom:2px'>" +
                "               <button id='broadcast_ask_nf_"+activity_id+"_"+owner_id+"' style='padding: 0px;background-color:#ffffff;display:inline;' class='btn btn-social btn-default btn-simple btn-sm pull-left'   onclick=\"broadcastAskInNetwork('broadcast_ask_nf', "+activity_id+", "+owner_id+"); return false;\"> " +
                "               <img width='18px' src='images/broadcast.png' class='pull-left' style='display:inline;margin-top:-1px;background-color:#ffffff'>&nbsp;&nbsp; </button>"+comments+"</p></div> " +
                "            </div>" +
                "               <div id='responsedetails_"+activity_id+"' align='center' class=' pull-center' style='margin-bottom:10px;display:inline;'>" +
                fl_list_str +
                "                   <button id='ask_response_btn_"+activity_id+"_"+owner_id+"' style='padding: 1px 10px 5px 10px; margin-top: 0%;background-color:#ffffff' class='btn btn-default btn-simple btn-md pull-center' rel='tooltip' title='Post Response' data-original-title='Post Response' type='button' data-toggle='modal'  onclick=\"postResponseToAsk("+activity_id+", "+owner_id+"); return false;\">" +
                "                       <i class='fa fa-share fa-md' style='color:#ff6666'></i>" +
                "                   </button>" +
                "                   <button id='hide_response_btn_"+activity_id+"_"+owner_id+"' style='padding: 1px 10px 5px 10px; margin-top: 0%;background-color:#ffffff;display:none' class='btn btn-default btn-simple btn-md pull-center' rel='tooltip' title='Post Response' data-original-title='Post Response' type='button' data-toggle='modal'  onclick=\"postResponseToAsk("+activity_id+", "+owner_id+"); return false;\"> " +
                "                        <i class='fa fa-share fa-md' style='color:#12B812'></i>" +
                "                   </button><br>" +
                "               </div>"+
                "           </div>" +
                "       </div>" +
                "   </dd>" +
                "</dl>";
        return ret;
    }

    public String loadFBFriendsString(Connection con, String friend_userid, String friend_email, String friend_name, String friend_photo_path) {
        friend_photo_path = (friend_photo_path != null && friend_photo_path.trim().length() > 0 ? friend_photo_path : "images/profile.jpg");

        String ret = "" +
                "<dl style='padding:0px'  >" +
                "   <dd class='pos-left clearfix'>" +
                "       <div class='events' style='margin-top:2px; box-shadow: 0.09em 0.09em 0.09em 0.05em  #fef7f7; padding: 5px 10px 5px 10px;' onclick='showfllist("+friend_userid+");'>" +
                "           <div class='pull-left'>" +
                "               <img class='img-circle' onclick='showdetails();' style='max-width:45px' src='"+friend_photo_path+"' class='events-object img-rounded'>" +
                "           </div>" +
                "           <div class='events-body' >" +
                "               <div align='left' class='events' style='width:80%;display:inline-block'>" +
                "                   <h2 style='margin-top:3px;margin-bottom:3px;font-size:15px;margin-left:3px'>"+friend_name+"</h2>"+
                "               </div>" +
                "               <div align='right' class='events' style='width:20%;display:inline-block'>" +
                "               <button data-toggle='modal' type='button' id='showfriends_fl_"+friend_userid+"'   class='btn btn-default btn-simple btn-lg' style='padding: 1px 1px;background-color:white;margin-top:2px;' onclick='showfllist("+friend_userid+");'>" +
                "                   <i class='fa fa-angle-right' style='color:#808080;font-size: 25px;'></i>" +
                "               </button>" +
                "               <button  data-toggle='modal' type='button' id='hidefriends_fl_"+friend_userid+"'  class='btn btn-default btn-simple btn-lg' style='padding: 1px 1px;display: none;' onclick='hideFriendFLs("+friend_userid+");'>" +
                "                   <i class='fa fa-caret-down fa-lg' style='color:#22A7F0'></i>" +
                "               </button>" +
                "           </div>" +
                "           </div>" +
                "       </div>" +
                "   </dd>" +
                "</dl>";
        return ret;
    }

    public String loadskFriendString(String friend_userid, String friend_email, String friend_name, String friend_photo_path) {

        String ret =
                "<dl style='padding:0px'>" +
                        "   <dd class='pos-left clearfix'>" +
                        "       <div class='events' style='margin-top:0px; margin-bottom:1px; box-shadow: 0.09em 0.09em 0.09em 0.05em  #fef7f7;padding: 5px 10px 5px 10px;' onclick='showfllist("+friend_userid+");'>" +
                        "           <div class='pull-left'>" +
                        "               <img class='img-circle' onclick='showdetails();' style='max-width:45px' src='images/sk.png' class='events-object img-rounded'>" +
                        "           </div>" +
                        "           <div class='events-body'>" +
                        "               <div align='left' class='events' style='width:80%;display:inline-block'>" +
                        "                   <h2 style='margin-top:3px;margin-bottom:3px;font-size:15px;margin-left:3px'>SK</h2>"+
                        "               </div>" +
                        "               <div align='right' class='events' style='width:20%;display:inline-block'>" +
                        "               <button  data-toggle='modal' type='button' id='showfriends_fl_"+friend_userid+"'  class='btn btn-default btn-simple btn-lg' style='padding: 1px 1px;margin-left:-5px;background-color:white' onclick=\"showfllist("+friend_userid+", '"+friend_name+"');\">" +
                        "                     <i class='fa fa-angle-right' style='color:#808080;font-size: 25px;'></i>" +
                        "               </button>" +
/*
                        "               <button  data-toggle='modal' type='button' id='hidefriends_fl_"+friend_userid+"' class='btn btn-default btn-simple btn-lg' style='padding: 1px 1px;margin-left:-5px; display: none;' onclick='hideFriendFLs("+friend_userid+");'>" +
                        "                   <i class='fa fa-caret-down fa-lg' style='color:#22A7F0'></i>" +
                        "               </button>" +
*/
                        "           </div>" +
                        "       </div>" +
                        "   </dd>" +
                        "</dl>";
        return ret;
    }

    public String getFlListString(String friend_userid, String fl_userid, String freelancer_name, String freelancer_email, String profession, String expertise, String experience, String linkedin) {
        String ret = "";
        String linkedin_str1 = "<button class='btn btn-info btn-simple btn-fill   btn-sm' style='cursor: pointer;padding: 0px 5px' data-original-title='Linkedin profile' type='button' title='' rel='tooltip'  onclick=\"window.open('"+linkedin+"', '_blank')\"><i class='fa fa-linkedin'></i> </button>";
        String linkedin_str = (linkedin != null && linkedin.trim().length() > 0 ? linkedin_str1 : "");

        ret =
                "   <div id=fl_"+friend_userid+" class='text-left' style='max-width: 98%;margin-top: 0%;max-height: 200px;overflow: auto; overflow-x: hidden;overflow-y:scroll'></div>"+
                        "<dl style='padding: 2px 0; position: relative'  >" +
                        "   <dd class='pos-left clearfix'style='line-height:1.2' >" +
                        "       <div class='events' id='friendfl' style='background-color:#ffffff;line-height:1.3; box-shadow: 0.09em 0.09em 0.09em 0.05em #fef7f7;padding:5px 5px 5px 10px'>" +
                        "           <div class='events-body'>" +
                        "               <div align='left'>  " +
                        "                  <h5 style='margin-top:0px;margin-bottom:3px;font-size:15px;margin-left:8px'>"+(freelancer_name != null && freelancer_name.trim().length() > 0 ? freelancer_name  : "N/A")+" &nbsp;"+(linkedin_str)+"</h5>"+
                        "                     <h4 class='text-muted' style='margin-bottom:2px;font-family:monospace;overflow:auto; font-size-adjust: 0.58;line-height:1.1;font-size:12px;margin-left:8px' >" +
                        "                        Profession:"+(profession != null && profession.trim().length() > 0 ? profession : "N/A")+"<br>" +
                        (experience != null && experience.trim().length() > 0 ? "Experience:"+experience+"<br>" : " " )+"" +
                        (expertise != null && expertise.trim().length() > 0 ? "Expertise:"+expertise+"<br>" : " ")+"" +
                        "                  </div>" +
                        "               </div>" +
                        "           </div>" +
                        "       </div>" +
                        "   </dd>" +
                        "   <div id='showfl_of_friend_"+fl_userid+"' style='max-width: 98%;margin-top: %;maax-height: 150px;overflow: auto;'></div>"+
                        "</dl>";

        return ret;
    }

    public String loadAskListString(Connection con, String user_id, String activity_id, String comments, String posted_on, String posted_by_photo, String name, String posted_by) {

        posted_by_photo = (posted_by_photo != null && posted_by_photo.trim().length() > 0 ? posted_by_photo : "images/profile.jpg");

        String Date_str = datetime(con, activity_id);

        String ret = "" +
                " <dl style='margin-bottom:-2px;margin-top:0.5%;padding:0px; width: 99%;'>" +
                "           <dd class='pos-left clearfix' style='margin-top:-1%'>" +
                "               <div class='events' style='margin-top:1%;display:inline;background-color:#ffefef;padding-right: 7px;padding-top: 6px;  box-shadow: 0.09em 0.09em 0.09em 0.05em #888888;'>" +
                "                <p class='pull-right' style='display:inline;margin-left:-6%;margin-top:-2%'> " +
                "                   <img class='events-object img-rounded' src='images/post.png' style='max-width:25px;margin-right: 8%;'> </p> " +
                "                <p class='pull-left' style='margin-left:2%;margin-bottom: 0px'>" +
                "               <img class='img-circle style='max-width:45px' src='"+posted_by_photo+"' class='events-object img-rounded'>" +
                "           </p>" +
                "           <div class='events-body' style='margin-bottom:2%;margin-top: 1%'>" +
                "               <div align='left' style='margin-left:8px'>" +
                "                   <h3 class='events-heading text-left' style='display: inline;font-size: 15px'>"+name+"  </h3>" +
                "                   <p class='text-left text-muted' style='font-size: 11px; margin: 0 0 5px;'>"+Date_str+"</p>" +
                "               </div></div>" +
                "              <span class='events' style='margin-bottom:1px;background-color:#ffefef\n;padding:0px'>" +
                "                 <p class='text-left' style='line-height:1.3;font-size: 11px;word-wrap: break-word;margin-left: 2%;margin-bottom:0px;margin-top:0px;' align='left' >"+comments+"</p>" +
                "                    <div  align='center' class='event-body' style='margin-bottom:1%;display:inline'>" +
                "                      <div class='pull-right' style='display:inline'> "+
                "                       <button  onclick=\"getpostdetailstodelete('"+activity_id+"');\" data-toggle='modal' type='button'  class='btn btn-default btn-simple btn-lg ' style='padding: 1px 10px;background-color:#ffefef' ><i class='fa fa-times' style='color:#ff6666'></i></button>" +
                "                         <button  data-toggle='modal' type='button' id='hideaskresponses_"+activity_id+"'  class='btn btn-default btn-simple btn-lg ' style='padding: 1px 10px; display: none;background-color:#fefafa' onclick='hideAskResponses("+activity_id+");'><i class='fa fa-caret-up fa-lg' style='color:#22A7F0'></i></button>" +
                "			              <button  data-toggle='modal' type='button' id='showaskresponses_"+activity_id+"'  class='btn btn-default btn-simple btn-lg' style='padding: 1px 10px;background-color:#ffefef' onclick='showAskResponses("+activity_id+");'><i class='fa fa-arrow-circle-right' style='color:#22A7F0'></i></button>" +

                "                      </div> </div><br>"+
                "                   </span>" +
                "               </div>" +
                "           </dd>" +
                "           <div id='show_ask_responses_"+activity_id+"' class='text-left' style='max-width: 98%;margin-bottom: 0%;max-height: 180px;overflow: auto;'></div>"+
                "       </dl>";

        return ret;
    }

    public String loadUserNotificationsNameString(String from_user_id) {
        String ret = "" +
                "<dl id='"+from_user_id+"' style='padding:0px'>  " +
                "   <dd class='pos-left clearfix'>" +
                "       <div class='events' style='margin-top:2%; box-shadow: 0.09em 0.09em 0.09em 0.05em  #888888; background-color: #ffffff;'>" +
                "           <div class='events-body'>" +
                "               <div class='pull-left'>"+
                "                   <h7 id='"+from_user_id+"_name' style='margin-left:5px;'>Profile name is not added</h7><br>" +
                "               </div>" +
                "             <div class='pull-right'>  " +
                "                   <button onclick='openProfileForm(\"from_alert\");' type='button' class='btn btn-info btn-sm pull-right' style='display:inline;border-radius:15px; margin-bottom: 8px;'>" +
                "                   Add</button> " +
                "             </div>" +
                "           </div>" +
                "       </div>" +
                "   </dd>" +
                "</dl>";

        return ret;
    }

    public String loadUserNotificationsProfessionString(String from_user_id) {
        String ret = "" +
                "<dl id='"+from_user_id+"' style='padding:0px'>  " +
                "   <dd class='pos-left clearfix'>" +
                "       <div class='events' style='margin-top:2%; box-shadow: 0.09em 0.09em 0.09em 0.05em  #888888; background-color: #ffffff;'>" +
                "           <div class='events-body'>" +
                "               <div class='pull-left'>"+
                "                   <h7 id='"+from_user_id+"_name' style='margin-left:5px;'>Profession details are not added</h7><br>" +
                "               </div>" +
                "             <div class='pull-right'>  " +
                "                   <button onclick='openSkillsForm(\"from_alert\");' type='button' class='btn btn-info btn-sm pull-right' style='display:inline;border-radius:15px; margin-bottom: 8px;'>" +
                "                   Add</button> " +
                "             </div>" +
                "           </div>" +
                "       </div>" +
                "   </dd>" +
                "</dl>";

        return ret;
    }

    public String loadRemindersString(String from_userid, String from_name, String to_userid, String to_name, String invitation_sent_time, String connection) {
        if (connection.equalsIgnoreCase("appinvite")) {
            connection = "App invitation";
        } else if (connection.equalsIgnoreCase("appreminder")) {
            connection = "App reminder";
        } else if (connection.equalsIgnoreCase("friend")) {
            connection = "Friend request";
        } else if (connection.equalsIgnoreCase("professional")) {
            connection = "Professional request";
        } else if (connection.equalsIgnoreCase("client")) {
            connection = "Client request";
        } else {
            connection = connection+" request";
        }
        String ret =  "<dl id='remind_"+from_userid+"'style='word-wrap: break-word;padding:0px;'>" +
                "   <dd class='pos-left clearfix' style='margin-bottom:0px'>" +
                "       <div class='events' style='margin-top:3px;line-height:1.0;background-color:#ffffff; box-shadow: 0.09em 0.09em 0.09em 0.05em #888888; display:inline-block;'>" +
                "           <div class='events-body ' style='margiun-right:0px;'>" +
                "               <div align='left' class='pull-left' style='width:70%;margin-bottom:2px'>" +
                "                   <h5 style='margin-top:0px;margin-bottom:3px;font-size:15px;margin-left:8px'>"+(to_name != null && to_name.trim().length() > 0 ? to_name  : "N/A")+" &nbsp;</h5>" +
                "                   <h4 class='text-muted' style='margin-bottom:2px;font-family:monospace;overflow:auto; font-size-adjust: 0.58;line-height:1.1;font-size:12px;margin-left:8px'>"+connection+" sent on: " +invitation_sent_time+"</h4>" +
                "               </div>" +
                "               <div class='pull-right'  style='width:30%;background-color:#ffffff;'>  " +
                "                   <button id='remind_"+to_userid+"' onclick='sendAPPInvite(\""+from_userid+"\", \""+to_userid+"\");' type='button' class='btn btn-info btn-sm pull-right' style='display:inline;border-radius:15px'>\n" +
                "                       Remind" +
                "                   </button>" +
                "                   <button id='remindsuccess_"+to_userid+"' type='button' class='btn btn-success btn-sm pull-right' style='display:inline;border-radius:15px;display:none'>\n" +
                "                       Success" +
                "                   </button>" +
                "               </div>" +
                "           </div>" +
                "       </div>" +
                "   </dd>" +
                "</dl>";

        return ret;
    }

    final String sql_updateProfileDetails = "update users set name = ? where user_id = ?";

    public int updateProfileName(String profile_name, String user_id) {
        int status = 0;

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();
            ps = getPs(con, sql_updateProfileDetails);

            byte[] profile_name_enc = processEncrypt(profile_name);

            ps.setBytes(1, profile_name_enc);
            ps.setString(2, user_id);

            status = ps.executeUpdate();
        } catch(Exception se) {
//            System.err.print(se.getMessage());
//            System.err.print(new Date()+"\t "+se.getMessage());
            logException(se);
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    public int addOrUpdateFLskills(String profession, String expertise, String experience, String linkedin, String profile_location, String profile_about, String from_user_id) {
        int status = 0;

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_checkFLSkills);
            ps.setString(1, from_user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                ps = getPs(con, sql_updateFLSkills);

                ps.setString(1, profession);
                ps.setString(2, expertise);
                ps.setString(3, experience);
                ps.setString(4, linkedin);
                ps.setString(5, profile_about);
                ps.setString(6, profile_location);
                ps.setString(7, from_user_id);

                status = ps.executeUpdate();
            } else {
                ps = getPs(con, sql_insertFLSkills);

                ps.setString(1, profession);
                ps.setString(2, expertise);
                ps.setString(3, experience);
                ps.setString(4, linkedin);
                ps.setString(5, profile_about);
                ps.setString(6, profile_location);
                ps.setString(7, from_user_id);

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

    final String sql_insertContactProfession = "insert into skills (profession, user_id) values (?, ?)";
    final String sql_updateContactProfession = "update skills set profession = ? where user_id = ?";

    public int addOrUpdateContactProfession(String contact_user_id, String contactprofile_profession) {
        int status = 0;

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_checkFLSkills);
            ps.setString(1, contact_user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                ps = getPs(con, sql_updateContactProfession);

                ps.setString(1, contactprofile_profession);
                ps.setString(2, contact_user_id);

                status = ps.executeUpdate();
            } else {
                ps = getPs(con, sql_insertContactProfession);

                ps.setString(1, contactprofile_profession);
                ps.setString(2, contact_user_id);

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

    public String saveProfileDetails(String from_user_id, String profile_name, String profile_profession,
                                     String profile_expertise, String profile_experience, String profile_linkedin, String profile_location, String profile_about) {
        int name_status = updateProfileName(profile_name, from_user_id);
        int skills_status = addOrUpdateFLskills(profile_profession, profile_expertise, profile_experience, profile_linkedin,profile_location, profile_about, from_user_id);

        if(name_status > 0 && skills_status > 0) {
            return "success";
        }
        return "failed";
    }

    //    final String sql_updateContactDetails = "update users set name = ? where user_id = ?";
    final String sql_updateContactDetails = "update relationship set to_contact_name = ? where rs_id = ? and to_user_id = ?";

    public int UpdateContactDetails(String rs_id, String contact_user_id, String contact_name) {
        int status = 0;

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();
            ps = getPs(con, sql_updateContactDetails);

            try {
                byte[] contact_name_enc = processEncrypt(contact_name);

                ps.setBytes(1, contact_name_enc);
                ps.setString(2, rs_id);
                ps.setString(3, contact_user_id);

                status = ps.executeUpdate();
            } catch(Exception e) {
                System.out.println(new Date()+"\t "+e.getMessage());
                e.printStackTrace();
            }
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.print(new Date()+"\t "+se.getMessage());
            return status;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    final String sql_deleteContact = "update relationship set active_status = 2 where rs_id = ?";       //0 - not active; 1 - active; 2 - deleted

    public int deleteConcatDetails(String rs_id) {
        int status = 0;

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();
            ps = getPs(con, sql_deleteContact);
            ps.setString(1, rs_id);

            status = ps.executeUpdate();

        } catch(Exception se) {
            System.err.print(new Date()+"\t "+se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    public String postResponseToAsk(String user_id, String pros_userid, String activity_id, String comments) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        int cnt = 0;

        try {
            con = getConnection();

            ps = getPs(con, sql_checkAskResponse);
            ps.setString(1, activity_id);
            ps.setString(2, user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                ps = getPs(con, sql_updateAskResponse);

                ps.setString(1, comments);
                ps.setString(2, activity_id);
                ps.setString(3, pros_userid);
                ps.setString(4, user_id);

                cnt = ps.executeUpdate();
            } else {
                ps = getPs(con, sql_postAskResponse);

                ps.setString(1, activity_id);
                ps.setString(2, pros_userid);
                ps.setString(3, user_id);
                ps.setString(4, comments);

                cnt = ps.executeUpdate();
            }

            if(cnt > 0) {
                sendResponseSmstoOwner(con, activity_id, pros_userid, user_id);
                sendResponseSmstoProfessional(con, activity_id, pros_userid, user_id);          //todo, erroneous. fix
                return "success";
            }

            return "failed";
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return "failed";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String addNotifications(String professional_id, String from_user_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_checkNotifications);

            ps.setString(1, from_user_id);
            ps.setString(2, professional_id);

            rs = ps.executeQuery();

            if(rs.next()) {
                return "success";
            } else {
                ps = getPs(con, sql_postNotifications);

                ps.setString(1, from_user_id);
                ps.setString(2, professional_id);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    return "success";
                }
            }
            return "failed";
        } catch (Exception e) {
            System.out.println(new Date() + "\t " + e.getMessage());
            e.printStackTrace();
            return "failed";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }


    //TODO, review. added by Srikanth
    String sql_get_owner_details1 = "select u.name as from_name_enc, u.mobile as to_mobile_enc from users u where u.user_id = ?";
    String sql_get_activity_details = "select ar.comments from users u, activities_responses ar, activities a where ar.activity_id = a.activity_id and u.user_id = a.posted_by and ar.activity_id = ?";

//    String sql_post_response_sms_to_professional = "select (select name from users where user_id = ?) as from_name_enc, (select u.name from users u, activities a  where activity_id = ? and u.user_id = a.posted_by) as client_name_enc, u.mobile as to_mobile_enc from users u, activities_responses ar, activities a where ar.activity_id = a.activity_id and u.user_id = ar.fl_userid and ar.activity_id = ?";

    String sql_get_loggedin_user_details2 = "select u.name as loggedin_username_enc from users u where u.user_id = ?";
    String sql_get_mobile_details2 = "select u.mobile as to_mobile_enc from users u where u.user_id = ?";
    String sql_get_activity_owner_details2 = "select u.name as activity_ownername_enc from users u, activities a where activity_id = ? and u.user_id = a.posted_by";

    public void sendResponseSmstoOwner(Connection con, String activity_id, String pros_userid, String user_id) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        String from_name = null;
        String to_mobile = null;
        String comments = null;

        try {
            ps = getPs(con, sql_get_owner_details1);
            ps.setString(1, user_id);
            rs = ps.executeQuery();

            if(rs.next()) {                                          //0 - no relation; 1 - phone_contact; 2 - fb_friend
                byte[] fl_name_enc = rs.getBytes("from_name_enc");
                byte[] fl_name_ba = processDecrypt(fl_name_enc);
                from_name = new String(fl_name_ba);

                byte[] to_mobileen = rs.getBytes("to_mobile_enc");
                byte[] to_mobile_ba = processDecrypt(to_mobileen);
                to_mobile = new String(to_mobile_ba);
            }

            ps = getPs(con, sql_get_activity_details);
            ps.setString(1, activity_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                comments = rs.getString("comments");
            }

            if(to_mobile != null && from_name != null && comments != null) {
                System.out.println(new Date()+"\t sendResponseSmstoOwner1 -> activity_id: "+activity_id+", recommended_by: "+user_id+", comment: "+comments);
//                System.out.println(new Date()+"\t sendResponseSmstoOwner2 -> from_name: "+from_name+", to_mobile: "+to_mobile+", comments: "+comments);
//               sendResponse_SMS(from_name, to_mobile, comments);
            } else {
                System.out.println(new Date()+"\t Could not sendResponseSmstoOwner -> activity_id: "+activity_id+", recommended_by: "+user_id+", comment: "+comments);
            }
        } catch(Exception se) {
            System.err.print(se.getMessage());
        }
    }

    public void sendResponseSmstoProfessional(Connection con, String activity_id, String pros_userid, String loggedin_user_id) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        String loggedin_username = null;
        String to_mobile = null;
        String activity_ownername = null;

        try {
            ps = getPs(con, sql_get_loggedin_user_details2);
            ps.setString(1, loggedin_user_id);
            rs = ps.executeQuery();

            if(rs.next()) {                                          //0 - no relation; 1 - phone_contact; 2 - fb_friend
                byte[] loggedin_username_enc = rs.getBytes("loggedin_username_enc");
                byte[] loggedin_username_ba = processDecrypt(loggedin_username_enc);
                loggedin_username = new String(loggedin_username_ba);
            }

            ps = getPs(con, sql_get_mobile_details2);
            ps.setString(1, pros_userid);
            rs = ps.executeQuery();

            if(rs.next()) {                                          //0 - no relation; 1 - phone_contact; 2 - fb_friend
                byte[] to_mobile_enc = rs.getBytes("to_mobile_enc");
                byte[] to_mobile_ba = processDecrypt(to_mobile_enc);
                to_mobile = new String(to_mobile_ba);
            }

            ps = getPs(con, sql_get_activity_owner_details2);
            ps.setString(1, activity_id);
            rs = ps.executeQuery();

            if(rs.next()) {                                          //0 - no relation; 1 - phone_contact; 2 - fb_friend
                byte[] activity_ownername_enc = rs.getBytes("activity_ownername_enc");
                byte[] activity_ownername_ba = processDecrypt(activity_ownername_enc);
                activity_ownername = new String(activity_ownername_ba);
            }

            if(to_mobile != null && to_mobile != null && activity_ownername != null) {
                System.out.println(new Date()+"\t sendResponseSmstoProfessional1 -> activity_id: "+activity_id+", recommended_by: "+loggedin_user_id);
                System.out.println(new Date()+"\t sendResponseSmstoProfessional2 -> loggedin_username: "+loggedin_username+", activity_ownername: "+activity_ownername+", to_mobile: "+to_mobile);
//                sendResponse_SMS_to_Professional(loggedin_username, activity_ownername, to_mobile);
            } else {
                System.out.println(new Date()+"\t Could not sendResponseSmstoProfessional -> activity_id: "+activity_id+", recommended_by: "+loggedin_user_id);
            }
        } catch(Exception se) {
            System.err.print(se.getMessage());
        }
    }

    public String broadcastAskInNetwork(String user_id, String activity_id, String owner_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_checkBroadcastInNetwork);

            ps.setString(1, user_id);
            ps.setString(2, activity_id);
            ps.setString(3, owner_id);

            rs = ps.executeQuery();

            if(rs.next()) {
                return "success";
            } else {
                ps = getPs(con, sql_postBroadcastInNetwork);

                ps.setString(1, user_id);
                ps.setString(2, activity_id);
                ps.setString(3, owner_id);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    return "success";
                }
            }
            return "failed";
        } catch (Exception e) {
            System.out.println(new Date() + "\t " + e.getMessage());
            e.printStackTrace();
            return "failed";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String postCommentsInNetwork(String user_id, String fl_user_id, String post_type, String comments) {

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_postCommentsInNetwork);

            ps.setString(1, user_id);
            ps.setString(2, fl_user_id);
            ps.setString(3, post_type);
            ps.setString(4, comments);

            int cnt = ps.executeUpdate();

            if(cnt > 0) {
                return "success";
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return "failed";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return "failed";
    }

    public String getClientsForFL(String from_user_id, String fl_userid, String fl_name) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String friendUserIds = "";
        int cnt = 0;

        String ret_list = "";

        try {
            con = getConnection();

            final String sql_getFriendsUserIds = "select to_user_id from relationship where from_user_id = "+from_user_id+" and advanced_relation_type = 4";

            ps = getPs(con, sql_getFriendsUserIds);
            rs = ps.executeQuery();

            while (rs.next()) {
                String to_user_id = rs.getString("to_user_id");
                if(cnt == 0) {
                    friendUserIds += to_user_id;
                } else {
                    friendUserIds += ", "+to_user_id;
                }
                cnt++;
            }

            if(cnt == 0) {
                friendUserIds = "NULL";
            }

            final String sql_getFLclients = "select r.to_contact_name as fl_name, u.name as client_name, u.email as client_email, u. mobile as client_mobile, u.fb_photo_path as client_fb_photo_path, r.to_user_id , r.from_user_id " +
                    "from users u, relationship r " +
                    "where r.from_user_id in ("+friendUserIds+") and advanced_relation_type = 4 and r.to_user_id = "+fl_userid+" and  r.from_user_id = u.user_id and r.from_user_id <> "+from_user_id+" " +       // displays friends who worked with selected the freelancer

                    "UNION " +

                    "select r.to_contact_name as fl_name, u.name as client_name, u.email as client_email, u. mobile as client_mobile, u.fb_photo_path as client_fb_photo_path, r.to_user_id , r.from_user_id " +
                    "from users u, relationship r " +
                    "where r.from_user_id = "+from_user_id+" and advanced_relation_type = 4 and r.to_user_id = "+fl_userid+" and r.from_user_id = u.user_id";

            ps = getPs(con, sql_getFLclients);
            rs = ps.executeQuery();

            while(rs.next()) {
                try {
//                    byte[] client_email_enc = rs.getBytes("client_email");
                    byte[] client_name_enc = rs.getBytes("client_name");
                    String client_photo = rs.getString("client_fb_photo_path");

//                    byte[] client_email_ba = processDecrypt(client_email_enc);
                    byte[] client_name_ba = processDecrypt(client_name_enc);

//                    String client_email = new String(client_email_ba);
                    String client_name = new String(client_name_ba);

                    ret_list += getClientsForFLString(fl_userid, from_user_id, fl_name, client_name, client_photo);
                } catch(Exception  e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                    continue;
                }
            }

            ret_list += "</ul>";

        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return ret_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
//        System.out.println(new Date()+"\t getClientsForFL END");
        return ret_list;
    }

    public String getClientsForSearchFL(String fl_userid , String user_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String friendUserIds = "";
        int cnt = 0;

        String ret_list = "";

        try {
            con = getConnection();

            final String sql_getFriendsUserIds = "select to_user_id from relationship where from_user_id = "+user_id+" and advanced_relation_type = 4";

            ps = getPs(con, sql_getFriendsUserIds);
            rs = ps.executeQuery();

            while (rs.next()) {
                String to_user_id = rs.getString("to_user_id");
                if(cnt == 0) {
                    friendUserIds += to_user_id;
                } else {
                    friendUserIds += ", "+to_user_id;
                }
                cnt++;
            }

            if(cnt == 0) {
                friendUserIds = "NULL";
            }

            final String sql_getFLclients = "select r.to_contact_name as fl_name, u.name as client_name, u.email as client_email, u. mobile as client_mobile, u.fb_photo_path as client_fb_photo_path, r.to_user_id , r.from_user_id " +
                    "from users u, relationship r " +
                    "where r.from_user_id in ("+friendUserIds+") and advanced_relation_type = 4 and r.to_user_id = "+fl_userid+" and  r.from_user_id = u.user_id and r.from_user_id <> "+user_id+" " +       // displays friends who worked with selected the freelancer

                    "UNION " +

                    "select r.to_contact_name as fl_name, u.name as client_name, u.email as client_email, u. mobile as client_mobile, u.fb_photo_path as client_fb_photo_path, r.to_user_id , r.from_user_id " +
                    "from users u, relationship r " +
                    "where r.from_user_id = "+user_id+" and advanced_relation_type = 4 and r.to_user_id = "+fl_userid+" and r.from_user_id = u.user_id";

            ps = getPs(con, sql_getFLclients);
            rs = ps.executeQuery();

            while(rs.next()) {
                try {
                    byte[] fl_name_enc = rs.getBytes("fl_name");
//                    byte[] client_email_enc = rs.getBytes("client_email");
                    byte[] client_name_enc = rs.getBytes("client_name");
                    String client_photo = rs.getString("client_fb_photo_path");

                    byte[] fl_name_ba = processDecrypt(fl_name_enc);
//                    byte[] client_email_ba = processDecrypt(client_email_enc);
                    byte[] client_name_ba = processDecrypt(client_name_enc);

                    String freelancer_name = new String(fl_name_ba);
//                    String client_email = new String(client_email_ba);
                    String client_name = new String(client_name_ba);

//                    ret_list += getClientsForFLString(fl_userid, freelancer_name, client_email, client_name, client_photo);
                    ret_list += getClientsForFLString(fl_userid, user_id, freelancer_name, client_name, client_photo);

                } catch(Exception  e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                    continue;
                }
            }

            ret_list += "</ul>";
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return ret_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
//        System.out.println(new Date()+"\t getClientsForFL END");
        return ret_list;
    }

    public String getClientsForFLString(String fl_userid, String user_id, String freelancer_name, String client_name, String client_photo) {
        client_photo = (client_photo != null && client_photo.trim().length() > 0 ? client_photo : "images/profile.jpg");
        String  ret =
                "   <div id=fl_"+fl_userid+" class='text-left' style='max-width: 98%;margin-top: 0%;max-height: 200px;overflow: auto; overflow-x: hidden;overflow-y:scroll'></div>"+
                        "<dl style='padding: 2px 0; position: relative; width: 99%;'>" +
                        "   <dd class='pos-left clearfix'style='line-height:1.2' >" +
                        "       <div class='events' id='friendfl' style='background-color:#ffffff;line-height:1.3; box-shadow: 0.09em 0.09em 0.09em 0.05em #888888; padding:5px 5px 5px 10px;min-height:50px;margin-bottom:-3px'>" +
                        "               <div class='pull-left' >" +
                        "                   <img class='img-circle' onclick='showdetails();' style='max-width:35px;margin-top:1%;margin-right:7px' src='"+client_photo+"' class='events-object img-rounded'>" +
                        "               </div>" +
                        "                   <div align='left' style='margin-top:3%;line-height: 1.3;display:inline;'> " +
                        "                       <h5 class='events-heading pull-left ' style='display: inline;font-size:15px;margin-top:3%'>"+client_name+"&nbsp;  </h5>" +
                        "                   </div>" +
                        "               </div>" +
                        "       </div>" +
                        "   </dd>" +
                        "   <div id='showfl_of_friend_"+fl_userid+"' style='max-width: 98%;margin-top: %;maax-height: 150px;overflow: auto;'></div>"+
                        "</dl>";

        return ret;
    }

    public String getAskResponses(String activity_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String ret_list = "";

        try {
            con = getConnection();

            ps = getPs(con, sql_getAskResponsesList);
            ps.setString(1, activity_id);
            rs = ps.executeQuery();

            while(rs.next()) {
                String recommended_by_name = "";

                byte[] recommended_by_name_enc = rs.getBytes("name");       //TODO, Not using email and contact number to display in UI as of now

                try {
                    byte[] recommended_by_nam_bytes = processDecrypt(recommended_by_name_enc);
                    recommended_by_name = new String(recommended_by_nam_bytes);
                } catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                    continue;
                }

                String recommended_by_photo = rs.getString("fb_photo_path");
                String comments = rs.getString("comments");
                String recommended_on = rs.getString("recommended_on");

                ret_list += getAskResponsesList(con, recommended_by_name, recommended_by_photo, comments, recommended_on, activity_id);
            }

            ret_list += "</ul>";
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return ret_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return ret_list;
    }

    public String getAskResponsesList(Connection con, String recommended_by_name, String recommended_by_photo, String comments, String recommended_on,String activity_id) {

        recommended_by_photo = (recommended_by_photo != null && recommended_by_photo.trim().length() > 0 ? recommended_by_photo : "images/profile.jpg");

        String date_str_response = dateTimeActivityResponse(con, activity_id);
        String ret =   " <div  class='text-left' style='max-width: 98%;margin-top: 0%;max-height: 200px;overflow: auto; overflow-x: hidden;overflow-y:scroll;'></div>" +
                "<dl style='padding: 2px 2px; position: relative'>" +
                "                        <dd class='pos-left clearfix'style='line-height:1.2'>" +
                "                            <div class='events' id='askresponse' style='background-color:#ffffff;line-height:1.3; padding:5px 5px 5px 10px;margin-bottom:2px;  box-shadow: 0.09em 0.09em 0.09em 0.05em #888888;'>" +
                "                               <div class='pull-left' >" +
                "                                   <img class='img-circle' onclick='showdetails();' style='max-width:35px;margin-top:1%;margin-right:7px' src='"+recommended_by_photo+"' class='events-object img-rounded'>" +
                "                               </div>" +
                "                                   <div align='left' style='line-height: 1.3;margin-top:0%;margin-bottom:2px'> " +
                "                                       <h5 class='events-heading text-left dont-break-out' style='display: inline;font-size:15px;margin-top:3%'>"+recommended_by_name+"  </h5>" +
                "                                       <span class='text-muted' style='font-size: 12px'>suggests</span> <span class='text-muted' style='font-size: 15px;word-wrap: break-word'>" +comments+ "</span><br> " +
                "                                       <span class='text-muted' style='font-size: 10px'>("+date_str_response+")</span>   " +
                "                               </div>" +
                "                               </div>" +
                "                            </div>" +
                "                        </dd>" +
                "                 </dl>";
        return ret;
    }

    public long getUserId(String email)	{
        long userid = -1;

        Connection con =  null;
        PreparedStatement getUID = null;
        ResultSet rs = null;

        try {
            con = getConnection();

            byte[] email_enc = processEncrypt(email);

            getUID = getPs(con, sql_getUserId);
            getUID.setBytes(1, email_enc);
            rs = getUID.executeQuery();

            if (rs.next()) {
                userid = rs.getLong("user_id");
                return userid;
            }
        } catch(Throwable t) {
            t.printStackTrace();
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }

        return userid;
    }

    public boolean insertFBUserIfNotExist(String email, String name, String gender, String fb_photo_path, String fb_user_id) {
        Connection con = null;
        PreparedStatement checUser = null, insertUser = null, updateUser = null;
        ResultSet rs = null;

        boolean userExist = false;

        try {
            con = getConnection();

            byte[] email_enc = processEncrypt(email);
            byte[] name_enc = processEncrypt(name);

            checUser = getPs(con, sql_doesFBUserExist);
            checUser.setString(1, fb_user_id);
            rs = checUser.executeQuery();

            if (rs.next()) {
                updateUser = getPs(con, sql_updateFBUserDetails);

                updateUser.setBytes(1, email_enc);
                updateUser.setBytes(2, name_enc);
                updateUser.setString(3, gender);
                updateUser.setString(4, fb_photo_path);
                updateUser.setInt(5, 1);                            //Registered - Yes i.e., 1
                updateUser.setString(6, fb_user_id);

                int s = updateUser.executeUpdate();

                return true;
            } else {
                insertUser = getPs(con, sql_insertFBUserDetails);

                insertUser.setBytes(1, email_enc);
                insertUser.setBytes(2, name_enc);
                insertUser.setString(3, gender);
                insertUser.setString(4, fb_photo_path);
                insertUser.setString(5, fb_user_id);
                insertUser.setInt(6, 1);                //Registered - Yes i.e., 1

                int s = insertUser.executeUpdate();

                if (s > 0) {
                    return true;
                } else {
                    return false;
                }
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public static final String sql_checkGeneratedUniqueIsAlreadyPresent = "select COUNT(*) AS rowcount from at_question where question_unique_id = ?";

    static final String char_digits = "2104356879";

    private static int getNextRandomInt() {
        int nextRand = ran.nextInt();
        if (nextRand < 0)
            nextRand = nextRand * -1;
        return nextRand;
    }

    static Random ran = new Random();

    public String deletePost(String user_id ,String activity_id ) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_deletePost);
            ps.setString(1, activity_id);
            int cnt = ps.executeUpdate();

            if(cnt > 0) {
                return "success";
            }
            return "failed";
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return "failed";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }
    final static String sql_deletePost = "update activities set status = 2 where activity_id = ?";


    final static String sql_getUserId = "SELECT user_id FROM users WHERE email = ?";

    final static String sql_doesFBUserExist = "SELECT * FROM users WHERE fb_user_id = ?";
    final static String sql_insertFBUserDetails = "insert into users(email, name, gender, fb_photo_path, fb_user_id, registered) values(?, ?, ?, ?, ?, ?) ";
    final static String sql_updateFBUserDetails = "update users set email = ?, name = ?, gender = ?, fb_photo_path = ?, registered = ? where fb_user_id = ?";

    public boolean insertUserFBFriendsIfNotExist(String userId, String fb_user_id, List<User> friendsList) {
        Connection con = null;
        PreparedStatement checkMapping = null, insertMapping = null;
        ResultSet rs = null;

        try {
            con = getConnection();

            for (User user1 : friendsList) {
                String fb_friend_user_id = user1.getId();
                String fb_friend_user_name = user1.getName();

                postFBFriendsToDB(con, userId, fb_friend_user_name, fb_friend_user_id);
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return false;
    }

    final String sql_checkPhoneContactFromUsers = "select * from users where mobile = ?";
    final String sql_insertPhoneContactIntoUsers = "insert into users (mobile, email) values (?, ?)";

    final String sql_checkContactsReadStatus = "select * from user_mobile_contacts_read_status where user_id = ? and read_contacts_status = 1";
    final String sql_updateContactsReadStatus = "INSERT INTO user_mobile_contacts_read_status (user_id, read_contacts_status) VALUES(?, 1) ON DUPLICATE KEY UPDATE read_contacts_status = 1";

    public boolean postContactsToDB(String from_user_id, org.json.simple.JSONArray contacts_array) {
        Connection con = null;
        PreparedStatement ps_select = null;
        PreparedStatement ps_insert = null;
        PreparedStatement ps_update = null;
        ResultSet rs = null;
        int relation_type = 1;
        int advanced_relation_type = 4;     //changed from 0 to 4 on 29aug. Now, all the new entries are considered as contacts and will be displayed in network feed page

        String name = null;
        String mobile = null;
        String email = null;
        String contactImage_str = null;

//        System.out.println(new Date()+"\t postContactsToDB -> mobile: "+mobile);

        try {
            con = getConnection();

            ps_select = getPs(con, sql_checkContactsReadStatus);
            ps_select.setString(1, from_user_id);
            rs = ps_select.executeQuery();

            //TODO, check if this check has to be done at the Android/iOS level itself
            if(rs.next()) {     //If contacts were already read from mobile and inserted in the database, do nothing, return. Means, we are not inserting contact for the 2nd time
                System.out.println(new Date()+"\t postContactsToDB -> contacts already inserted, do nothing for user_id: "+from_user_id);
                return false;
            }

            ps_select = getPs(con, sql_checkPhoneContactFromUsers);

//            System.out.println("***contacts_array.size(): "+contacts_array.size());

            for(int i = 0; i < contacts_array.size(); i++) {
                org.json.simple.JSONArray contacts = (org.json.simple.JSONArray)contacts_array.get(i);

                if(contacts.size() != 4) {
                    continue;
                }

                try {
                    name = (String)contacts.get(0);
                    mobile = (String)contacts.get(1);
                    email = (String)contacts.get(2);
                    contactImage_str = (String)contacts.get(3);

                    byte[] contactImage = null;

                    if(contactImage_str.length() > 0) {
                        contactImage = Base64.decode(contactImage_str);
                    }

                    //replace all the characters other than + and digits
                    mobile = mobile.replaceAll("[^\\d\\+]", "");

                    byte[] name_enc = processEncrypt(name);
                    byte[] mobile_enc = processEncrypt(mobile);
                    byte[] email_enc = processEncrypt(email);

                    ps_select.setBytes(1, mobile_enc);

                    rs = ps_select.executeQuery();

                    if(rs.next()) {     //If user already exists
                        String to_user_id = rs.getString("user_id");

                        if(from_user_id.equals(to_user_id)) {       //If the same contact is saved in the mobile
                            continue;
                        }

                        postRelationTypeToDB(con, from_user_id, to_user_id, name_enc, contactImage, relation_type, advanced_relation_type);
                    } else {
                        ps_insert = con.prepareStatement(sql_insertPhoneContactIntoUsers, Statement.RETURN_GENERATED_KEYS);

                        ps_insert.setBytes(1, mobile_enc);
                        ps_insert.setBytes(2, email_enc);

                        int cnt = ps_insert.executeUpdate();

                        if(cnt == 1) {
                            rs = ps_insert.getGeneratedKeys();
                            if(rs.next()) {
                                String to_user_id = rs.getString(1);

                                if(from_user_id.equals(to_user_id)) {       //If the self contact is saved in the mobile
                                    continue;
                                }

                                //relation_type: 0 - no relation; 1 - phone_contact; 2 - fb_friend
                                //advanced_relation_type: 0 - no relation; 1 - friend; 2 - client; 3 - freelancer; 4 - contact
                                postRelationTypeToDB(con, from_user_id, to_user_id, name_enc, contactImage, relation_type, advanced_relation_type);
                            }
                        }
                    }
                } catch (Exception e) {
                    System.out.println(new Date()+"\t postContactsToDB -> Could not post contact to db. from_user_id: : "+from_user_id+", contact_name: "+name);
                    e.printStackTrace();
                    return false;
                }
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t postContactsToDB -> Could not post contacts to db. "+e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return  false;
    }

    public boolean postContactsToDB_iOS(String from_user_id, javax.json.JsonArray contacts_array) {
        Connection con = null;
        PreparedStatement ps_select = null;
        PreparedStatement ps_insert = null;
        PreparedStatement ps_update = null;
        ResultSet rs = null;
        int relation_type = 1;
        int advanced_relation_type = 4;     //changed from 0 to 4 on 29aug. Now, all the new entries are considered as contacts and will be displayed in network feed page

        String name = null;
        String mobile = null;
        String email = "";

        try {
            con = getConnection();

            ps_select = getPs(con, sql_checkContactsReadStatus);
            ps_select.setString(1, from_user_id);
            rs = ps_select.executeQuery();

            //TODO, check if this check has to be done at the Android/iOS level itself
            if(rs.next()) {     //If contacts were already read from mobile and inserted in the database, do nothing, return. Means, we are not inserting contact for the 2nd time
                System.out.println(new Date()+"\t postContactsToDB -> contacts already inserted. do nothing for user_id: "+from_user_id);
                return false;
            }

            ps_select = getPs(con, sql_checkPhoneContactFromUsers);

            for(int i = 0; i < contacts_array.size(); i++) {
                javax.json.JsonObject contacts_obj = null;
                contacts_obj = contacts_array.getJsonObject(i);

                if(contacts_obj.size() < 2) {
                    continue;
                }

                try {
                    name = contacts_obj.getString("name");
                    mobile = contacts_obj.getString("number");
//                    email = contacts_obj.getString("email");

//                    System.out.println(new Date()+"\t name: "+name);

                    //replace all the characters other than + and digits
                    mobile = mobile.replaceAll("[^\\d\\+]", "");

                    byte[] name_enc = processEncrypt(name);
                    byte[] mobile_enc = processEncrypt(mobile);
                    byte[] email_enc = processEncrypt(email);

                    ps_select.setBytes(1, mobile_enc);

                    rs = ps_select.executeQuery();

                    if(rs.next()) {
                        String to_user_id = rs.getString("user_id");

                        if(from_user_id.equals(to_user_id)) {       //If the same contact is saved in the mobile
                            continue;
                        }

                        postRelationTypeToDB(con, from_user_id, to_user_id, name_enc, null, relation_type, advanced_relation_type);     //setting contactImage as null for now
                    } else {
                        ps_insert = con.prepareStatement(sql_insertPhoneContactIntoUsers, Statement.RETURN_GENERATED_KEYS);

                        ps_insert.setBytes(1, mobile_enc);
                        ps_insert.setBytes(2, email_enc);

                        int cnt = ps_insert.executeUpdate();

                        if(cnt == 1) {
                            rs = ps_insert.getGeneratedKeys();
                            if(rs.next()) {
                                String to_user_id = rs.getString(1);

                                if(from_user_id.equals(to_user_id)) {       //If the self contact is saved in the mobile
                                    continue;
                                }

                                //relation_type: 0 - no relation; 1 - phone_contact; 2 - fb_friend
                                //advanced_relation_type: 0 - no relation; 1 - friend; 2 - client; 3 - freelancer; 4 - contact
                                postRelationTypeToDB(con, from_user_id, to_user_id, name_enc, null, relation_type, advanced_relation_type);     //setting contactImage as null for now
                            }
                        }
                    }
                } catch (Exception e) {
                    System.out.println(new Date()+"\t postContactsToDB_iOS -> Could not post contact to db. from_user_id: "+from_user_id+", contact_name: "+name);
                    e.printStackTrace();
                    return false;
                }
            }

            // TODO, review: in android, posting contacts in batches. So, updating the flag finally at the end from the android wrapper
            // after successfull read contacts from mobile, update user_mobile_contacts_read_status table

            updateReadContactsStatusToDB(con, from_user_id);
        } catch (Exception e) {
            System.out.println(new Date()+"\t postContactsToDB_iOS -> Could not post contacts to db. "+e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return  false;
    }

    public boolean updateReadContactsStatusToDB(String from_user_id) {
        Connection con = null;
        PreparedStatement ps_update = null;

        try {
            con = getConnection();
//            after successfull read contacts from mobile, update user_mobile_contacts_read_status table

            ps_update = getPs(con, sql_updateContactsReadStatus);
            ps_update.setString(1, from_user_id);

            int cnt = ps_update.executeUpdate();

            if(cnt > 0) {
                return true;
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t updateReadContactsStatusToDB -> Could not update the status["+from_user_id+"] to db: "+e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeConnection(con);
        }
        return false;
    }

    public boolean updateReadContactsStatusToDB(Connection con, String from_user_id) {
        PreparedStatement ps_update = null;

        try {
//            after successfull read contacts from mobile, update user_mobile_contacts_read_status table

            ps_update = getPs(con, sql_updateContactsReadStatus);
            ps_update.setString(1, from_user_id);

            int cnt = ps_update.executeUpdate();

            if(cnt > 0) {
                return true;
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t updateReadContactsStatusToDB -> Could not update the status["+from_user_id+"] to db: "+e.getMessage());
            e.printStackTrace();
            return false;
        }
        return false;
    }

    final String sql_checkFBFriendsFromUsers = "select * from users where fb_user_id = ?";
    final String sql_insertFBFriendsIntoUsers = "insert into users (name, fb_user_id) values (?, ?)";

    public boolean postFBFriendsToDB(Connection con, String from_user_id, String fb_friend_user_name, String fb_friend_user_id) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        int relation_type = 2;
        int advanced_relation_type = 1;

        try {
            ps = getPs(con, sql_checkFBFriendsFromUsers);
            ps.setString(1, fb_friend_user_id);
            rs = ps.executeQuery();

            byte[] fb_friend_user_name_enc = processEncrypt(fb_friend_user_name);

            if(rs.next()) {
                String to_user_id = rs.getString("user_id");

                postRelationTypeToDB(con, from_user_id, to_user_id, fb_friend_user_name_enc, null, relation_type, advanced_relation_type);     //setting contactImage as null for now
                return true;
            } else {
                ps = con.prepareStatement(sql_insertFBFriendsIntoUsers, Statement.RETURN_GENERATED_KEYS);

                ps.setString(1, fb_friend_user_id);
                int cnt = ps.executeUpdate();

                if(cnt == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next()) {
                        String to_user_id = rs.getString(1);
                        //relation_type: 0 - no relation; 1 - phone_contact; 2 - fb_friend
                        //advanced_relation_type: 0 - no relation; 1 - friend; 2 - client; 3 - freelancer
                        postRelationTypeToDB(con, from_user_id, to_user_id, fb_friend_user_name_enc, null, relation_type, advanced_relation_type);     //setting contactImage as null for now
                        return true;
                    }
                }
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return false;
        }
        return  false;
    }

    final String sql_checkUserRelation_Forward = "select * from relationship where from_user_id = ? and to_user_id = ?";
    final String sql_checkUserRelation_Inverse = "select * from relationship where to_user_id = ? and from_user_id = ?";
    final String sql_insertUserRelation_Forward = "insert into relationship (from_user_id, to_user_id, relation_type, advanced_relation_type, active_status, approval_status, to_contact_name) values (?, ?, ?, ?, ?, ?, ?)";
    final String sql_updateToUserName_Inverse = "update relationship set from_contact_name = ? where rs_id = ?";

    final String sql_checkUserRelation = "select * from relationship where from_user_id = ? and to_user_id = ?";
    final String sql_insertUserRelation = "insert into relationship (from_user_id, to_user_id, relation_type, advanced_relation_type, active_status, approval_status, to_contact_name) values (?, ?, ?, ?, ?, ?, ?)";

    public int postRelationTypeToDB(Connection con, String from_user_id, String to_user_id, byte[] name_enc, byte[] contactImage, int relation_type, int advanced_relation_type) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        int rs_id = -1;

        int active_status = 1;
        int approval_status = 1;

        if(advanced_relation_type == 2) {
            approval_status = 0;
        }

        try {
            ps = getPs(con, sql_checkUserRelation);
            ps.setString(1, from_user_id);
            ps.setString(2, to_user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                //Relationship already exists. DO Nothing
//                System.out.println(new Date()+"\t Relationship already exists. Do Nothing...");

                rs_id = rs.getInt("rs_id");
            } else {
                //Relationship doesn't exists, check if relationship already exists in the reverse way and insert relationship accordingly...
                System.out.println(new Date()+"\t Relationship doesn't exists, check if relationship already exists in the reverse way and insert relationship accordingly...");

                ps = getPs(con, sql_checkUserRelation);

                ps.setString(1, to_user_id);
                ps.setString(2, from_user_id);

                rs = ps.executeQuery();

                if(rs.next()) {
                    //Inverse relationship already exists. Get the inverse relationship and insert forward relationship accordingly for the advanced relationship type
                    System.out.println(new Date()+"\t Inverse relationship already exists. Get the inverse relationship and insert forward relationship accordingly for the advanced relationship type...");

                    rs_id = rs.getInt("rs_id");
                    int art_inverse = rs.getInt("advanced_relation_type");

                    if(art_inverse == 2) {
                        advanced_relation_type = 3;
                    } else if(art_inverse == 3) {
                        advanced_relation_type = 2;
                    } else {
                        advanced_relation_type = art_inverse;
                    }
                } else {
                    //Inverse relationship doesn't exists, insert relationship with advanced relationship type = 0...
                    System.out.println(new Date()+"\t Inverse relationship doesn't exists, insert relationship with advanced relationship type = 0...");
                }

                ps = con.prepareStatement(sql_insertUserRelation, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, from_user_id);
                ps.setString(2, to_user_id);
                ps.setInt(3, relation_type);
                ps.setInt(4, advanced_relation_type);
                ps.setInt(5, active_status);
                ps.setInt(6, approval_status);
                ps.setBytes(7, name_enc);

                int cnt = ps.executeUpdate();

                if(cnt == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next()) {
                        rs_id = rs.getInt(1);

                        if(contactImage != null && contactImage.length > 0) {
                            saveContactImageToFileSystem(rs_id, from_user_id, to_user_id, contactImage);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return rs_id;
        }
        return rs_id;
    }

    public String saveProfileImageToFileSystem(String from_user_id, byte[] profile_image, String timeNow) {
        String res = "failed";

        FileOutputStream fos = null;
        File file = null;

        File photo_path_dir = new File(PROFILE_IMAGE_PATH+"\\"+from_user_id);

        if (!photo_path_dir.exists()) {
            try {
                photo_path_dir.mkdir();
            }
            catch(SecurityException se) {
                System.out.println(new Date()+"\t Could not create directory to save contact images: "+photo_path_dir);
            }
        }

        String profile_image_file_name = "profile_"+timeNow+".jpg";

        String photo_path = photo_path_dir+"\\"+profile_image_file_name;

        try {
            file = new File(photo_path);
            fos = new FileOutputStream(file);
            fos.write(profile_image);
            res = "success";
            System.out.println(new Date()+"\t Successfully saved the profile_image: "+photo_path);

            boolean image_status = updateProfileImageName(from_user_id, profile_image_file_name);
        } catch (Exception e) {
            System.out.println(new Date()+"\t Could not save profile_image: "+photo_path);
            e.printStackTrace();
            return res;
        }
        finally {
            try {
                fos.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return res;
    }

    public String saveBusinessDetailsImageToFileSystem(String from_user_id, byte[] businessdetails_image, String timeNow) {
        String res = "failed";

        FileOutputStream fos = null;
        File file = null;

        File photo_path_dir = new File(PROFILE_IMAGE_PATH+"\\"+from_user_id);

        if (!photo_path_dir.exists()) {
            try {
                photo_path_dir.mkdir();
            }
            catch(SecurityException se) {
                System.out.println(new Date()+"\t Could not create directory to save contact business details images: "+photo_path_dir);
            }
        }

        String business_image_file_name = "business_"+timeNow+".jpg";

        String photo_path = photo_path_dir+"\\"+business_image_file_name;

        try {
            file = new File(photo_path);
            fos = new FileOutputStream(file);
            fos.write(businessdetails_image);
            res = "success";
            System.out.println(new Date()+"\t Successfully saved the businessdetails_image: "+photo_path);

            boolean image_status = updateBusinessDetailsImageName(from_user_id, business_image_file_name);
        } catch (Exception e) {
            System.out.println(new Date()+"\t Could not save businessdetails_image: "+photo_path);
            e.printStackTrace();
            return res;
        }
        finally {
            try {
                fos.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return res;
    }

    final String sql_updateProfileImageStatus = "update users set profile_image_file_name = ? where user_id = ?";

    public boolean updateProfileImageName(String from_user_id, String profile_image_file_name) {
        PreparedStatement ps = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_updateProfileImageStatus);
            ps.setString(1, profile_image_file_name);
            ps.setString(2, from_user_id);
            int cnt = ps.executeUpdate();

            if(cnt > 0) {
                return true;
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t Error: updateProfileImageStatus -> " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }

        return false;
    }

    final String sql_updateBusinessDetailsImageStatus = "update users set businessdetails_image_file_name = ? where user_id = ?";

    public boolean updateBusinessDetailsImageName(String from_user_id, String business_image_file_name) {
        PreparedStatement ps = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_updateBusinessDetailsImageStatus);
            ps.setString(1, business_image_file_name);
            ps.setString(2, from_user_id);
            int cnt = ps.executeUpdate();

            if(cnt > 0) {
                return true;
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t Error: updateBusinessDetailsImageName -> " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }

        return false;
    }

    void saveContactImageToFileSystem(int rs_id, String from_user_id, String to_user_id, byte[] contactImage) {
        FileOutputStream fos = null;
        File file = null;

        File photo_path_dir = new File(CONTACT_IMAGE_PATH+"\\"+from_user_id);

        if (!photo_path_dir.exists()) {
            try {
                photo_path_dir.mkdir();
            }
            catch(SecurityException se) {
                System.out.println(new Date()+"\t Could not create directory to save contact images: "+photo_path_dir);
            }
        }

        String photo_path = photo_path_dir+"\\rs_"+rs_id+".jpg";

        try {
            file = new File(photo_path);
            fos = new FileOutputStream(file);
            fos.write(contactImage);
            System.out.println(new Date()+"\t Successfully saved the contactImage: "+photo_path);
        } catch (Exception e) {
            System.out.println(new Date()+"\t Could not save contactImage: "+photo_path);
            e.printStackTrace();
        }
        finally {
            try {
                fos.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public String getStringForContacts(String from_user_id, String to_user_id, String name, String phone, String email, String connection, int approval_status, int rs_id) {
        String s = "";
        s = "" +
                "<dl id='"+from_user_id+"' style='padding:0px'>  " +
                "   <dd class='pos-left clearfix'>" +
                "       <div class='events' style='margin-top:2%; box-shadow: 0.09em 0.09em 0.09em 0.05em  #888888; background-color: #e1e2cf;'>" +
                "           <div class='pull-left img-circle'>" +
//                "               <img onclick='' class='img-circle' style='max-width:40px' src='images/self.png' class='events-object img-rounded'>" +
                "               <img onclick='' class='img-circle' style='max-width:40px' src='user_contact_images/"+rs_id+".jpg' class='events-object img-rounded'>" +
                "           </div>" +
                "           <div class='events-body'>" +
                "               <div align='left'>"+
                "                   <h7 id='"+from_user_id+"_name' style='margin-left:5px;'>"+name+"</h7><br>" +
                "               </div>" +
                "               <div class='events-body text-center pull-left' style='margin-top: 10px; margin-left: 6px;'>" +
                "                   <div class='ui-segment'>" +
                "                       <span a id = 'connection_"+rs_id+"_1' class='option"+(connection.equals("1") ? " active" : " ")+"' onclick=\"updateContactRelationship('"+rs_id+"','1','"+(connection.equals("1") ? "active" : "not_active")+"');\">Friend</span>" +
                "                       <span a id = 'connection_"+rs_id+"_2' class='option"+(connection.equals("2") ? (approval_status == 1 ? " active" : " pending") : " ")+"' onclick=\"updateContactRelationship('"+rs_id+"','2','"+(connection.equals("2") ? (approval_status == 1 ? "active" : "pending") : "not_active")+"');\">Client</span>" +
                "                       <span a id = 'connection_"+rs_id+"_3' class='option"+(connection.equals("3") ? (approval_status == 1 ? " active" : " pending") : " ")+"' onclick=\"updateContactRelationship('"+rs_id+"','3','"+(connection.equals("3") ? (approval_status == 1 ? "active" : "pending") : "not_active")+"');\">Professional</span>" +
                "                   </div>" +
                "               </div>" +
                "               <div class='pull-left' style='padding-left: 6px'>" +
                "                   <button  data-toggle='modal' type='button' class='btn btn-default btn-simple btn-lg  text-center' style='padding: 1px 5px;background-color:#e1e2cf;margin-top: 1%' >" +
                "                       <i class='fa fa-share' style='color:#22A7F0'></i>" +
                "                   </button>" +
                "                   <button data-toggle='modal' type='button' class='btn btn-default btn-simple btn-lg  text-center' style='padding: 1px 8px;background-color:#e1e2cf;margin-top: 1%' onclick=\"editContactForm('"+rs_id+"','"+from_user_id+"','"+name+"');\" >" +
                "                       <i class='fa fa-edit' style='color:#F6BB42'></i>" +
                "                   </button>" +
                "                   <button  data-toggle='modal' type='button' class='btn btn-default btn-simple btn-lg  text-center' style='padding: 1px 5px;background-color:#e1e2cf;margin-top: 1%' onclick=\"getContactDetailsToDelete('"+rs_id+"');\" >" +
                "                       <i class='fa fa-times' style='color: #E9573F'></i>" +
                "                   </button>" +
                "               </div>" +
                "           </div>" +
                "       </div>" +
                "   </dd>" +
                "</dl>";
        return s;
    }

    final String sql_getNumberOfContacts_FromRelationship = "select count(*) as no_of_contacts from users u, relationship rs where u.user_id = rs.to_user_id and rs.from_user_id = ? and rs.active_status = ?";

    public int getNumberOfContacts_FromRelationship(String user_id) {
        Connection con = null;
        PreparedStatement getAC = null;
        ResultSet rs = null;
        int no_of_contacts = 0;

        try {
            con = getConnection();
            getAC = getPs(con, sql_getNumberOfContacts_FromRelationship);

            getAC.setString(1, user_id);
            getAC.setInt(2, 1);
            rs = getAC.executeQuery();

            while (rs.next()) {
                no_of_contacts = rs.getInt("no_of_contacts");
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return no_of_contacts;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return no_of_contacts;
    }

    final String sql_getInitialContacts_FromRelationship = "select u.user_id, rs.rs_id, rs.to_contact_name as contact_name, u.mobile, u.email, rs.advanced_relation_type, rs.approval_status, 'forward' as direction from users u, relationship rs where u.user_id = rs.to_user_id and rs.from_user_id = ? and rs.active_status = ?  limit ?";

    public ArrayList getInitialContacts_FromRelationship_AL(String from_user_id) {
//        System.out.println(""+from_user_id);
        Connection con = null;
        PreparedStatement getAC = null;
        ResultSet rs = null;
        ArrayList contact_list = new ArrayList();

        String contact_user_id = "";
        int rs_id = 0;
        byte[] name_enc;
        byte[] mobile_enc;
        byte[] email_enc;
        String advanced_relation_type = "";
        int approval_status = 0;
        String direction = "";
        String img_name_withpath = "images/profile.jpg";

        try {
            con = getConnection();
            getAC = getPs(con, sql_getInitialContacts_FromRelationship);

            getAC.setString(1, from_user_id);
            getAC.setInt(2, 1);             //active_status
            getAC.setInt(3, SET_CONTACTS_INITIAL_LOADING_LIMIT);
            rs = getAC.executeQuery();

            while (rs.next()) {
                contact_user_id = rs.getString("user_id");
                rs_id = rs.getInt("rs_id");
                name_enc = rs.getBytes("contact_name");
                advanced_relation_type = rs.getString("advanced_relation_type");
                approval_status = rs.getInt("approval_status");
                direction = rs.getString("direction");
                mobile_enc = rs.getBytes("mobile");
                email_enc = rs.getBytes("email");
                img_name_withpath = getimagestatus(from_user_id, "rs_" + rs_id + ".jpg");

                try {
                    String dec_name = "Someone";
                    try {
                        byte[] name_bytes = processDecrypt(name_enc);
                        dec_name = new String(name_bytes);
                    } catch (Exception e) {
                        System.out.println(new Date()+"\t "+e.getMessage());
                    }

                    String dec_mobile = "";
                    try {
                        byte[] mobile_bytes = processDecrypt(mobile_enc);
                        dec_mobile = new String(mobile_bytes);
                    } catch (Exception e) {
                        System.out.println(new Date()+"\t "+e.getMessage());
                    }

                    String dec_email = "";
                    try {
                        byte[] email_bytes = processDecrypt(email_enc);
                        dec_email = new String(email_bytes);
                    } catch (Exception e) {
                        System.out.println(new Date()+"\t "+e.getMessage());
                    }

                    HashMap hm = new HashMap();
                    hm.put("from_user_id", from_user_id);
                    hm.put("contact_user_id", contact_user_id);
                    hm.put("dec_name", dec_name);
                    hm.put("advanced_relation_type", advanced_relation_type);
                    hm.put("approval_status", approval_status);
                    hm.put("rs_id", rs_id);
                    hm.put("direction", direction);
                    hm.put("dec_mobile", dec_mobile);
                    hm.put("dec_email", dec_email);
                    hm.put("img_name_withpath", img_name_withpath);

                    contact_list.add(hm);
                } catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                    continue;
                }
            }
            return contact_list;
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return contact_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    final String sql_getRemainingContacts_FromRelationship = "select u.user_id, rs.rs_id, rs.to_contact_name as contact_name, u.mobile, u.email, rs.advanced_relation_type, rs.approval_status, 'forward' as direction from users u, relationship rs where u.user_id = rs.to_user_id and rs.from_user_id = ? and rs.active_status = ? ";

    public ArrayList getRemainingContacts_FromRelationship_AL(String from_user_id) {
        Connection con = null;
        PreparedStatement getAC = null;
        ResultSet rs = null;
        ArrayList contact_list = new ArrayList();

        String contact_user_id;
        int rs_id = 0;
        byte[] name_enc;
        byte[] mobile_enc;
        byte[] email_enc;
        String advanced_relation_type;
        int approval_status;
        String direction = "";
        String img_name_withpath = "images/profile.jpg";

        try {
            con = getConnection();
            getAC = getPs(con, sql_getRemainingContacts_FromRelationship);

            getAC.setString(1, from_user_id);
            getAC.setInt(2, 1);
            rs = getAC.executeQuery();

            int contact_cnt = 0;

            while (rs.next()) {
                contact_cnt++;
                contact_user_id = rs.getString("user_id");
                rs_id = rs.getInt("rs_id");
                name_enc = rs.getBytes("contact_name");
                advanced_relation_type = rs.getString("advanced_relation_type");
                approval_status = rs.getInt("approval_status");
                direction = rs.getString("direction");
                mobile_enc = rs.getBytes("mobile");
                email_enc = rs.getBytes("email");

                img_name_withpath = getimagestatus(from_user_id, "rs_"+rs_id +".jpg");
                //System.out.println("Remaining img_name_withpath : "+img_name_withpath);

                if(contact_cnt <= SET_CONTACTS_INITIAL_LOADING_LIMIT) {
                    continue;
                }

                try {
                    String dec_name = "Someone";
                    try {
                        byte[] name_bytes = processDecrypt(name_enc);
                        dec_name = new String(name_bytes);
                    } catch (Exception e) {
                        System.out.println(new Date()+"\t "+e.getMessage());
                    }

                    String dec_mobile = "";
                    try {
                        byte[] mobile_bytes = processDecrypt(mobile_enc);
                        dec_mobile = new String(mobile_bytes);
                    } catch (Exception e) {
                        System.out.println(new Date()+"\t "+e.getMessage());
                    }

                    String dec_email = "";
                    try {
                        byte[] email_bytes = processDecrypt(email_enc);
                        dec_email = new String(email_bytes);
                    } catch (Exception e) {
                        System.out.println(new Date()+"\t "+e.getMessage());
                    }

                    HashMap hm = new HashMap();
                    hm.put("from_user_id", from_user_id);
                    hm.put("contact_user_id", contact_user_id);
                    hm.put("dec_name", dec_name);
                    hm.put("advanced_relation_type", advanced_relation_type);
                    hm.put("approval_status", approval_status);
                    hm.put("rs_id", rs_id);
                    hm.put("direction", direction);
                    hm.put("dec_mobile", dec_mobile);
                    hm.put("dec_email", dec_email);
                    hm.put("img_name_withpath", img_name_withpath);

                    contact_list.add(hm);
                } catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
//                    e.printStackTrace();
                    continue;
                }
            }

            return contact_list;
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return contact_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    final String sql_getContacts_FromRelationship = "select u.user_id, rs.rs_id, rs.to_contact_name as contact_name, u.mobile, u.email, rs.advanced_relation_type, rs.approval_status, 'forward' as direction from users u, relationship rs where u.user_id = rs.to_user_id and rs.from_user_id = ? and rs.active_status = ? ";

    public ArrayList getContacts_FromRelationship_AL(String from_user_id) {
        Connection con = null;
        PreparedStatement getAC = null;
        ResultSet rs = null;
        ArrayList contact_list = new ArrayList();

        String contact_user_id;
        int rs_id = 0;
        byte[] name_enc;
        byte[] mobile_enc;
        byte[] email_enc;
        String img_name_withpath = "images/profile.jpg";

        try {
            con = getConnection();
            getAC = getPs(con, sql_getContacts_FromRelationship);

            getAC.setString(1, from_user_id);
            getAC.setInt(2, 1);
            rs = getAC.executeQuery();

            int contact_cnt = 0;

            while (rs.next()) {
                contact_cnt++;
                contact_user_id = rs.getString("user_id");
                rs_id = rs.getInt("rs_id");
                name_enc = rs.getBytes("contact_name");
                mobile_enc = rs.getBytes("mobile");

                img_name_withpath = getimagestatus(from_user_id, "rs_"+rs_id +".jpg");
                //System.out.println("Remaining img_name_withpath : "+img_name_withpath);

                try {
                    String dec_name = "Someone";
                    try {
                        byte[] name_bytes = processDecrypt(name_enc);
                        dec_name = new String(name_bytes);
                    } catch (Exception e) {
                        System.out.println(new Date()+"\t "+e.getMessage());
                    }

                    String dec_mobile = "";
                    try {
                        byte[] mobile_bytes = processDecrypt(mobile_enc);
                        dec_mobile = new String(mobile_bytes);
                    } catch (Exception e) {
                        System.out.println(new Date()+"\t "+e.getMessage());
                    }

                    HashMap hm = new HashMap();
                    hm.put("from_user_id", from_user_id);
                    hm.put("contact_user_id", contact_user_id);
                    hm.put("dec_name", dec_name);
                    hm.put("rs_id", rs_id);
                    hm.put("dec_mobile", dec_mobile);
                    hm.put("img_name_withpath", img_name_withpath);

                    contact_list.add(hm);
                } catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
//                    e.printStackTrace();
                    continue;
                }
            }

            Collections.sort(contact_list, new MapComparator("dec_name"));

            return contact_list;
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return contact_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    class MapComparator implements Comparator<Map<String, String>> {
        private final String key;

        public MapComparator(String key) {
            this.key = key;
        }

        public int compare(Map<String, String> first, Map<String, String> second) {
            // TODO: Null checking, both for maps and values
            String firstValue = first.get(key);
            String secondValue = second.get(key);

            return firstValue.compareToIgnoreCase(secondValue);
        }
    }

    final String sql_getMaxRSID = "select max(rs_id) as rs_id from relationship where from_user_id = ?";

    public int getMaxRSID(String user_id) {
        Connection con = null;
        PreparedStatement getAC = null;
        ResultSet rs = null;
        int max_rsid = 0;

        try {
            con = getConnection();
            getAC = getPs(con, sql_getMaxRSID);

            getAC.setString(1, user_id);
            rs = getAC.executeQuery();

            if (rs.next()) {
                max_rsid = rs.getInt("rs_id");
            }
            return max_rsid;
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return max_rsid;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    //TODO, review sql_check_contact_map_mobile, sql_check_contact_map_fb. inner queries

    String sql_check_contact_mobile = "Select * from users where mobile = ?";
    String sql_check_contact_map_mobile = "Select * from users u, relationship rs where u.user_id = rs.from_user_id and u.user_id = ? and rs.to_user_id = (select user_id from users where mobile = ?)";
    String sql_insert_contact_mobile = "insert into users (mobile, email) values(?, ?)";

    String sql_check_contact_fb = "Select * from users where email = ?";
    String sql_check_contact_map_fb = "Select * from users u, relationship rs where u.user_id = ? and rs.to_user_id = (select user_id from users where email = ?)";
    String sql_insert_contact_fb = "insert into users (mobile, email) values(?, ?)";

    public String addMobileContact(String from_user_id, String contact_name, String contact_number, String contact_mail, String connection_str) {
        int connection = Integer.parseInt(connection_str);

        String status = "failed";

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        int relation_type = 1;

        try {
            con = getConnection();

            byte[] enc_contact_name = processEncrypt(contact_name);
            byte[] enc_contact_mail = processEncrypt(contact_mail);
            byte[] enc_mobile = processEncrypt(contact_number);

            ps = getPs(con, sql_check_contact_mobile);
            ps.setBytes(1, enc_mobile);
            rs = ps.executeQuery();

            if(rs.next()) {
                //Contact already exists, check relationship

                System.out.println(new Date()+"\t Contact already exists, check relationship -> from_user_id: "+from_user_id);

                String to_user_id = rs.getString("user_id");

                ps = getPs(con, sql_check_contact_map_mobile);

                ps.setString(1, from_user_id);
                ps.setBytes(2, enc_mobile);

                rs = ps.executeQuery();

                if(rs.next()) {
                    //Relationship already exists, return

//                    System.out.println("Relationship already exists, return");

                    status = "mapping_exists";
                    return status;
                } else {
                    //Relationship doesn't exist, insert relationship

                    int approval_status = 1;

                    if(connection_str.equals("2")) {
                        approval_status = 0;
                    }

                    int rs_id = postRelationTypeToDB(con, from_user_id, to_user_id, enc_contact_name, null, relation_type, connection);     //setting contactImage as null for now

                    status = getStringForContacts(from_user_id, to_user_id, contact_name, contact_number, contact_mail, connection_str, approval_status, rs_id);
                }
            } else {
                //Contact doesn't exist, insert contact and relationship

                ps = con.prepareStatement(sql_insert_contact_mobile, Statement.RETURN_GENERATED_KEYS);
                ps.setBytes(1, enc_mobile);
                ps.setBytes(2, enc_contact_mail);

                int id = ps.executeUpdate();

                int approval_status = 1;

                if(connection_str.equals("2")) {
                    approval_status = 0;
                }

                if(id == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next()) {
                        String to_user_id = rs.getString(1);

                        int rs_id = postRelationTypeToDB(con, from_user_id, to_user_id, enc_contact_name, null, relation_type, connection);     //setting contactImage as null for now

                        status = getStringForContacts(from_user_id, to_user_id, contact_name, contact_number, contact_mail, connection_str, approval_status, rs_id);
                    }
                }
            }
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.print(new Date()+"\t "+se.getMessage());
            return status;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }

        return status;
    }

    public String addFBContact(String from_user_id, String contact_name, String contact_number, String contact_mail, String connection_str) {

        int connection = Integer.parseInt(connection_str);

        String status = "failed";

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        int relation_type = 2;

        try {
            con = getConnection();

            byte[] enc_contact_name = processEncrypt(contact_name);
            byte[] enc_contact_mail = processEncrypt(contact_mail);
            byte[] enc_mobile = processEncrypt(contact_number);

            ps = getPs(con, sql_check_contact_fb);
            ps.setBytes(1, enc_mobile);
            rs = ps.executeQuery();

            if(rs.next()) {
                //Email already exists, check relationship

//                System.out.println("Email already exists, check relationship");

                String to_user_id = rs.getString("user_id");

                ps = getPs(con, sql_check_contact_map_fb);

                ps.setString(1, from_user_id);
                ps.setBytes(2, enc_contact_mail);

                rs = ps.executeQuery();

                if(rs.next()) {
                    //Relationship already exists, return

//                    System.out.println("Relationship already exists, return");

                    status = "mapping_exists";
                    return status;
                } else {
                    //Relationship doesn't exist, insert relationship

                    int approval_status = 1;

                    if(connection_str.equals("2")) {
                        approval_status = 0;
                    }

                    int rs_id = postRelationTypeToDB(con, from_user_id, to_user_id, enc_contact_name, null, relation_type, connection);     //setting contactImage as null for now

                    status = getStringForContacts(from_user_id, to_user_id, contact_name, contact_number, contact_mail, connection_str, approval_status, rs_id);
                }
            } else {
                //Email doesn't exist, insert email and relationship

                ps = con.prepareStatement(sql_insert_contact_fb, Statement.RETURN_GENERATED_KEYS);
                ps.setBytes(1, enc_mobile);
                ps.setBytes(2, enc_contact_mail);

                int id = ps.executeUpdate();

                int approval_status = 1;

                if(connection_str.equals("2")) {
                    approval_status = 0;
                }

                if(id == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next()) {
                        String to_user_id = rs.getString(1);

                        int rs_id = postRelationTypeToDB(con, from_user_id, to_user_id, enc_contact_name, null, relation_type, connection);     //setting contactImage as null for now

                        status = getStringForContacts(from_user_id, to_user_id, contact_name, contact_number, contact_mail, connection_str, approval_status, rs_id);
                    }
                }
            }
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.print(new Date()+"\t "+se.getMessage());
            return status;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    public ArrayList addMobileContact_JSON(String from_user_id, String contact_name, String contact_number, String contact_mail, String connection_str) {
        int connection = Integer.parseInt(connection_str);

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        int relation_type = 1;

        ArrayList contact_list = new ArrayList();

        String advanced_relation_type = "";
        String direction = "";

        try {
            con = getConnection();

            byte[] enc_contact_name = processEncrypt(contact_name);
            byte[] enc_contact_mail = processEncrypt(contact_mail);
            byte[] enc_mobile = processEncrypt(contact_number);

            ps = getPs(con, sql_check_contact_mobile);
            ps.setBytes(1, enc_mobile);
            rs = ps.executeQuery();

            if(rs.next()) {
                //Contact already exists, check relationship

                System.out.println(new Date()+"\t Contact already exists, check relationship -> from_user_id: "+from_user_id);

                String to_user_id = rs.getString("user_id");

                ps = getPs(con, sql_check_contact_map_mobile);

                ps.setString(1, from_user_id);
                ps.setBytes(2, enc_mobile);

                rs = ps.executeQuery();

                if(rs.next()) {
                    //Relationship already exists, return

//                    System.out.println("Relationship already exists, return");

                    HashMap hm = new HashMap();
                    hm.put("status", "mapping_exists");
                    contact_list.add(hm);
                    return contact_list;
                } else {
                    //Relationship doesn't exist, insert relationship

                    int approval_status = 1;

                    if(connection_str.equals("2")) {
                        approval_status = 0;
                    }

                    int rs_id = postRelationTypeToDB(con, from_user_id, to_user_id, enc_contact_name, null, relation_type, connection);     //setting contactImage as null for now

                    HashMap hm = new HashMap();
                    hm.put("from_user_id", from_user_id);
                    hm.put("contact_user_id", to_user_id);
                    hm.put("dec_name", contact_name);
                    hm.put("advanced_relation_type", connection);
                    hm.put("approval_status", approval_status);
                    hm.put("rs_id", rs_id);
                    hm.put("direction", direction);
                    hm.put("dec_mobile", contact_number);
                    hm.put("dec_email", contact_mail);

                    contact_list.add(hm);

                    return contact_list;

//                    status = getStringForContacts(from_user_id, contact_name, contact_number, contact_mail, connection_str, approval_status, rs_id);
                }
            } else {
                //Contact doesn't exist, insert contact and relationship

                ps = con.prepareStatement(sql_insert_contact_mobile, Statement.RETURN_GENERATED_KEYS);
                ps.setBytes(1, enc_mobile);
                ps.setBytes(2, enc_contact_mail);

                int id = ps.executeUpdate();

                int approval_status = 1;

                if(connection_str.equals("2")) {
                    approval_status = 0;
                }

                if(id == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next()) {
                        String to_user_id = rs.getString(1);

                        int rs_id = postRelationTypeToDB(con, from_user_id, to_user_id, enc_contact_name, null, relation_type, connection);     //setting contactImage as null for now

                        HashMap hm = new HashMap();
                        hm.put("from_user_id", from_user_id);
                        hm.put("contact_user_id", to_user_id);
                        hm.put("dec_name", contact_name);
                        hm.put("advanced_relation_type", connection);
                        hm.put("approval_status", approval_status);
                        hm.put("rs_id", rs_id);
                        hm.put("direction", direction);
                        hm.put("dec_mobile", contact_number);
                        hm.put("dec_email", contact_mail);

                        contact_list.add(hm);

                        return contact_list;

//                        status = getStringForContacts(from_user_id, contact_name, contact_number, contact_mail, connection_str, approval_status, rs_id);
                    }
                }
            }
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.print(new Date()+"\t "+se.getMessage());
            HashMap hm = new HashMap();
            hm.put("status", "failed");
            contact_list.add(hm);

            return contact_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }

        HashMap hm = new HashMap();
        hm.put("status", "failed");
        contact_list.add(hm);

        return contact_list;
    }

    public ArrayList addFBContact_JSON(String from_user_id, String contact_name, String contact_number, String contact_mail, String connection_str) {

        int connection = Integer.parseInt(connection_str);

        String status = "failed";

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        int relation_type = 2;

        ArrayList contact_list = new ArrayList();

        String advanced_relation_type = "";
        String direction = "";

        try {
            con = getConnection();

            byte[] enc_contact_name = processEncrypt(contact_name);
            byte[] enc_contact_mail = processEncrypt(contact_mail);
            byte[] enc_mobile = processEncrypt(contact_number);

            ps = getPs(con, sql_check_contact_fb);
            ps.setBytes(1, enc_mobile);
            rs = ps.executeQuery();

            if(rs.next()) {
                //Email already exists, check relationship

                String to_user_id = rs.getString("user_id");

                ps = getPs(con, sql_check_contact_map_fb);

                ps.setString(1, from_user_id);
                ps.setBytes(2, enc_contact_mail);

                rs = ps.executeQuery();

                if(rs.next()) {
                    //Relationship already exists, return

                    HashMap hm = new HashMap();
                    hm.put("status", "mapping_exists");
                    contact_list.add(hm);
                    return contact_list;
                } else {
                    //Relationship doesn't exist, insert relationship

                    int approval_status = 1;

                    if(connection_str.equals("2")) {
                        approval_status = 0;
                    }

                    int rs_id = postRelationTypeToDB(con, from_user_id, to_user_id, enc_contact_name, null, relation_type, connection);     //setting contactImage as null for now

                    HashMap hm = new HashMap();
                    hm.put("from_user_id", from_user_id);
                    hm.put("contact_user_id", to_user_id);
                    hm.put("dec_name", contact_name);
                    hm.put("advanced_relation_type", connection);
                    hm.put("approval_status", approval_status);
                    hm.put("rs_id", rs_id);
                    hm.put("direction", direction);
                    hm.put("dec_mobile", contact_number);
                    hm.put("dec_email", contact_mail);

                    contact_list.add(hm);

                    return contact_list;

//                    status = getStringForContacts(from_user_id, contact_name, contact_number, contact_mail, connection_str, approval_status, rs_id);
                }
            } else {
                //Email doesn't exist, insert email and relationship

                ps = con.prepareStatement(sql_insert_contact_fb, Statement.RETURN_GENERATED_KEYS);
                ps.setBytes(1, enc_mobile);
                ps.setBytes(2, enc_contact_mail);

                int id = ps.executeUpdate();

                int approval_status = 1;

                if(connection_str.equals("2")) {
                    approval_status = 0;
                }

                if(id == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next()) {
                        String to_user_id = rs.getString(1);

                        int rs_id = postRelationTypeToDB(con, from_user_id, to_user_id, enc_contact_name, null, relation_type, connection);     //setting contactImage as null for now

                        HashMap hm = new HashMap();
                        hm.put("from_user_id", from_user_id);
                        hm.put("contact_user_id", to_user_id);
                        hm.put("dec_name", contact_name);
                        hm.put("advanced_relation_type", connection);
                        hm.put("approval_status", approval_status);
                        hm.put("rs_id", rs_id);
                        hm.put("direction", direction);
                        hm.put("dec_mobile", contact_number);
                        hm.put("dec_email", contact_mail);

                        contact_list.add(hm);

                        return contact_list;

//                        status = getStringForContacts(from_user_id, contact_name, contact_number, contact_mail, connection_str, approval_status, rs_id);
                    }
                }
            }
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.print(new Date()+"\t "+se.getMessage());
            HashMap hm = new HashMap();
            hm.put("status", "failed");
            contact_list.add(hm);

            return contact_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        HashMap hm = new HashMap();
        hm.put("status", "failed");
        contact_list.add(hm);

        return contact_list;
    }

    String sql_get_relationship_details = "select * from relationship where rs_id = ?";
    String sql_update_relationship = "update relationship set advanced_relation_type = ?, approval_status = ? where rs_id = ?";
    String sql_update_relationship_inverse = "update relationship set advanced_relation_type = ?, approval_status = ? where from_user_id = ? and to_user_id = ? and relation_type = ?";

    public String updateContactRelationship(String rs_id, String connection, String direction) {
        String status = "failed";

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        int approval_status = 1;

        if(direction.equalsIgnoreCase("forward") && connection.equals("2")) {
            approval_status = 0;
        } else if(direction.equalsIgnoreCase("inverse") && connection.equals("3")) {
            approval_status = 0;
        }

        try {
            con = getConnection();

            ps = getPs(con, sql_update_relationship);

            ps.setString(1, connection);
            ps.setInt(2, approval_status);
            ps.setString(3, rs_id);

            int cnt = ps.executeUpdate();

            if(cnt > 0) {
                status = "success";

                //get the relationship details and update advanced_relation_type in reverse order

                ps = getPs(con, sql_get_relationship_details);
                ps.setString(1, rs_id);
                rs = ps.executeQuery();

                if(rs.next()) {
                    int from_user_id = rs.getInt("from_user_id");
                    int to_user_id = rs.getInt("to_user_id");
                    int relation_type = rs.getInt("relation_type");

                    int advanced_relation_type = 0;

                    if(connection.equalsIgnoreCase("2")) {
                        advanced_relation_type = 3;
                    } else if(connection.equalsIgnoreCase("3")) {
                        advanced_relation_type = 2;
                    } else if(connection.equalsIgnoreCase("1")) {
                        advanced_relation_type = 1;
                    }

                    //Update relationship type for the users in reverse way, only if exists. Otherwise, it ignores
                    ps = getPs(con, sql_update_relationship_inverse);

                    ps.setInt(1, advanced_relation_type);
                    ps.setInt(2, approval_status);
                    ps.setInt(3, to_user_id);
                    ps.setInt(4, from_user_id);
                    ps.setInt(5, relation_type);

                    cnt = ps.executeUpdate();
                }

                addToInvitationsQueue(con, rs_id);
            }
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.print(new Date()+"\t "+se.getMessage());
            return status;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    //TODO, review inner queries

    String sql_get_invite_details = "select (select from_user_id from relationship where rs_id = ?) as from_userid, (select name from users where user_id = from_userid) as from_name, u.user_id as to_userid, u.name as to_name, u.email as to_email, u.mobile as to_mobile, rs.relation_type, rs.advanced_relation_type " +
            "from users u, relationship rs " +
            "where u.user_id = rs.to_user_id and rs.rs_id = ?";
    String sql_add_to_invitations_queue = "insert into user_invitations(from_userid, from_name, to_userid, to_name, to_email, to_mobile, connection, invitation_type, invitation_status) values(?, ?, ?, ?, ?, ?, ?, ?, ?)";
    String sql_check_invite_status = "select * from user_invitations where to_userid = ? and invitation_type = ? and invitation_status = 1";
    String sql_update_invite_status = "update user_invitations set invitation_status = 1, invitation_sent_time = NOW() where inv_id = ?";

    public void addToInvitationsQueue(Connection con, String rs_id) {
        PreparedStatement ps = null;
        ResultSet rs = null;

        int relation_type = 0;
        int advanced_relation_type = 0;
        String connection = "no_relation";
        byte[] from_name_enc;
        byte[] to_name_enc;
        byte[] to_email_enc;
        byte[] to_mobile_enc;
        int from_userid = 0;
        int to_userid = 0;
        int invitation_status = 0;

        try {
            ps = getPs(con, sql_get_invite_details);
            ps.setString(1, rs_id);
            ps.setString(2, rs_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                from_userid = rs.getInt("from_userid");
                from_name_enc = rs.getBytes("from_name");
                to_userid = rs.getInt("to_userid");
                to_name_enc = rs.getBytes("to_name");
                to_email_enc = rs.getBytes("to_email");
                to_mobile_enc = rs.getBytes("to_mobile");

                relation_type = rs.getInt("relation_type");
                advanced_relation_type = rs.getInt("advanced_relation_type");

                if(advanced_relation_type == 1) {                                //0 - no relation; 1 - friend; 2 - client; 3 - freelancer
                    connection = "Friend";
                } else if(advanced_relation_type == 2) {
                    connection = "Client";
                } else if(advanced_relation_type == 3) {
                    connection = "Professional";
                }

                int inv_id = addToAppInvitationTrack(con, from_userid, from_name_enc, to_userid, to_name_enc, to_email_enc, to_mobile_enc, connection, relation_type, invitation_status);

                if(inv_id > 0) {
                    checkAndInviteUserFirstTime(con, inv_id, to_userid, from_name_enc, to_name_enc, to_email_enc, to_mobile_enc, connection, relation_type);
                }
            }
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.print(new Date()+"\t "+se.getMessage());
        }
    }

    public int addToAppInvitationTrack(Connection con, int from_userid, byte[] from_name_enc, int to_userid, byte[] to_name_enc, byte[] to_email_enc, byte[] to_mobile_enc, String connection, int relation_type, int invitation_status) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        int inv_id = -1;

        try {
            ps = con.prepareStatement(sql_add_to_invitations_queue, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, from_userid);
            ps.setBytes(2, from_name_enc);
            ps.setInt(3, to_userid);
            ps.setBytes(4, to_name_enc);
            ps.setBytes(5, to_email_enc);
            ps.setBytes(6, to_mobile_enc);
            ps.setString(7, connection);
            ps.setInt(8, relation_type);
            ps.setInt(9, invitation_status);

            int cnt = ps.executeUpdate();

            if(cnt == 1) {
                rs = ps.getGeneratedKeys();
                if(rs.next()) {
                    inv_id = rs.getInt(1);

                    if(invitation_status == 1) {
                        ps = getPs(con, sql_update_invite_status);
                        ps.setInt(1, inv_id);

                        int update_cnt = ps.executeUpdate();
                    }
                }
            }
        } catch(Exception se) {
            System.err.print(new Date()+"\t addToAppInvitationTrack -> Could not add. from_userid: "+from_userid+", to_userid: "+to_userid);
            se.printStackTrace();
            return inv_id;
        }
        return inv_id;
    }

    public void checkAndInviteUserFirstTime(Connection con, int inv_id, int to_userid, byte[] from_name_enc, byte[] to_name_enc, byte[] to_email_enc, byte[] to_mobile_enc, String connection, int relation_type) {
        PreparedStatement ps = null;
        ResultSet rs = null;

        String from_name;
        String to_name;
        String to_email;
        String to_mobile;
        boolean user_already_invited = false;

        try {
            ps = getPs(con, sql_check_invite_status);
            ps.setInt(1, to_userid);
            ps.setInt(2, relation_type);
            rs = ps.executeQuery();

            if(rs.next()) {
                // User was already invited by this user or others'. Do nothing. Remaining invitations will be done in bulk (like every end of the day, weekly once, after every 5 entries... yet to decide this...)
                System.out.println(new Date()+"\t User "+to_userid+" was already invited for the first time. Do nothing...");
                user_already_invited = true;
            }

            if(!user_already_invited) {
                if(relation_type == 1) {                                         //0 - no relation; 1 - phone_contact; 2 - fb_friend
                    from_name = new String(processDecrypt(from_name_enc));
                    to_name = new String(processDecrypt(to_name_enc));
                    to_mobile = new String(processDecrypt(to_mobile_enc));

                    System.out.println(new Date()+"\t Inviting1 "+to_name+" ("+to_mobile+"), from_name: "+from_name+", as: "+connection);
//                    inviteUser_SMS(from_name, to_mobile, connection);

                    //update the invitation status

                    ps = getPs(con, sql_update_invite_status);
                    ps.setInt(1, inv_id);
                    ps.executeUpdate();
                } else if(relation_type == 2) {                                  //0 - no relation; 1 - phone_contact; 2 - fb_friend
                    //TODO, send email?
                }
            }
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.print(new Date()+"\t "+se.getMessage());
        }
    }

    public void checkAndInviteUserFirstTime(Connection con, String rs_id) {
        PreparedStatement ps = null;
        ResultSet rs = null;

        int invite_status = 0;      //0 - not_sent; 1 - sms_sent; 2 - mail_sent
        int relation_type = 0;
        int advanced_relation_type = 0;
        String connection = "no_relation";
        byte[] from_name_enc;
        byte[] to_mobile_enc;
        String from_name;
        String to_mobile;

        try {
            ps = getPs(con, sql_check_invite_status);
            ps.setString(1, rs_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                // User was already invited. Do nothing
                System.out.println(new Date()+"\t User was already invited. Do nothing -> rs_id: "+rs_id);
            } else {
                ps = getPs(con, sql_get_invite_details);

                ps.setString(1, rs_id);
                ps.setString(2, rs_id);

                rs = ps.executeQuery();

                if(rs.next()) {
                    from_name_enc = rs.getBytes("from_name");
                    to_mobile_enc = rs.getBytes("to_mobile");

                    relation_type = rs.getInt("relation_type");
                    advanced_relation_type = rs.getInt("advanced_relation_type");

                    if(advanced_relation_type == 1) {                                //0 - no relation; 1 - friend; 2 - client; 3 - freelancer
                        connection = "Friend";
                    } else if(advanced_relation_type == 2) {
                        connection = "Client";
                    } else if(advanced_relation_type == 3) {
                        connection = "Freelancer";
                    }

                    if(relation_type == 1) {                                         //0 - no relation; 1 - phone_contact; 2 - fb_friend
                        from_name = new String(processDecrypt(from_name_enc));
                        to_mobile = new String(processDecrypt(to_mobile_enc));
                        System.out.println(new Date()+"\t Inviting2 "+to_mobile+", from_name: "+from_name+", connection: "+connection);
//                        inviteUser_SMS(from_name, to_mobile, connection);
                    } else {
                        //DO nothing for now
                    }
                }
            }
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.print(new Date()+"\t "+se.getMessage());
        }
    }

    //    String sql_app_invite_user_details = "select (select name from users where user_id = ?) as name, u.mobile, r.* from users u, relationship r where r.to_user_id = u.user_id and rs_id = ? ";
//    String sql_app_invite_user_details = "select (select name as profile_name from users where user_id = ?) as profile_name, (select mobile from users where user_id = ?) as to_mobile";
    String sql_app_invite_user_details1 = "select u.name as profile_name, rs.to_contact_name from users u, relationship rs where u.user_id = rs.from_user_id and u.user_id = ? and rs.to_user_id = ?";
    String sql_app_invite_user_details2 = "select u.mobile as to_mobile, email from users u where u.user_id = ?";

    public void appInvite(int from_user_id, int contact_user_id, String rs_id, String from_country_code) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String from_name = "";
        String to_contact_name = "";
        String to_mobile = "";
        String to_email = "";

        byte[] fl_name_enc = new byte[0];
        byte[] to_contact_name_enc = new byte[0];
        byte[] to_mobile_enc = new byte[0];
        byte[] to_email_enc = new byte[0];

        boolean flag1 = false;
        boolean flag2 = false;

        try {
            con = getConnection();

            ps = getPs(con, sql_app_invite_user_details1);
            ps.setInt(1, from_user_id);
            ps.setInt(2, contact_user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                fl_name_enc = rs.getBytes("profile_name");
                byte[] fl_name_ba = processDecrypt(fl_name_enc);
                from_name = new String(fl_name_ba);

                to_contact_name_enc = rs.getBytes("to_contact_name");
                byte[] to_contact_name_ba = processDecrypt(to_contact_name_enc);
                to_contact_name = new String(to_contact_name_ba);

                if(to_mobile.startsWith("0")) {
                    to_mobile = to_mobile.replaceFirst("0","");
                }

                if(to_mobile.indexOf("+") != 0) {
                    to_mobile = from_country_code+""+to_mobile;
                }
                flag1 = true;
            }

            ps = getPs(con, sql_app_invite_user_details2);
            ps.setInt(1, contact_user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                to_mobile_enc = rs.getBytes("to_mobile");
                byte[] to_mobile_ba = processDecrypt(to_mobile_enc);
                to_mobile = new String(to_mobile_ba);

                to_email_enc = rs.getBytes("email");
                byte[] to_email_ba = processDecrypt(to_email_enc);
                to_email = new String(to_email_ba);

                flag2 = true;
            }

            if(flag1 && flag2) {
                System.out.println(new Date()+"\t inviteApp_SMS -> from_user_id: "+from_user_id+",contact_user_id: "+contact_user_id+", from_name: "+from_name+", to_contact_name: "+to_contact_name);

                if(server_type.equalsIgnoreCase("test")) {
                    boolean status = getAppInviteStatusForMsg(con, to_mobile_enc);
                    //true - send the message for the current day; false - do not send the message

                    if(status) {
                        System.out.println(new Date()+"\t appInvite -> sending app invite to "+test_mobile_number+" on behalf of: "+to_mobile);
                        inviteApp_SMS(from_name, test_mobile_number);
                    } else {
                        System.out.println(new Date()+"\t appInvite -> app invite already sent for today to "+test_mobile_number);
                    }
                } else if (server_type.equalsIgnoreCase("prod")) {
                    System.out.println(new Date()+"\t appInvite -> sending app invite to "+to_mobile);
                    inviteApp_SMS(from_name, to_mobile);
                }

                int inv_id = addToAppInvitationTrack(con, from_user_id, fl_name_enc, contact_user_id, to_contact_name_enc, to_email_enc, to_mobile_enc, "AppInvite", 1, 1);
            }
        } catch(Exception se) {
            System.out.println(new Date()+"\t appInvite -> could not send invitation, to_mobile: "+to_mobile+", from_user_id: "+from_user_id);
            se.printStackTrace();
        } finally {
            if (con != null) {
                closeConnection(con);
            }
        }
    }

    String sql_user_details = "select * from users u where u.user_id = ?";

    public void remindAppInvite(int source_user_id, int dest_user_id, String from_country_code) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String from_name = "";
        String to_contact_name = "";
        String to_mobile = "";
        String to_email = "";

        byte[] fl_name_enc = new byte[0];
        byte[] to_contact_name_enc = new byte[0];
        byte[] to_mobile_enc = new byte[0];
        byte[] to_email_enc = new byte[0];

        boolean flag1 = false;
        boolean flag2 = false;

        try {
            con = getConnection();

            ps = getPs(con, sql_user_details);
            ps.setInt(1, source_user_id);

            rs = ps.executeQuery();

            if(rs.next()) {
                try {
                    fl_name_enc = rs.getBytes("name");
                    byte[] fl_name_ba = processDecrypt(fl_name_enc);
                    from_name = new String(fl_name_ba);
                } catch (Exception e) {
                    System.out.println(new Date()+"\t remindAppInvite -> Could not get the from_name; source_user_id: "+source_user_id+", dest_user_id: "+dest_user_id);
                }

/*
                to_contact_name_enc = rs.getBytes("to_contact_name");
                byte[] to_contact_name_ba = processDecrypt(to_contact_name_enc);
                to_contact_name = new String(to_contact_name_ba);
*/
                flag1 = true;
            }

            ps = getPs(con, sql_user_details);
            ps.setInt(1, dest_user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                try {
                    to_mobile_enc = rs.getBytes("mobile");
                    byte[] to_mobile_ba = processDecrypt(to_mobile_enc);
                    to_mobile = new String(to_mobile_ba);
                } catch (Exception e) {
                    System.out.println(new Date()+"\t remindAppInvite -> Could not get the to_mobile; source_user_id: "+source_user_id+", dest_user_id: "+dest_user_id);
                }
                try {
                    to_email_enc = rs.getBytes("email");
                    byte[] to_email_ba = processDecrypt(to_email_enc);
                    to_email = new String(to_email_ba);
                } catch (Exception e) {
                    System.out.println(new Date()+"\t remindAppInvite -> Could not get the to_email; source_user_id: "+source_user_id+", dest_user_id: "+dest_user_id);
                }

                if(to_mobile.startsWith("0")) {
                    to_mobile = to_mobile.replaceFirst("0","");
                }

                if(to_mobile.indexOf("+") != 0) {
                    to_mobile = from_country_code+""+to_mobile;
                }

                flag2 = true;
            }

            System.out.println(new Date()+"\t flag1: "+flag1);
            System.out.println(new Date()+"\t flag2: "+flag2);

            if(flag1 && flag2) {
                System.out.println(new Date()+"\t remindApp_SMS -> source_user_id: "+source_user_id+",dest_user_id: "+dest_user_id+", from_name: "+from_name+", to_contact_name: "+to_contact_name);

                try {
//                    remindAppInvite_SMS(from_name, to_mobile);
                } catch (Exception e) {
                    System.out.println(new Date()+"\t remindAppInvite_SMS -> Could not send SMS; source_user_id: "+source_user_id+", dest_user_id: "+dest_user_id);
                }

                int inv_id = addToAppInvitationTrack(con, source_user_id, fl_name_enc, dest_user_id, to_contact_name_enc, to_email_enc, to_mobile_enc, "InviteReminder", 1, 1);
            }
        } catch(Exception se) {
            System.out.println(new Date()+"\t remindAppInvite -> could not send invitation, to_mobile: "+to_mobile+", source_user_id: "+source_user_id);
            se.printStackTrace();
        } finally {
            if (con != null) {
                closeConnection(con);
            }
        }
    }
%>

<%!
 

    HashMap<String, String> test_numbers = new HashMap<String, String>();

    public String sendVerificationCodeToMobile_Twilio(String mobilenum, String verification_code) {

        //adding phone numbers not to send SMS to them, for development and testing
//        test_numbers.put("+919901424531", "Satya");
        test_numbers.put("+918105575151", "Srikanth");
        test_numbers.put("+919844408661", "Sridhar");
        test_numbers.put("+918951092157", "Ajay");
        test_numbers.put("+919090909090", "Test1");
        test_numbers.put("+919090909091", "Test2");
        test_numbers.put("+919090909092", "Test3");
        test_numbers.put("+919012345678", "Test3");

        if(test_numbers.get(mobilenum) != null) {
            return "test_queued";
        }

        String msg = "Thanks for choosing Netref. Verification code for your mobile is: "+verification_code+".";

        TwilioRestClient client = new TwilioRestClient(LIVE_ACCOUNT_SID, LIVE_AUTH_TOKEN);

        Account account = client.getAccount();

        MessageFactory messageFactory = account.getMessageFactory();
        List<NameValuePair> params = new ArrayList<NameValuePair>();
        params.add(new BasicNameValuePair("To", mobilenum));
        params.add(new BasicNameValuePair("From", From_PhoneNumber));
        params.add(new BasicNameValuePair("Body", msg));
        Message sms = null;

        try {
            sms = messageFactory.create(params);

            //TODO, just for safe
            Thread.sleep(1000);

            if(sms != null) {
                return sms.getStatus();
            }
        } catch (TwilioRestException e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return "failed";
        } catch (InterruptedException e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        }

        return "failed";
    }

    public String sendResponse_SMS(String from_name, String to_mobile, String comments) {
        String msg = "Hi, "+(from_name != null && from_name.length() > 0 ? from_name:"Someone") +" recommended a professional "+comments+" for the post requested by you. Start here: https://goo.gl/Njkmxu";

        TwilioRestClient client = new TwilioRestClient(LIVE_ACCOUNT_SID, LIVE_AUTH_TOKEN);

        Account account = client.getAccount();

        MessageFactory messageFactory = account.getMessageFactory();
        List<NameValuePair> params = new ArrayList<NameValuePair>();
        params.add(new BasicNameValuePair("To", to_mobile));
        params.add(new BasicNameValuePair("From", From_PhoneNumber));
        params.add(new BasicNameValuePair("Body", msg));
//        params.add(new BasicNameValuePair("MediaUrl", "https://goo.gl/Njkmxu"));
        Message sms = null;

        try {
            sms = messageFactory.create(params);

            //TODO, just for safe
            Thread.sleep(1000);

            if(sms != null) {
                return sms.getStatus();
            }
        } catch (TwilioRestException e) {
            e.printStackTrace();
            return "failed";
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        return "failed";
    }

    public String sendResponse_SMS_to_Professional(String loggedin_username, String activity_ownername, String to_mobile) {
        String msg = "Hi, you have been referred by "+(loggedin_username != null && loggedin_username.length() > 0 ? loggedin_username:"Someone") +" as professioal to the client "+activity_ownername+". Start here: https://goo.gl/Njkmxu";

        TwilioRestClient client = new TwilioRestClient(LIVE_ACCOUNT_SID, LIVE_AUTH_TOKEN);

        Account account = client.getAccount();

        MessageFactory messageFactory = account.getMessageFactory();
        List<NameValuePair> params = new ArrayList<NameValuePair>();
        params.add(new BasicNameValuePair("To", to_mobile));
        params.add(new BasicNameValuePair("From", From_PhoneNumber));
        params.add(new BasicNameValuePair("Body", msg));
//        params.add(new BasicNameValuePair("MediaUrl", "https://goo.gl/Njkmxu"));
        Message sms = null;

        try {
            sms = messageFactory.create(params);

            //TODO, just for safe
            Thread.sleep(1000);

            if(sms != null) {
                return sms.getStatus();
            }
        } catch (TwilioRestException e) {
            e.printStackTrace();
            return "failed";
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        return "failed";
    }

    public String inviteApp_SMS(String from_name, String to_mobile) {
//        String msg = "Hi, "+(from_name != null && from_name.length() > 0 ? from_name:"Someone") +" wants your feedback about Netref. You can download it from: https://goo.gl/Njkmxu";
        
        String msg = "Hi, "+(from_name != null && from_name.length() > 0 ? from_name:"Someone") +" invites you to try Netref. " +
                "Download the iOS link from https://goo.gl/nyeq2m or the Android link from https://goo.gl/Njkmxu";

        TwilioRestClient client = new TwilioRestClient(LIVE_ACCOUNT_SID, LIVE_AUTH_TOKEN);

        Account account = client.getAccount();

        MessageFactory messageFactory = account.getMessageFactory();
        List<NameValuePair> params = new ArrayList<NameValuePair>();
        params.add(new BasicNameValuePair("To", to_mobile));
        params.add(new BasicNameValuePair("From", From_PhoneNumber));
        params.add(new BasicNameValuePair("Body", msg));
//        params.add(new BasicNameValuePair("MediaUrl", "https://goo.gl/Njkmxu"));
        Message sms = null;

        try {
            sms = messageFactory.create(params);

            //TODO, just for safe
            Thread.sleep(1000);

            if(sms != null) {
                return sms.getStatus();
            }
        } catch (TwilioRestException e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return "failed";
        } catch (InterruptedException e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        }

        return "failed";
    }

    public String remindAppInvite_SMS(String from_name, String to_mobile) {
        String msg = "Reminder: "+(from_name != null && from_name.length() > 0 ? from_name:"Someone") +" would like you to join on Netref. You can download it from: https://goo.gl/Njkmxu";

        System.out.println(new Date()+"\t remindAppInvite_SMS: "+msg);

        TwilioRestClient client = new TwilioRestClient(LIVE_ACCOUNT_SID, LIVE_AUTH_TOKEN);

        Account account = client.getAccount();

        MessageFactory messageFactory = account.getMessageFactory();
        List<NameValuePair> params = new ArrayList<NameValuePair>();
        params.add(new BasicNameValuePair("To", to_mobile));
        params.add(new BasicNameValuePair("From", From_PhoneNumber));
        params.add(new BasicNameValuePair("Body", msg));
//        params.add(new BasicNameValuePair("MediaUrl", "https://goo.gl/Njkmxu"));
        Message sms = null;

        try {
            sms = messageFactory.create(params);

            //TODO, just for safe
            Thread.sleep(1000);

            if(sms != null) {
                return sms.getStatus();
            }
        } catch (TwilioRestException e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return "failed";
        } catch (InterruptedException e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        }

        return "failed";
    }

    public String reminder_SMS(String from_name, String to_mobile) {
        String msg = (from_name != null && from_name.length() > 0 ? from_name:"Someone") +" wants your feedback about Netref. You can download it from: https://goo.gl/Njkmxu";

        TwilioRestClient client = new TwilioRestClient(LIVE_ACCOUNT_SID, LIVE_AUTH_TOKEN);

        Account account = client.getAccount();

        MessageFactory messageFactory = account.getMessageFactory();
        List<NameValuePair> params = new ArrayList<NameValuePair>();
        params.add(new BasicNameValuePair("To", to_mobile));
        params.add(new BasicNameValuePair("From", From_PhoneNumber));
        params.add(new BasicNameValuePair("Body", msg));
//        params.add(new BasicNameValuePair("MediaUrl", "https://goo.gl/Njkmxu"));
        Message sms = null;

        try {
            sms = messageFactory.create(params);

            //TODO, just for safe
            Thread.sleep(1000);

            if(sms != null) {
                return sms.getStatus();
            }
        } catch (TwilioRestException e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return "failed";
        } catch (InterruptedException e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        }

        return "failed";
    }

    public String inviteUser_SMS(String from_name, String to_mobile, String connection) {
        String msg = "Hi, "+(from_name != null && from_name.length() > 0 ? from_name:"Someone") +" added you as "+connection+". ";

        if(connection.equalsIgnoreCase("professional")) {
            msg += "Fill up your skills to be found by potential clients. ";
        }

        msg += "Start here: https://goo.gl/Njkmxu";

        TwilioRestClient client = new TwilioRestClient(LIVE_ACCOUNT_SID, LIVE_AUTH_TOKEN);

        Account account = client.getAccount();

        MessageFactory messageFactory = account.getMessageFactory();
        List<NameValuePair> params = new ArrayList<NameValuePair>();
        params.add(new BasicNameValuePair("To", to_mobile));
        params.add(new BasicNameValuePair("From", From_PhoneNumber));
        params.add(new BasicNameValuePair("Body", msg));
//        params.add(new BasicNameValuePair("MediaUrl", "https://goo.gl/Njkmxu"));
        Message sms = null;

        try {
            sms = messageFactory.create(params);

            //TODO, just for safe
            Thread.sleep(1000);

            if(sms != null) {
                return sms.getStatus();
            }
        } catch (TwilioRestException e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return "failed";
        } catch (InterruptedException e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        }

        return "failed";
    }

    public static String generateVerificationCode() {
        int nextLength = 4;
        StringBuffer buffer = new StringBuffer(4);
        int nextCharAt;
        for (int i = 0; i < nextLength; i++) {
            nextCharAt = (getNextRandomInt()) % 10;
            buffer.append(nextCharAt);
        }
        return buffer.toString();
    }

    final static String sql_insertMobileDetails_2 = "insert into verify_mobile(user_id, verification_code, verified) values(?, ?, ?) ";
    final static String sql_verifyMobileCode = "SELECT u.user_id, vm.verification_code FROM verify_mobile vm, users u WHERE vm.user_id = u.user_id and u.mobile = ? order by create_time DESC";
    final static String sql_updateVerificationStatus = "update verify_mobile set verified = ? where user_id = ? and mobile = ? and verification_code = ?";

    public boolean insertMobile(long userId, byte[] mobile_bytes, String verification_code) {

        Connection con = null;
        PreparedStatement insertMobile = null;

        try {
            con = getConnection();

            insertMobile = getPs(con, sql_insertMobileDetails_2);

            insertMobile.setLong(1, userId);
            insertMobile.setString(2, verification_code);
            insertMobile.setInt(3, 0);

            int s = insertMobile.executeUpdate();

            if (s > 0) {
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeConnection(con);
        }
    }

    public int verifyMobileCode(String mobilenum, String verification_code) {
        Connection con = null;
        PreparedStatement verifyMobileCode = null, updateStatus = null;
        ResultSet rs = null;

        int userId = -1;

        try {
            con = getConnection();

            byte[] mobile_bytes = processEncrypt(mobilenum);

            verifyMobileCode = getPs(con, sql_verifyMobileCode);
            verifyMobileCode.setBytes(1, mobile_bytes);

            rs = verifyMobileCode.executeQuery();

            if (rs.next()) {
                String db_code = rs.getString("verification_code");
                if(verification_code.equalsIgnoreCase(db_code)) {
                    userId = rs.getInt("user_id");
                    return userId;
                } else if(verification_code.equalsIgnoreCase("1234")) {         //TODO, Temporary logic till we finalize the SMS gateway
                    userId = rs.getInt("user_id");
                    return userId;
                }
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return userId;
        } finally {
            closeConnection(con);
        }
        return userId;
    }

    String sql_checkPhoneNumber = "select * from users where mobile = ?";
    String sql_insertPhoneContact = "insert into users (mobile, device_id, registered) values (?, ?, ?)";
    String sql_updateContactRegisterStatus = "update users set registered = ? where user_id = ?";

    String sql_checkDeviceIMEINumber = "select * from users where device_id = ?";
    String sql_checkDeviceIMEINumberForUser = "select * from users where mobile = ? and device_id = ?";
    String sql_checkDeviceIMEINumberForUser2 = "select * from users where device_id = ?";
    String sql_insertDeviceIMEINumber = "insert into users (device_id, registered) values (?, ?)";

    String sql_updateMobileNumber = "update users set mobile = ? where user_id = ?";
    String sql_updateDeviceIMEINumber = "update users set device_id = ? where user_id = ?";

    public int registerPhoneNumberIfNotExists(String country_code, String phonenum, String deviceIMEI) {
        ResultSet rs = null;
        Connection con = null;
        PreparedStatement ps = null;

        String mobile = country_code+""+phonenum;
        int registered = 1;

        int user_id = -1;

        //-- If mobileno already exists
        //      -- if imei exists - do nothing
        //      -- else - update imei
        //-- else
        //      -- if imei exists - update mobile no
        //      -- else - insert new entry

        try {
            con = getConnection();

            byte[] mobile_enc = processEncrypt(mobile);

//        Check and insert if the phone registration doesn't exist

            ps = getPs(con, sql_checkPhoneNumber);
            ps.setBytes(1, mobile_enc);
            rs = ps.executeQuery();

            if (rs.next()) {                                    //If mobileno already exists
                user_id = rs.getInt(1);

                ps = getPs(con, sql_checkDeviceIMEINumberForUser);
                ps.setBytes(1, mobile_enc);
                ps.setString(2, deviceIMEI);
                rs = ps.executeQuery();

                if (rs.next()) {                                //if imei exists - do nothing
                    //Do Nothing
                } else {
                    ps = getPs(con, sql_updateDeviceIMEINumber);
                    ps.setString(1, deviceIMEI);
                    ps.setInt(2, user_id);
                    ps.executeUpdate();
                }

                ps = getPs(con, sql_updateContactRegisterStatus);

                ps.setInt(1, registered);          //registered - 1 - yes
                ps.setInt(2, user_id);
                ps.executeUpdate();
            } else {
                ps = getPs(con, sql_checkDeviceIMEINumberForUser);
                ps.setBytes(1, mobile_enc);
                ps.setString(2, deviceIMEI);
                rs = ps.executeQuery();

                if (rs.next()) {
                    user_id = rs.getInt(1);

                    ps = getPs(con, sql_updateMobileNumber);
                    ps.setBytes(1, mobile_enc);
                    ps.setInt(2, user_id);
                    ps.executeUpdate();

                    ps = getPs(con, sql_updateContactRegisterStatus);

                    ps.setInt(1, registered);          //registered - 1 - yes
                    ps.setInt(2, user_id);
                    ps.executeUpdate();
                } else {
                    ps = con.prepareStatement(sql_insertPhoneContact, Statement.RETURN_GENERATED_KEYS);
                    ps.setBytes(1, mobile_enc);
                    ps.setString(2, deviceIMEI);
                    ps.setInt(3, 1);                //Registered - Yes

                    int id = ps.executeUpdate();
                    if(id == 1) {
                        rs = ps.getGeneratedKeys();
                        if(rs.next())
                            user_id = rs.getInt(1);
                    }
                }
            }
        } catch (Throwable t) {
            System.out.println(new Date()+"\t "+t.getMessage());
            t.printStackTrace();
        } finally {
            if(con != null)
                closeConnection(con);
        }
        return user_id;
    }

    public int registerIMEIIfNotExists(String deviceIMEI) {
        ResultSet rs = null;
        Connection con = null;
        PreparedStatement ps = null;
        int registered = 0;

        int user_id = 0;

        try {
            con = getConnection();

//        Check and insert if the phone registration with deviceIMEI doesn't exist

            ps = getPs(con, sql_checkDeviceIMEINumber);
            ps.setString(1, deviceIMEI);
            rs = ps.executeQuery();

            if (rs.next()) {
                user_id = rs.getInt(1);
            } else {
                ps = con.prepareStatement(sql_insertDeviceIMEINumber, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, deviceIMEI);
                ps.setInt(2, registered);                //Registered - Assuming No for Skip login

                int id = ps.executeUpdate();
                if(id == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next())
                        user_id = rs.getInt(1);
                }
            }
        } catch (Throwable t) {
            System.out.println(new Date()+"\t "+t.getMessage());
            t.printStackTrace();
        } finally {
            if(con != null)
                closeConnection(con);
        }
        return user_id;
    }

    String sql_get_suggested_professions = "select profession from list_of_professions";
    public ArrayList getSuggestedProfessions() {
        Connection con = null;
        PreparedStatement psPros = null;
        ResultSet rs = null;
        ArrayList suggestedProfessionList = new ArrayList();

        try {
            con = getConnection();
            psPros = getPs(con, sql_get_suggested_professions);
            rs = psPros.executeQuery();

            while (rs.next()) {
                String prof = rs.getString(1);

                if(prof == null || prof.trim().length() <= 0) {
                    continue;
                }

                prof = prof.replaceAll(";",",");

                String splited_prof_by_comma[] = prof.split(",");
                for(int i = 0; i < splited_prof_by_comma.length; i++) {
                    String keyword = splited_prof_by_comma[i].trim();

                    if(!suggestedProfessionList.contains(keyword)) {
                        suggestedProfessionList.add(keyword);
                    }
                }
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            return suggestedProfessionList;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        Collections.sort(suggestedProfessionList);
        return suggestedProfessionList;
    }

    String get_suggested_keywords = "select expertise from skills";
    public ArrayList getSuggestedKeywords() {
        Connection con = null;
        PreparedStatement getSKeyword = null;
        ResultSet rs = null;
        ArrayList suggestedKeywordsList = new ArrayList();

        try {
            con = getConnection();
            getSKeyword = getPs(con, get_suggested_keywords);
            rs = getSKeyword.executeQuery();

            while (rs.next()) {
                String keywords = rs.getString(1);

                if(keywords == null || keywords.trim().length() <= 0) {
                    continue;
                }

                keywords = keywords.replaceAll(";",",");

                String splited_keywords_by_comma[] = keywords.split(",");
                for(int i = 0; i < splited_keywords_by_comma.length; i++) {
                    String keyword = splited_keywords_by_comma[i].toLowerCase().trim();

                    if(!suggestedKeywordsList.contains(keyword)) {
                        suggestedKeywordsList.add(keyword);
                    }
                }
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
//            e.printStackTrace();
            return suggestedKeywordsList;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        Collections.sort(suggestedKeywordsList);
        return suggestedKeywordsList;
    }

    //    String get_app_invite_status_sql = " select distinct (to_userid), invitation_status from user_invitations where connection = 'AppInvite' and from_userid = ?";
    String get_app_invite_status_sql = "  select distinct (ui.to_userid), ui.invitation_status, r.rs_id from user_invitations ui, relationship r where r.to_user_id = ui.to_userid and ui.connection = 'AppInvite' and ui.from_userid = ?";
    public ArrayList getAppInviteStatus(String from_user_id) {
        Connection con = null;
        PreparedStatement getAIC = null;
        ResultSet rs = null;
        ArrayList app_invite_contact_list = new ArrayList();

        String to_userId;
        int invitation_status;
        String rs_id;

        try {
            con = getConnection();
            getAIC = getPs(con, get_app_invite_status_sql);
            getAIC.setString(1, from_user_id);
            rs = getAIC.executeQuery();

            while (rs.next()) {
                to_userId = rs.getString("to_userid");
                invitation_status = rs.getInt("invitation_status");
                rs_id = rs.getString("rs_id");

//                System.out.println("to_userId : "+to_userId+" invitation_status : "+invitation_status);

                HashMap hm = new HashMap();
                hm.put("from_user_id", from_user_id);
                hm.put("to_userId", to_userId);
                hm.put("invitation_status", invitation_status);
                hm.put("rs_id", rs_id);

                app_invite_contact_list.add(hm);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }  finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return app_invite_contact_list;
    }

    /*-----------------------------get Professional detail-----------------*/
    final String sql_getProfessionalDetails = "SELECT u.name as profile_name, u.profile_image_file_name, u.mobile, s.* " +
            "            FROM users u LEFT JOIN skills s " +
            "            ON u.user_id = s.user_id " +
            "            where u.user_id = ?";

    public String getProfessionalDetails(String professional_id, String from_user_id) {
        String  pros_name = "";
        String  pros_image_file_name = "";
        String  pros_profession = "";
        String  pros_expertise = "";
        String  pros_experience = "";
        String  pros_linkedin = "";
        String  pros_about = "";
        String  pros_mobile = "";

        String  pros_details = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_getProfessionalDetails);
            ps.setString(1, professional_id);
            rs = ps.executeQuery();
            System.out.println(new Date()+"\t ps: "+ps);

            if (rs.next()) {
                pros_image_file_name = rs.getString("profile_image_file_name");
                pros_profession = rs.getString("profession");
                pros_expertise = rs.getString("expertise");
                pros_experience = rs.getString("experience");
                pros_linkedin = rs.getString("linkedin");
                pros_about = rs.getString("about");

                try {
                    byte[] pros_mobile_enc = rs.getBytes("mobile");
                    byte[] pros_mobile_ba = processDecrypt(pros_mobile_enc);
                    pros_mobile = new String(pros_mobile_ba);
                }  catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                }

                try {
                    if(pros_image_file_name == null || pros_image_file_name.equalsIgnoreCase("NULL")){
                        pros_image_file_name = "profile.jpg";
                    } else {
                        pros_image_file_name = pros_image_file_name;
                    }
                    pros_profession =  pros_profession != null ?  pros_profession : "";
                    pros_expertise =  pros_expertise != null ?  pros_expertise : "";
                    pros_experience =  pros_experience != null ?  pros_experience : "";
                    pros_linkedin =  pros_linkedin != null ?  pros_linkedin : "";
                    pros_about = pros_about != null ? pros_about : "";

                    pros_details = "<div id='contact_professional_info' style='display: none;'></div>" +
                            "<div class='events pull-left' style=' word-wrap: break-word; width:100%; max-height: 140px; margin-top:3px;line-height:1.0;background-color:#ffffff; display:inline-block; border-radius:4px; overflow: auto; box-shadow: 0.09em 0.09em 0.09em 0.05em #888888; padding:5px 0px 5px 0px;'>" +
                            " <p class='pull-left' style='margin-left:4px;margin-bottom: 0px'> " +
                            " <img class='img-circle' style='main-width:25px;max-width:25px;margin-bottom:10px' src='profile_images/"+pros_image_file_name+"' onError='this.onerror=null;this.src=\"profile_images/profile.jpg\"' >" +
                            " </p>" +
                            " <div class='events-body ' style='margiun-right:0px;'>" +
                            " <div align='left ' class='pull-left' style='margin-bottom:2px'>" +
                            " <h4 class='' style='margin-bottom:2px;font-family:monospace;overflow:auto; font-size-adjust: 0.58;line-height:1.1;font-size:12px;margin-left:8px'> " +
//                            (pros_mobile != null && pros_mobile.trim().length() > 0 ? " Contact: "+pros_mobile +"<br>" : "") +
                            (pros_mobile != null && pros_mobile.trim().length() > 0 ? "" +
                                    "<button id='contact_professional' onclick=\"contactProfessional("+professional_id+" , "+from_user_id+");\" type='button' class='btn btn-info btn-sm' style='display:inline;border-radius:5px; padding: .1rem .3rem; box-shadow: 0.09em 0.09em 0.09em 0.05em #888888; margin-bottom: 5px;'>Contact</button><br>" : "") +
                            (pros_linkedin != null && pros_linkedin.trim().length() > 0 ? " Linkedin: "+pros_linkedin +"<br>" : "") +
                            (pros_profession != null && pros_profession.trim().length() > 0 ? " Profession: "+pros_profession +"<br>" : "") +
                            (pros_experience != null && pros_experience.trim().length() > 0 ? " Experience: "+pros_experience +"<br>" : "") +
                            (pros_expertise != null && pros_expertise.trim().length() > 0 ? " Expertise: "+pros_expertise +"<br>" : "") +
                            (pros_about != null && pros_about.trim().length() > 0 ? " About: "+pros_about +"<br>" : "") +
                            " </h4>" +
                            " </div> " +
                            " </div>" +
                            " </div>" +
                            " <div id='showflcl_59' class='text-left' style='max-width: 100%;margin-top: %;display_none;background-color:#f5f5f5'>" +
                            " </div>";

                } catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                }
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
            return pros_details;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return pros_details;
    }

    //    String get_app_invite_status_for_sms_sql = "select count(ui.to_userid) from user_invitations ui where  ui.connection = 'AppInvite' and ui.to_userid = ? and DATE(invitation_sent_time) = CURDATE()";
    String get_app_invite_status_for_sms_sql = "select count(ui.to_userid) from user_invitations ui where  ui.connection = 'AppInvite' and DATE(invitation_sent_time) = CURDATE()";

    public boolean getAppInviteStatusForMsg(Connection con, byte[] to_mobile_enc) {
        PreparedStatement getAIC = null;
        ResultSet rs = null;
        boolean status = false;

        int inv_count;
        try {
            getAIC = getPs(con, get_app_invite_status_for_sms_sql);
//            getAIC.setBytes(1, to_mobile_enc);
            rs = getAIC.executeQuery();

            while(rs.next()) {
                inv_count = rs.getInt(1);
                if(inv_count <= 0) {
                    status = true;
                } else if(inv_count > 0)
                    status = false;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return status;
    }

    //    String get_verification_code_status_for_sms_sql = "select count(vm.user_id) from verify_mobile vm where vm.user_id = ? and DATE(create_time) = CURDATE()";
    String get_verification_code_status_for_sms_sql = "select count(vm.user_id) from verify_mobile vm where DATE(create_time) = CURDATE()";
    public boolean getverificationSentStatusForTestNumber() {
        Connection con= null;
        PreparedStatement getAIC = null;
        ResultSet rs = null;
        boolean status = false;

        int inv_count;
        try {
            con = getConnection();
            getAIC = getPs(con, get_verification_code_status_for_sms_sql);
//            getAIC.setLong(1, user_id);

            rs = getAIC.executeQuery();

            if(rs.next()) {
                inv_count = rs.getInt(1);
                if(inv_count <= 0) {
                    status = true;
                } else if(inv_count > 0)
                    status = false;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (con != null) {
                closeConnection(con);
            }
        }
        return status;
    }

    public String getimagestatus(String from_user_id, String image_name){
        String image_path = "profile.jpg";
        File check_path = new File(CONTACT_IMAGE_PATH+"\\"+from_user_id+"\\"+image_name);

        if(check_path.exists()) {
            image_path = from_user_id+"/"+image_name;
        }
        return image_path;
    }

    public String getprofileimagestatus(String from_user_id, String image_name){
        String image_path = "Not Avilable";
        File check_path = new File(PROFILE_IMAGE_PATH+"\\"+from_user_id+"\\"+image_name);

        if(check_path.exists()) {
            image_path = image_name;
        }
        return image_path;
    }
%>

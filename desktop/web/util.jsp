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
<%@ page import="javax.mail.internet.MimeMessage" %>
<%@ page import="javax.mail.internet.InternetAddress" %>
<%@ page import="javax.mail.internet.MimeBodyPart" %>
<%@ page import="javax.mail.internet.MimeMultipart" %>
<%@ page import="javax.mail.Authenticator" %>
<%@ page import="javax.mail.PasswordAuthentication" %>
<%@ page import="javax.mail.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.ParseException" %>
<%!
    SimpleDateFormat DAY_MONTH_FORMATTER = new SimpleDateFormat("EEE, MMM d");

    static {
        try{
            Class.forName ("com.mysql.jdbc.Driver").newInstance ();
        } catch (Throwable t){
            t.printStackTrace();
        }
    }

    public Connection getConnection() {
        Connection conn = null;
        try
        {
            String userName = "root";
            String password = "root123";

            String url = "jdbc:mysql://localhost:3306/netref";

            conn = DriverManager.getConnection(url, userName, password);
            return conn;
        } catch (Exception e) {
            System.err.println ("Cannot connect to database host");
            e.printStackTrace();
        }
        return conn;
    }

    public void closeConnection(Connection conn) {
        if (conn == null) return;
        try {
            conn.close ();
        } catch (Exception e) { /* ignore close errors */ }
    }

    String sql_check_fl_map = "Select * from fl_client_map where client_email = (select email from users where user_id = ?) and freelancer_email = ? and status != 2";
    String sql_add_fl = "insert into fl_client_map (client_email, client_name, freelancer_email, freelancer_name, posted_by, status) values((SELECT email FROM users WHERE user_id = ?), (SELECT nickname FROM users WHERE user_id = ?), ?, ?, (SELECT email FROM users WHERE user_id = ?), ?)";

    public String addFreelancer(String freelancer_name, String freelancer_email, String user_id) {
        String res = "failed";
        PreparedStatement ps = null;
        Connection con = null;
        ResultSet rs = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_check_fl_map);
            ps.setString(1, user_id);
            ps.setString(2, freelancer_email);

            rs = ps.executeQuery();

            if(rs.next()) {
                res = "already_exists";
            } else {
                ps = con.prepareStatement(sql_add_fl, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, user_id);
                ps.setString(2, user_id);
                ps.setString(3, freelancer_email);
                ps.setString(4, freelancer_name);
                ps.setString(5, user_id);
                ps.setInt(6, 1);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next()) {
                        int flId = rs.getInt(1);
                        String status_msg = "<td width='20%'>Approval not required</td>";
                        res = getStringForFLs(user_id, freelancer_name, freelancer_email, flId, status_msg);
                    }
                }
            }
        } catch(SQLException se) {
            System.err.print(se.getMessage());
            return res;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return res;
    }

    public String getAllActiveClients(String user_id) {
        Connection con = null;
        PreparedStatement getAC = null;
        ResultSet rs = null;
        String course_list = "";

        try {
            con = getConnection();
            getAC = con.prepareStatement(sql_getAllActiveClients);
            getAC.setString(1, user_id);
            rs = getAC.executeQuery();

            while (rs.next()) {
                int fcm_id = rs.getInt("fcm_id");
                String client_email = rs.getString("client_email");
                String client_name = rs.getString("client_name");
//                String client_userid = rs.getString("user_id");     //TODO, wrong client_userid, it's logged in user_id

                String freelancer_email = rs.getString("freelancer_email");
                String posted_by = rs.getString("posted_by");
                int status = rs.getInt("status");

                String status_msg = "";

                if(posted_by.trim().equalsIgnoreCase(client_email.trim())) {
                    if(status == 1) {
                        status_msg = "Approval not required";
                    } else {
                        status_msg = "Approval pending";
                    }
                } else if(posted_by.trim().equalsIgnoreCase(freelancer_email.trim())) {
                    if(status == 1) {
                        status_msg = "Approved";
                    } else {
                        status_msg = "Approval pending";
                    }
                }

                String tr = getStringForClients(user_id, client_name, client_email, fcm_id, status_msg);

                course_list += tr;
            }
            return course_list;
        } catch (Exception e) {
            e.printStackTrace();
            return "An error occurred while getting active clients. Please try again.";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String getAllActiveFls(String user_id) {
        Connection con = null;
        PreparedStatement getAFLs = null;
        ResultSet rs = null;
        String course_list = "";

        try {
            con = getConnection();
            getAFLs = con.prepareStatement(sql_getAllActiveFls);
            getAFLs.setString(1, user_id);
            rs = getAFLs.executeQuery();

            while (rs.next()) {
                int fcm_id = rs.getInt("fcm_id");
                String freelancer_name = rs.getString("freelancer_name");
                String freelancer_email = rs.getString("freelancer_email");
//                String fl_userid = rs.getString("user_id");     //TODO, wrong FL user_id, it's logged in user_id

                String client_email = rs.getString("client_email");
                String posted_by = rs.getString("posted_by");
                int status = rs.getInt("status");

                String status_msg = "";

                if(posted_by.trim().equalsIgnoreCase(client_email.trim())) {
                    if(status == 1) {
                        status_msg = "<td width='30%'>Approval not required</td>";
                    } else {
                        status_msg = "<td width='30%'>Approval pending</td>";
                    }
                } else if(posted_by.trim().equalsIgnoreCase(freelancer_email.trim())) {
                    if(status == 1) {
                        status_msg = "<td width='30%'>Approved</td>";
                    } else {
                        status_msg = "<td width='30%' id='fcm_"+fcm_id+"'><button id = 'btn_fcm_"+fcm_id+"' class='btn btn-sm btn-fill btn-info' style='width: 70px;' onclick='approveFL("+fcm_id+")'>Approve</button></td>";
                    }
                }

                String tr = getStringForFLs(user_id, freelancer_name, freelancer_email, fcm_id, status_msg);

                course_list += tr;
            }
            return course_list;
        } catch (Exception e) {
            e.printStackTrace();
            return "An error occurred while getting active fls. Please try again.";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String approveFL(String fcm_id) {
        Connection con = null;
        PreparedStatement approveFL = null;

        try {
            con = getConnection();
            approveFL = con.prepareStatement(sql_approveFL);
            approveFL.setInt(1, 1);
            approveFL.setString(2, fcm_id);
            int cnt = approveFL.executeUpdate();

            if(cnt > 0) {
                return "success";
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "failed";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return "failed";
    }

    public String showFLList(String friend_userid) {
        Connection con = null;
        PreparedStatement getFLList = null;
        ResultSet rs = null;
        String course_list = "";

        try {
            con = getConnection();
            getFLList = con.prepareStatement(sql_getAllFLofFriends);
            getFLList.setString(1, friend_userid);

            rs = getFLList.executeQuery();

            while (rs.next()) {
                String freelancer_name = rs.getString("freelancer_name");
                String freelancer_email = rs.getString("freelancer_email");
                String skills = rs.getString("skills");
                String experience = rs.getString("experience");
                String linkedin = rs.getString("linkedin");
                String fl_userid = rs.getString("user_id");

                String tr = getFlList(friend_userid, fl_userid, freelancer_name, freelancer_email, skills, experience, linkedin);

                course_list += tr;
            }
            return course_list;
        } catch (Exception e) {
            e.printStackTrace();
            return "An error occurred while getting freelancer list. Please try again.";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public int checkUserType(String user_id) {
        Connection con = null;
        PreparedStatement getUTPS = null;

        int user_type = 0;  //0 - new, 1 - client, 2 - freelancer

        try {
            con = getConnection();
            getUTPS = con.prepareStatement(sql_checkUserType);

            getUTPS.setString(1, user_id);

            ResultSet getUTRS = getUTPS.executeQuery();

            while (getUTRS.next()) {
                user_type = getUTRS.getInt("user_type");
            }
            return user_type;
        } catch (Exception e) {
            e.printStackTrace();
            return user_type;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public boolean setUserType(String user_id, String user_type) {
        Connection con = null;
        PreparedStatement setUTPS = null;

        try {
            con = getConnection();
            setUTPS = con.prepareStatement(sql_setUserType);

            setUTPS.setString(1, user_id);
            setUTPS.setString(2, user_type);

            int cnt = setUTPS.executeUpdate();

            if(cnt > 0) {
                return true;
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String getStringForClients(String user_id, String client_name, String client_email, int fcm_id, String status_msg) {
        String s = "";

        s = "<tr id='"+fcm_id+"'>" +
                "   <td width='5%'>" +
                "   </td>" +
                "   <td width='15%'>"+client_name+" </td>" +
                "   <td width='25%'>"+client_email+"</td>" +
                "   <td width='20%' class='text-center'>Client</td>" +
                "   <td width='10%' class='td-actions' style='text-align:center;' >" +
                "       <button data-original-title='Share client' data-toggle='modal' type='button' title='Share client' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-share'></i></button>" +
                "       <button data-original-title='Edit client' data-toggle='modal' type='button' title='Edit client' rel='tooltip' class='btn btn-warning btn-simple btn-lg' style='padding: 1px 5px' onclick=\"openCLEditForm('"+client_name+"','"+client_email+"','"+fcm_id+"')\"><i class='fa fa-edit'></i></button>" +
                "       <button data-original-title='Delete client' data-toggle='modal' data-target='#deleteCL_mdl' type='button' title='Delete client' rel='tooltip' class='btn btn-danger btn-simple btn-lg' style='padding: 1px 5px'><i class='fa fa-times'></i></button>" +
                "   </td>" +
                "   <td width='30%'>"+status_msg+"</td>" +

                "</tr>";
        return s;
    }

    public String getStringForFLs(String user_id, String freelancer_name, String freelancer_email, int fcm_id, String status_msg) {
        String s = "";

        s = "<tr id='"+fcm_id+"'>" +
                "   <td width='5%'>" +
                "   </td>" +
                "   <td width='15%'>"+freelancer_name+" </td>" +
                "   <td width='25%'>"+freelancer_email+"</td>" +
                "   <td width='20%' class='text-center'>Freelancer</td>" +
                "   <td width='20%' class='td-actions' style='text-align:center;' >" +
                "       <button data-original-title='Share freelancer' data-toggle='modal' type='button' title='Share freelancer' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-share'></i></button>" +
                "       <button data-original-title='Edit freelancer' data-toggle='modal' type='button' title='Edit freelancer' rel='tooltip' class='btn btn-warning btn-simple btn-lg' style='padding: 1px 5px' onclick=\"openFLEditForm('"+freelancer_name+"','"+freelancer_email+"','"+fcm_id+"')\"><i class='fa fa-edit'></i></button>" +
                "       <button data-original-title='Delete freelancer' data-toggle='modal' data-target='#deleteFL_mdl' type='button' title='Delete freelancer' rel='tooltip' class='btn btn-danger btn-simple btn-lg' style='padding: 1px 5px'><i class='fa fa-times'></i></button>" +
                "   </td>" +
                status_msg+
                "</tr>";
        return s;
    }

    //    final String sql_getAllActiveFls = "select * from users u, user_fl_map ufm where u.user_id = ufm.user_id and ufm.user_id = ?";
    final String sql_getAllActiveFls = "select * from fl_client_map fcm where fcm.client_email = ( select email from users where user_id = ? ) and status != 2";
    final String sql_getAllActiveClients = "select * from fl_client_map fcm where fcm.freelancer_email = ( select email from users where user_id = ? ) and status != 2";

    final String sql_getAllFLofFriends = "select u.user_id, freelancer_name, freelancer_email, skills, experience, linkedin from users u, fl_client_map fcm ,skills s where u.email = fcm.freelancer_email and fcm.client_email = (select email from users where user_id = ?) and s.user_id = u.user_id and u.email not like '%@devsquare.com'"; //filtered @devsqure.com id not to display real id's

    final String sql_getAllDevelopersshare = "select * from freelancer";

    final String sql_getAllSKlist = "select u.nickname, skl.freelancer_email, s.skills, s.experience, s.linkedin, u.user_id " +
            "from sk_list skl, users u, skills s " +
            "where skl.freelancer_email = u.email and u.user_id = s.user_id and u.user_id <> ? and skl.status = 1";

    final String sql_checkUserType = "select * from user_type where user_id = ?";

    final String sql_setUserType = "insert into user_type values (?, ?)";

    final String sql_getFLRecommendCount = "select count(*) as total_count, (select count(*) from activities_responses where fl_userid = ? and recommend_status = 1) as recommend_count from activities_responses where fl_userid = ?";
    final String sql_getFLRecommendCountoffriend = "select count(*) as total_count, (select count(*) from activities_responses where fl_userid = ? and recommend_status = 1) as recommend_count from activities_responses where fl_userid = ?";
    final String sql_getFLRecommendsList = "select u.email, u.nickname, u.fb_photo_path, ar.activity_id, ar.recommend_status, ar.recommended_on from activities_responses ar, users u where ar.recommended_by = u.user_id and ar.fl_userid = ? order by ar.recommended_on DESC";
    final String sql_getFLRecommendsListoffriend = "select u.email, u.nickname, u.fb_photo_path, ar.activity_id, ar.recommend_status, ar.recommended_on from activities_responses ar, users u where ar.recommended_by = u.user_id and ar.fl_userid = (select u.user_id from users u, fl_client_map flp where u.email=flp.freelancer_mail and freelancer_mail=?) order by ar.recommended_on DESC";
    final String sql_checkFLRecommend = "select * from activities_responses where activity_id = ? and recommended_by = ?";
    final String sql_postRecommend = "insert into activities_responses (activity_id, fl_userid, recommended_by, recommend_status) values (?, ?, ?, ?)";
    final String sql_updateRecommend = "update activities_responses set recommend_status = ? where activity_id = ? and fl_userid = ? and recommended_by = ?";
    final String sql_getdatetime = "select * from activities where posted_by = ? and category = \"asks\" and status = 1 ";
    final String sql_getdatetimeactivities = "select * from activities where activity_id = ?";
    final String sql_getdatetimeactivityresponse = "select * from activities_responses where activity_id = ?";
    final String sql_getAskResponsesList = "select u.email, u.nickname, u.fb_photo_path, ar.activity_id, ar.comments, ar.recommended_on from activities_responses ar, users u where ar.recommended_by = u.user_id and ar.activity_id = ? order by ar.recommended_on DESC";

    final String sql_checkAskResponse = "select * from activities_responses where activity_id = ? and recommended_by = ?";
    final String sql_postAskResponse = "insert into activities_responses (activity_id, fl_userid, recommended_by, comments) values (?, ?, ?, ?)";
    final String sql_updateAskResponse = "update activities_responses set comments = ? where activity_id = ? and fl_userid = ? and recommended_by = ?";

    final String sql_getFLUserDetails = "select u.email, u.nickname, u.fb_photo_path, s.skills, s.experience, s.linkedin from users u, skills s where u.user_id = s.user_id and u.email not like '%@devsquare.com' and s.user_id = ?";
    final String sql_getFLSkills = "select * from skills where user_id = ?";
    final String sql_getFLdetails = "select * from fl_client_map where fcm_id = ?";
    final String sql_checkFLSkills = "select * from skills where user_id = ?";
    final String sql_insertFLSkills = "insert into skills (skills, experience, linkedin, user_id) values (?, ?, ?, ?)";
    final String sql_updateFLSkills = "update skills set skills = ?, experience = ?, linkedin = ? where user_id= ?";
    final String sql_updateFLdetails = "update fl_client_map set freelancer_name = ?, freelancer_email= ? where fcm_id =?";
    final String sql_updateCLdetails = "update fl_client_map set client_name = ?, client_email= ? where fcm_id =?";

    final String sql_checkCommentsInNetwork = "select * from activities where posted_by = ? and fl_userid = ? and category = ?";
    final String sql_postCommentsInNetwork = "insert into activities (posted_by, fl_userid, category, comments) values (?, ?, ?, ?)";
    final String sql_updateCommentsInNetwork = "update activities set comments = ? where posted_by = ? and fl_userid = ? and category = ?";

    final String sql_postskCommentsInNetwork = "insert into activities (posted_by, fl_userid, category, comments) values (?, ?, ?, ?)";
    final String sql_updateskCommentsInNetwork = "update activities set comments = ? where posted_by = ? and fl_userid = ? and category = ?";
    final String sql_checkCommentssskInNetwork = "select * from activities where posted_by = ? and fl_userid = ? and category = ?";

    final String sql_checkBroadcastInNetwork = "select * from activities_broadcast where broadcasted_by = ? and activity_id = ? and owner_id = ?";
    final String sql_postBroadcastInNetwork = "insert into activities_broadcast (broadcasted_by, activity_id, owner_id) values (?, ?, ?)";

    final String sql_getUserRole = "select ut.user_type from users u, user_type ut where u.user_id = ut.user_id and u.user_id = ?";
    final String sql_updateUserRole = "update user_type set user_type = ? where user_id = ?";

    final String sql_getFLDetails_For_ClientProject = "select fcm.freelancer_mail from fl_client_map fcm, users u where fcm.client_email = u.email and u.user_id = ? and status = 1";
    final String sql_getClientDetails_For_FLProject = "select fcm.client_email from fl_client_map fcm, users u where fcm.freelancer_mail = u.email and u.user_id = ? and status = 1";

    final String sql_approveFL = "update fl_client_map set status = ? where fcm_id = ?";

    public String getAllDevelopersshare() {
        Connection con = null;
        PreparedStatement getADS = null;
        ResultSet rs = null;
        String course_list = "";

        try {
            con = getConnection();
            getADS = con.prepareStatement(sql_getAllDevelopersshare);
            rs = getADS.executeQuery();

            while (rs.next()) {
                String developer_id = rs.getString("developer_id");
                String developer_name = rs.getString("developer_name");
                String developer_email = rs.getString("developer_email");

                String tr = getStringForDevelopersshare(developer_id, developer_name, developer_email);

                course_list += tr;
            }
            return course_list;
        } catch (Exception e) {
            e.printStackTrace();
            return "An error occurred while getting developers. Please try again.";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String getStringForDevelopersshare(String developer_id, String developer_name, String developer_email) {
        String s = "";

        s = "<tr id='"+developer_id+"'>" +
                "   <td width='20%'>"+developer_name+"</td>" +
                "   <td width='30%'>"+developer_email+"</td>" +
                "   <td width='30%' class='td-actions' style='text-align:center;' >" +
                "       <button data-original-title='Share' data-toggle='modal' type='button' title='Refer' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-share'></i></button>" +
                "   </td>" +
                "</tr>";
        return s;
    }

    public String getDeveloperslistforfriend() {
        Connection con = null;
        PreparedStatement getDLF = null;
        ResultSet rs = null;
        String course_list = "";

        try {
            con = getConnection();
            getDLF = con.prepareStatement(sql_getDeveloperslistforfriend);
            rs = getDLF.executeQuery();

            while (rs.next()) {
                String developer_id = rs.getString("developer_id");
                String developer_name = rs.getString("freelancer_name");
                String developer_email = rs.getString("freelancer_mail");

                String tr = getStringForActivedevelopers(developer_id, developer_name, developer_email);

                course_list += tr;
            }
            return course_list;
        } catch (Exception e) {
            e.printStackTrace();
            return "An error occurred while getting developers list of friend. Please try again.";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    final String sql_getDeveloperslistforfriend = "select * from freelancer";

    public String getStringForActivedevelopers(String developer_id, String developer_name, String developer_email) {
        String s = "";

        s = "<tr id='"+developer_id+"'>" +
                "   <td width='20%'>"+developer_name+"</td>" +
                "   <td width='30%'>"+developer_email+"</td>" +
                "   <td width='30%' class='td-actions' style='text-align:center;' >" +
                "       <button data-original-title='Share' data-toggle='modal' type='button' title='Refer' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-share'></i></button>" +
                "   </td>" +
                "</tr>";
        return s;
    }

    public String getAllSKlist(String user_id) {
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection con = null;

        String msg = "";

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_getAllSKlist);
            ps.setString(1, user_id);
            rs = ps.executeQuery();

            while (rs.next()) {
                String freelancer_name = rs.getString("nickname");
                String freelancer_email = rs.getString("freelancer_email");
                String skills = rs.getString("skills");
                String experience = rs.getString("experience");
                String linkedin = rs.getString("linkedin");
                String fl_userid = rs.getString("user_id");

                String tr = getStringForSKList(freelancer_name, freelancer_email, skills, experience, linkedin, fl_userid);

                msg += tr;
            }
            return msg;
        } catch (Exception e) {
            e.printStackTrace();
            return "An error occurred while getting sk list. Please try again.";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String getStringForSKList(String freelancer_name, String freelancer_email, String skills, String experience, String linkedin_url, String fl_userid) {
        String s = "";
        String recomended_totalforsk = recomendedsk(fl_userid);

        String linkedin_str1 = "<button class=\"btn btn-info btn-simple btn-fill   btn-sm\" style='cursor: pointer;padding: 0px 5px' data-original-title=\"Linkedin profile\" type=\"button\" title=\"\" rel=\"tooltip\"  onclick=\"window.open('"+linkedin_url+"', '_blank')\"><i class=\"fa fa-linkedin\"></i> </button>";
        String linkedin_str = (linkedin_url != null && linkedin_url.trim().length() > 0 ? linkedin_str1 : "N/A");

        s = "<tr id='"+fl_userid+"'>" +
                "<td width='5%'>" +
                "<button data-original-title='Show Recommendations' data-toggle='modal' type='button' id='showrecommendation_of_sks_"+fl_userid+"' title='Show Recommendations' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px;' onclick='showFLRecommendationsOfsk("+fl_userid+");'><i class='fa fa-caret-right'></i></button>" +
                "<button data-original-title='Hide Recommendations' data-toggle='modal' type='button' id='hiderecommendation_of_sks_"+fl_userid+"' title='Hide Recommendations' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px; display: none;' onclick='hiderecommendationsofsk("+fl_userid+");'><i class='fa fa-caret-down'></i></button> </td>" +
                "</td>"+
                "   <td width='20%' style='word-break: break-all;'>"+freelancer_name+" </td>" +
                "   <td width='20%' style='word-break: break-all;'>"+freelancer_email+"</td>" +
                "   <td width='25%' style='word-break: break-all;'>"+skills+"</td>" +
                "   <td width='10%' class='text-center'>"+experience+"</td>" +
                "<td width='25%' style='word-break: break-all;'>"+linkedin_str+"</td>" +
                "   <td width='10%' class='text-center'>"+recomended_totalforsk+"</td>" +
                "<td class='td-actions'>" +
                "    <button id='search_fl_"+fl_userid+"' style='padding: 1px 5px' class='btn btn-info btn-simple btn-lg' rel='tooltip' type='button' data-toggle='modal' data-original-title='Ask in network' onclick=\"enquireFLInNetwork('search_fl', "+fl_userid+"); return false;\">" +
                "        <i class='fa fa-question-circle fa-lg'></i>" +
                "   </td>" +
                "</tr>"+
                "<tr>" +
                "<td colspan='9' id='showrecommendation_of_sk_"+fl_userid+"' style='display:none;width: 120%; padding-left: 0px;'>"+
                "</td>"+
                "</tr>";
        return s;
    }

    public String  recomendedsk(String fl_userid) {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String recomended_totalforfl ="";

        try{
            con = getConnection();
            ps = con.prepareStatement(sql_getFLRecommendCountoffriend);
            ps.setString(1, fl_userid);
            ps.setString(2, fl_userid);

            rs = ps.executeQuery();

            if(rs.next()) {

                String total_count = rs.getString("total_count");
                String recommend_count = rs.getString("recommend_count");
                recomended_totalforfl = recommend_count+"/"+total_count;
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return recomended_totalforfl;
    }

    public int registerTask(String title,String mgremail,String taskdis) {
        int status = 0;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();
            ps = con.prepareStatement("insert into task values(?, ?, ?)");
            ps.setString(1, title);
            ps.setString(2, mgremail);
            ps.setString(3, taskdis);
            status = ps.executeUpdate();
        }
        catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    public int registerUser(String email, String pwd, String role, String doj) {
        int status = 0;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();
            ps = con.prepareStatement("insert into user values(?,?,?,?)");
            ps.setString(1, email);
            ps.setString(2, pwd);
            ps.setString(3, role);
            ps.setString(4, doj);
            status = ps.executeUpdate();
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    String sql_check_client_map = "Select * from fl_client_map where freelancer_email = (select email from users where user_id = ?) and client_email = ? and status != 2";
    String sql_add_client = "insert into fl_client_map (client_email, client_name, freelancer_email, freelancer_name, posted_by, status) values(?, ?, (SELECT email FROM users WHERE user_id = ?), (SELECT nickname FROM users WHERE user_id = ?), (SELECT email FROM users WHERE user_id = ?), ?)";

    public String addClient(String client_name, String client_email, String user_id) {
        String res = "failed";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_check_client_map);
            ps.setString(1, user_id);
            ps.setString(2, client_email);

            rs = ps.executeQuery();

            if(rs.next()) {
                res = "already_exists";
            } else {
                ps = con.prepareStatement(sql_add_client, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, client_email);
                ps.setString(2, client_name);
                ps.setString(3, user_id);
                ps.setString(4, user_id);
                ps.setString(5, user_id);
                ps.setInt(6, 0);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next()) {
                        int clientId = rs.getInt(1);
                        String status_msg = "Approval pending";
                        res = getStringForClients(user_id, client_name, client_email, clientId, status_msg);
                    }
                }
            }
        } catch(SQLException se) {
            System.err.print(se.getMessage());
            return res;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return res;
    }

    public String getAllManagers() {
        Connection con = null;
        PreparedStatement getAM = null;
        ResultSet rs = null;
        String course_list = "";

        try {
            con = getConnection();
            getAM = con.prepareStatement(sql_getAllManagers);

            rs = getAM.executeQuery();

            while (rs.next()) {
                String client_name = rs.getString("client_name");
                String client_email = rs.getString("client_email");

                String tr = getStringForManagers(client_name, client_email);

                course_list += tr;
            }
            return course_list;
        } catch (Exception e) {
            e.printStackTrace();
            return "An error occurred while getting managers. Please try again.";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String getStringForManagers( String client_name, String client_email) {
        String s = "";

        s = "<tr >" +
                "   <td width='30%'>"+client_name+"</td>" +
                "   <td width='30%'>"+client_email+"</td>" +
                "   <td width='30%' class='td-actions' style='text-align:center;' >" +
                "       <button data-original-title='Edit client' data-toggle='modal' type='button' title='Edit client' rel='tooltip' class='btn btn-warning btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-edit'></i></button>" +
                "       <button data-original-title='Delete client' data-toggle='modal' type='button' title='Delete client' rel='tooltip' class='btn btn-danger btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-times'></i></button>" +
                "   </td>" +
//                "  <td width='20%'><button class='btn btn-sm btn-fill btn-info'  style='width: 70px;margin-left:10px'>Approve </button></td>"+
                "</tr>";
        return s;
    }

    final String sql_getAllManagers = "select * from client";

    public int registerManagerTask(String task_title, String task_description, String user_id, String email) {
        int status = 0;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();
            ps = con.prepareStatement("insert into client_projects (task_title, task_description, client_id, client_email) values(?,?,?,?)");

            ps.setString(1, task_title);
            ps.setString(2, task_description);
            ps.setString(3, user_id);
            ps.setString(4, email);

            status = ps.executeUpdate();
        }
        catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    String sql_checkProjectForClient = "select * from client_projects where task_title = ? and client_id = ?";
    String sql_insertProjectForClient = "insert into client_projects (task_title, task_description, client_id) values(?, ?, ?)";

    String sql_checkProjectForClient_FLMapping = "select * from client_projects_fl_mapping where project_id = ? and fl_email = ?";
    String sql_insertProjectForClient_FLMapping = "insert into client_projects_fl_mapping (project_id, fl_email) values(?, ?)";

    public boolean addProjectForClient(String prj_title, String prj_desc, String fl_email, String client_id) {
        boolean status = false;
        Connection con = null;
        ResultSet rs = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_checkProjectForClient);
            ps.setString(1, prj_title);
            ps.setString(2, client_id);

            rs = ps.executeQuery();

            int project_id = -1;

            if(rs.next()) {
                project_id = rs.getInt("project_id");
            } else {
                ps = con.prepareStatement(sql_insertProjectForClient, Statement.RETURN_GENERATED_KEYS);

                ps.setString(1, prj_title);
                ps.setString(2, prj_desc);
                ps.setString(3, client_id);
                int id = ps.executeUpdate();

                if(id == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next()) {
                        project_id = rs.getInt(1);
                    }
                }
            }

            status = addProjectForClient_FLMapping(con, project_id, fl_email);
        }
        catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    public boolean addProjectForClient_FLMapping(Connection con, int project_id, String fl_email) {

        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ps = con.prepareStatement(sql_checkProjectForClient_FLMapping);
            ps.setInt(1, project_id);
            ps.setString(2, fl_email);

            rs = ps.executeQuery();

            if(rs.next()) {
                return true;
            } else {
                ps = con.prepareStatement(sql_insertProjectForClient_FLMapping);
                ps.setInt(1, project_id);
                ps.setString(2, fl_email);
                int id = ps.executeUpdate();

                if(id > 0) {
                    return true;
                }
            }
        }
        catch(SQLException se) {
            System.err.print(se.getMessage());
        }
        return false;
    }

    String sql_checkProjectForFL = "select * from freelancer_projects where task_title = ? and fl_userid = ?";
    String sql_insertProjectForFL = "insert into freelancer_projects (task_title, task_description, fl_userid) values(?, ?, ?)";

    String sql_checkProjectForFL_ClientMapping = "select * from freelancer_projects_client_mapping where project_id = ? and client_email = ?";
    String sql_insertProjectForFL_ClientMapping = "insert into freelancer_projects_client_mapping (project_id, client_email) values(?, ?)";

    public boolean addProjectForFL(String prj_title, String prj_desc, String client_email, String fl_userid) {
        boolean status = false;
        Connection con = null;
        ResultSet rs = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_checkProjectForFL);
            ps.setString(1, prj_title);
            ps.setString(2, fl_userid);

            rs = ps.executeQuery();

            int project_id = -1;

            if(rs.next()) {
                project_id = rs.getInt("project_id");
            } else {
                ps = con.prepareStatement(sql_insertProjectForFL, Statement.RETURN_GENERATED_KEYS);

                ps.setString(1, prj_title);
                ps.setString(2, prj_desc);
                ps.setString(3, fl_userid);
                int id = ps.executeUpdate();

                if(id == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next()) {
                        project_id = rs.getInt(1);
                    }
                }
            }

            status = addProjectForFL_ClientMapping(con, project_id, client_email);
        }
        catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    public boolean addProjectForFL_ClientMapping(Connection con, int project_id, String client_email) {

        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ps = con.prepareStatement(sql_checkProjectForFL_ClientMapping);
            ps.setInt(1, project_id);
            ps.setString(2, client_email);

            rs = ps.executeQuery();

            if(rs.next()) {
                return true;
            } else {
                ps = con.prepareStatement(sql_insertProjectForFL_ClientMapping);
                ps.setInt(1, project_id);
                ps.setString(2, client_email);
                int id = ps.executeUpdate();

                if(id > 0) {
                    return true;
                }
            }
        }
        catch(SQLException se) {
            System.err.print(se.getMessage());
        }
        return false;
    }

    public String getAllprojectsforclient(String client_id) {
        Connection con = null;
        PreparedStatement getAPFC = null;
        ResultSet rs = null;
        String course_list = "";

        try {
            con = getConnection();
            getAPFC = con.prepareStatement(sql_getClientProjects);
            getAPFC.setString(1, client_id);

            rs = getAPFC.executeQuery();

            while (rs.next()) {
                String project_id = rs.getString("project_id");
                String task_title = rs.getString("task_title");
                String task_description = rs.getString("task_description");
//                String manager_email = rs.getString("manager_email");

                String tr = getStringForClintProjects(client_id, project_id, task_title, task_description);

                course_list += tr;
            }
            return course_list;
        } catch (Exception e) {
            e.printStackTrace();
            return "Could not get the developer projects for client. Please try again.";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String getStringForClintProjects(String client_id, String project_id, String task_tile, String task_description) {
        String s = "";

        s = "<tr id='"+client_id+"_"+project_id+"'>" +
                "   <td width='20%'>"+task_tile+"</td>" +
                "   <td width='40%'>"+task_description+"</td>" +
                "   <td width='20%' class='text-center'><button data-original-title='Edit project' data-toggle='modal' type='button' title='Edit project' rel='tooltip' class='btn btn-warning btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-edit'></i></button>" +
                "                <button data-original-title='Delete project' data-toggle='modal' type='button' title='Delete project' rel='tooltip' class='btn btn-danger btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-times'></i></button></td>" +
                "   <td width='20%' class='text-center'>N/A</td>" +
                "</tr>";
        return s;
    }

    final String sql_getClientProjects = "select * from client_projects where client_id = ?";

    public String getAllprojectsforFL(String user_id) {
        Connection con = null;
        PreparedStatement getAPFFL = null;
        ResultSet rs = null;
        String course_list = "";

        try {
            con = getConnection();
            getAPFFL = con.prepareStatement(sql_getFLProjects);
            getAPFFL.setString(1, user_id);

            rs = getAPFFL.executeQuery();

            while (rs.next()) {
                String task_title = rs.getString("task_title");
                String task_description = rs.getString("task_description");

                String tr = getStringForFLProjects(user_id, task_title, task_description);

                course_list += tr;
            }
            return course_list;
        } catch (Exception e) {
            e.printStackTrace();
            return "Could not get the projects for fl. Please try again.";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String getStringForFLProjects(String user_id, String task_tile, String task_description) {
        String s = "";

        s = "<tr id='"+user_id+"'>" +
                "   <td width='20%'>"+task_tile+"</td>" +
                "   <td width='40%'>"+task_description+"</td>" +
                "   <td width='20%' class='text-center'><button data-original-title='Edit project' data-toggle='modal' type='button' title='Edit project' rel='tooltip' class='btn btn-warning btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-edit'></i></button>" +
                "                <button data-original-title='Delete project' data-toggle='modal' type='button' title='Delete project' rel='tooltip' class='btn btn-danger btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-times'></i></button></td>" +
//                "   <td width='20%' class='text-center'><button class='btn btn-sm btn-fill btn-info'  style='width: 70px;margin-left:10px'>Approve </button> </td>" +
                "</tr>";
        return s;
    }

    final String sql_getFLProjects = "select * from freelancer_projects where fl_userid = ?";

    public int registerDeveloperTask(String proj_title, String proj_description, String user_id) {
        int status = 0;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();
            ps = con.prepareStatement("insert into freelancer_projects (task_title, task_description, fl_userid) values(?, ?, ?)");

            ps.setString(1, proj_title);
            ps.setString(2, proj_description);
            ps.setString(3, user_id);

            status = ps.executeUpdate();
        } catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null) {
                closeConnection(con);
            }
        }
        return status;
    }

    public int registerContractorskills(String skills,String experience,String user_id) {
        int status = 0;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();
            ps = con.prepareStatement("insert into skills (skills, experience, user_id) values(?,?,?)");

            ps.setString(1, skills);
            ps.setString(2, experience);
            ps.setString(3, user_id);

            status=ps.executeUpdate();
        } catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    public String getSearchResults(String search_by, String search_value) {
        String fl_userid = "";
        String fl_email = "";
        String skills = "";
        String experience = "";
        String linkedin = "";
        String fb_photo_path = "";
        String fb_app_id = "";

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

/*
        String sql_searchFLs = "select s.*, u.email, u.user_id, u.fb_photo_path, u.fb_app_id " +
                "from skills s, users u " +
                "where s.user_id = u.user_id and u.email not like '%@devsquare.com' and "+search_by+" like '%"+search_value+"%'";
*/

        String sql_searchFLs = "select s.*, u.email, u.user_id, u.fb_photo_path, u.fb_app_id " +
                "from skills s, users u " +
                "where s.user_id = u.user_id and u.email not like '%@devsquare.com' and (";

        String[] search_value_arr = search_value.split(",");

        for (int i = 0; i < search_value_arr.length; i++) {
            if(i == search_value_arr.length-1) {
                sql_searchFLs += search_by+" like '%"+search_value_arr[i].trim()+"%'";
            } else {
                sql_searchFLs += search_by+" like '%"+search_value_arr[i].trim()+"%' or ";
            }
        }

        sql_searchFLs += ")";

//        System.out.println("sql_searchFLs: "+sql_searchFLs);

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_searchFLs);
            rs = ps.executeQuery();

            while(rs.next()) {
                fl_userid = rs.getString("user_id");
                fl_email = rs.getString("email");
                skills = rs.getString("skills");
                experience = rs.getString("experience");
                linkedin = rs.getString("linkedin");
                fb_photo_path = rs.getString("fb_photo_path");
                fb_app_id = rs.getString("fb_app_id");

                msg += getSearchResultsString(fl_userid, fl_email, skills, experience, linkedin, fb_photo_path, fb_app_id);
            }
        } catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String  datetime(String userid) {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String recommend_date ="";
        String converted_time =" ";

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_getdatetime);
            ps.setString(1, userid);
            //ps.setString(2, userid);

            rs = ps.executeQuery();

            if(rs.next()) {

                String my_string = rs.getString("posted_on");
                String [] my_date_time = null;
                my_date_time = my_string.split(" ");
                String Date_str=my_date_time[0];
                System.out.println("***********"+Date_str+":-"+Date_str);


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
//                    System.out.println("***********"+test_create_time+":-"+converted_time);

                } catch (ParseException ex) {
                    ex.printStackTrace();
                }
                recommend_date += Date_str+"&nbsp;<i class='fa fa-clock-o' style='font-size:10px'>"+converted_time+"</i>";
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return recommend_date;
    }

    public String  datetimeactivities(String activity_id) {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String recommend_dateactivities ="";
        String converted_timeactivities =" ";

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_getdatetimeactivities);
            ps.setString(1, activity_id);
            //ps.setString(2, userid);

            rs = ps.executeQuery();

            if(rs.next()) {

                String my_string = rs.getString("posted_on");
                String [] my_date_time = null;
                my_date_time = my_string.split(" ");
                String Date_str=my_date_time[0];
                System.out.println("***********"+Date_str+":-"+Date_str);


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

//                    System.out.println("***********"+test_create_time+":-"+converted_time2);

                } catch (ParseException ex) {
                    ex.printStackTrace();
                }
                recommend_dateactivities += Date_str+"&nbsp;&nbsp;<i class=\"fa fa-clock-o\"></i>"+converted_timeactivities;
//                System.out.println("***********"+recommend_date2+":-"+converted_time2);
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return recommend_dateactivities;
    }

    public String  datetimeactivityresponse(String activity_id) {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String recommend_dateactivityresponse ="";
        String converted_timeactivityresponse =" ";

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_getdatetimeactivityresponse);
            ps.setString(1, activity_id);
            //ps.setString(2, userid);

            rs = ps.executeQuery();

            if(rs.next()) {

                String my_string = rs.getString("recommended_on");
                String [] my_date_time = null;
                my_date_time = my_string.split(" ");
                String Date_str=my_date_time[0];
                System.out.println("***********"+Date_str+":-"+Date_str);


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

//                    System.out.println("***********"+test_create_time+":-"+converted_time2);

                } catch (ParseException ex) {
                    ex.printStackTrace();
                }
                recommend_dateactivityresponse += Date_str+"&nbsp;&nbsp;<i class=\"fa fa-clock-o\"></i>"+converted_timeactivityresponse;
//                System.out.println("***********"+recommend_date2+":-"+converted_time2);
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
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
            e.printStackTrace();
        }
        return ret;
    }

    public String loadActivities(String user_id) {
        String activity_id = "";
        String fl_userid = "";
        String fl_nickname = "";
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

        String sql_loadActivities = "select u.user_id, u.email, u.nickname, u.fb_photo_path, a.activity_id, a.fl_userid, a.category, a.comments, a.posted_on, a.posted_by, a.posted_by as owner_id " +
                "                from user_fb_friends uff, users u, activities a " +
                "                where uff.fb_friend_app_id = u.fb_app_id and u.user_id = a.posted_by and uff.user_id = ?  and a.status = 1" +
                " union " +

                "select u.user_id, u.email, u.nickname, u.fb_photo_path, ab.activity_id, -1 as fl_userid, 'broadcast' as category, a.comments, ab.broadcasted_on, ab.broadcasted_by, ab.owner_id " +
                "                from user_fb_friends uff, users u, activities_broadcast ab, activities a " +
                "                where uff.fb_friend_app_id = u.fb_app_id and u.user_id = ab.broadcasted_by and ab.activity_id = a.activity_id and uff.user_id = ? and a.status = 1" +

                " order by posted_on DESC";

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_loadActivities);
            ps.setString(1, user_id);
            ps.setString(2, user_id);

            rs = ps.executeQuery();

            Vector fl_list = getFLVectorList(user_id);

            while(rs.next()) {
                fl_nickname = rs.getString("nickname");
                posted_by_photo = rs.getString("fb_photo_path");
                activity_id = rs.getString("activity_id");
                fl_userid = rs.getString("fl_userid");
                category = rs.getString("category");
                comments = rs.getString("comments");
                posted_on = rs.getString("posted_on");
                posted_by = rs.getString("posted_by");
                owner_id = rs.getString("posted_by");

                if(category.equalsIgnoreCase("asks") || category.equalsIgnoreCase("broadcast")) {
                    msg += loadActivitiesAsksString(con, activity_id, posted_by_photo, fl_nickname, comments, posted_on, posted_by, owner_id, fl_list);
                } else if(category.equalsIgnoreCase("enquire")) {
                    msg += loadActivitiesEnquireString(con, activity_id, posted_by_photo, fl_userid, fl_nickname, comments, posted_on, posted_by, owner_id);
                }
            }
        } catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    final String sql_getFLVectorList = "select freelancer_email from fl_client_map where client_email = (select email from users where user_id = ?)and freelancer_email not like '%@devsquare.com'";
// filtered @devsquare.comnot show the real user id's

    public Vector getFLVectorList(String userid) {
        Connection con = null;
        PreparedStatement getFL = null;
        ResultSet rs = null;
        Vector fl_list = new Vector();

        try {
            con = getConnection();
            getFL = con.prepareStatement(sql_getFLVectorList);
            getFL.setString(1, userid);

            rs = getFL.executeQuery();

            while (rs.next()) {
                String freelancer_email = rs.getString("freelancer_email");
                fl_list.add(freelancer_email);
            }
            return fl_list;
        } catch (Exception e) {
            e.printStackTrace();
            return fl_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String loadFBFriends(String user_id) {
        String friend_userid = "";
        String friend_email = "";
        String friend_name = "";
        String friend_photo_path = "";

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        String sql_loadFBFriends = "select u.user_id, u.email, u.nickname, u.fb_photo_path from user_fb_friends uff, users u where uff.fb_friend_app_id = u.fb_app_id and uff.user_id = ?";

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_loadFBFriends);
            ps.setString(1, user_id);

            rs = ps.executeQuery();

            while(rs.next()) {
                friend_userid = rs.getString("user_id");
                friend_email = rs.getString("email");
                friend_name = rs.getString("nickname");
                friend_photo_path = rs.getString("fb_photo_path");

                msg += loadFBFriendsString(con, friend_userid, friend_email, friend_name, friend_photo_path);
            }
        } catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String loadskFriend() {
        String friend_userid = "";
        String friend_email = "";
        String friend_name = "";
        String friend_photo_path = "";

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        String sql_loadskFriend = "select * from users  where user_id = 32";

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_loadskFriend);


            rs = ps.executeQuery();

            while(rs.next()) {
                friend_userid = rs.getString("user_id");
                friend_photo_path = rs.getString("fb_photo_path");

                msg += loadskFriendString(friend_userid, friend_photo_path);
            }
        } catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String loadAskList(String user_id) {
        String activity_id = "";
        String comments = "";
        String posted_on = "";

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        String sql_loadAskList = "select * from activities where posted_by = ? and category = \"asks\" and status = 1 order by posted_on DESC";

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_loadAskList);
            ps.setString(1, user_id);

            rs = ps.executeQuery();

            while(rs.next()) {
                activity_id = rs.getString("activity_id");
                comments = rs.getString("comments");
                posted_on = rs.getString("posted_on");

                msg += loadAskListString(con,user_id,activity_id, comments, posted_on);
            }
        } catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String getFLskills(String user_id) {
        String skills = "";
        String experience = "";
        String linkedin = "";

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_getFLSkills);
            ps.setString(1, user_id);

            rs = ps.executeQuery();

            if(rs.next()) {
                skills = rs.getString("skills");
                experience = rs.getString("experience");
                linkedin = rs.getString("linkedin");
            }

            msg = getSkillsForm(skills, experience, linkedin);

        } catch(SQLException se) {
            System.err.print(se.getMessage());
            return msg;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String getSkillsForm(String skills, String experience, String linkedin) {

        String ret = "<div class='row' >" +
                "                        <div class='col-xs-3' style='margin-left:10%'>" +
                "                            <h5 for='name' class='text-right'>Skills</h5></div>" +
                "                        <div class='col-xs-7' style='margin-left:-1%'>" +
                "                            <input type='text' class='form-control' id='skills' placeholder='E.g. Android, PHP, ...' style='width: 300px' name='skills' value='"+(skills != null ? skills : "")+"'>" +
                "                        </div>" +
                "                    </div><br>" +
                "" +
                "                    <div class='row'>" +
                "                        <div class='col-xs-3' style='margin-left:10%'>" +
                "                            <h5 for='title' class='text-right'>Experience</h5></div>" +
                "                        <div class='col-xs-7' style='margin-left:-1%'>" +
                "                            <input type='text' class='form-control' placeholder='E.g. 5 years' style='width: 300px' id='experience' name='experience' value='"+(experience != null ? experience : "")+"'>" +
                "                        </div>" +
                "                    </div><br>" +
                "" +
                "                    <div class='row'>" +
                "                        <div class='col-xs-3' style='margin-left:10%'>" +
                "                            <h5 for='title' class='text-right'>LinkedIn</h5></div>" +
                "                        <div class='col-xs-7' style='margin-left:-1%'>" +
                "                            <input type='text' class='form-control' placeholder='E.g. https://linkedin.com/...' style='width: 300px' id='linkedin' name='linkedin' value='"+(linkedin != null ? linkedin : "")+"'>" +
                "                        </div>" +
                "                    </div><br>" +
                "                   <div id='add_skills_status' align='center' class='alert alert-warning' style='display: none'> </div>" +
                "                    <div class='modal-footer'>" +
                "                        <center><button class='btn btn-primary btn-fill btn-info' type='submit' onclick='updateSkills();'>Save</button>&nbsp;&nbsp;" +
                "                            <button class='btn btn-fill btn-default' data-toggle='button' data-dismiss='modal'>Cancel</button></center>" +
                "                    </div>" +
                "                    <input type='hidden' name='user_id' class='form-control' id='user_id' value='0'>";

        return ret;
    }

    public String getFLdetails(String user_id, String fcm_id) {
        String freelancer_name = "";
        String freelancer_email = "";

        String msg = "";
        String status_msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_getFLdetails);
            ps.setString(1, fcm_id);

            rs = ps.executeQuery();

            if(rs.next()) {
                freelancer_name = rs.getString("freelancer_name");
                freelancer_email = rs.getString("freelancer_email");

                String client_email = rs.getString("client_email");
                String posted_by = rs.getString("posted_by");
                int status = rs.getInt("status");

                if(posted_by.trim().equalsIgnoreCase(client_email.trim())) {
                    if(status == 1) {
                        status_msg = "<td width='30%'>Approval not required</td>";
                    } else {
                        status_msg = "<td width='30%'>Approval pending</td>";
                    }
                } else if(posted_by.trim().equalsIgnoreCase(freelancer_email.trim())) {
                    if(status == 1) {
                        status_msg = "<td width='30%'>Approved</td>";
                    } else {
                        status_msg = "<td width='30%' id='fcm_"+fcm_id+"'><button id = 'btn_fcm_"+fcm_id+"' class='btn btn-sm btn-fill btn-info' style='width: 70px;' onclick='approveFL("+fcm_id+")'>Approve</button></td>";
                    }
                }
            }

            msg =  "<div class='modal-dialog'>" +
                    "   <div class='modal-content' style='max-width: 550px'>" +
                    "       <div class='modal-header' style='background-color:#ff9500;border-radius: 5px 5px 0px 0px'>" +
                    "           <button type='button' class='close' data-dismiss='modal' style='color: white' aria-hidden='true'>&times;</button>" +
                    "           <h3 class='modal-title text-center' style='margin-bottom: 0px;height:15px;color: white'>Edit Freelancer</h3></br>" +
                    "       </div>" +
                    "       <div class='modal-body'> " +
                    "           <div class='row'>" +
                    "               <div class='col-md-2' style=margin-left:10%;'>" +
                    "                   <h5 >Name</h5>" +
                    "               </div>" +
                    "               <div class='col-md-5' style='margin-left:-3%'>" +
                    "                   <input type='text' name='edit_freelancer_name' placeholder='E.g. Adams' class='form-control' id='edit_freelancer_name' style='width:300px'  value=\""+freelancer_name+"\">" +
                    "               </div>" +
                    "           </div><br>" +
                    "           <div class='row'>" +
                    "               <div class='col-md-2' style=margin-left:10%;'>" +
                    "                   <h5 >Email</h5>" +
                    "               </div>" +
                    "               <div class='col-md-5'  style='margin-left:-3%'>" +
                    "                   <input type='text' name='edit_freelancer_email' placeholder='E.g. adamsxxx@xxx.com' class='form-control' id='edit_freelancer_email' style='width:300px'  value="+freelancer_email+">"+
                    "               </div>" +
                    "           </div><br>" +
                    "           <div id='edit_fl_status' align='center' class='alert alert-warning' style='display: none'> </div>" +
                    "           <input type='hidden' name='edit_fl_status_msg' id='edit_fl_status_msg' value=\"" +status_msg+"\"" +
                    "           <div class='modal-footer'>" +
                    "               <center>" +
                    "                   <button id='fcm_id' class='btn btn-fill btn-warning' data-toggle='button' type='submit' onclick=\"updateFldetails("+fcm_id+");\">Update freelancer</button>&nbsp;&nbsp;" +
                    "                   <button class='btn btn-fill btn-default' data-toggle='button' data-dismiss='modal'>Cancel</button>" +
                    "               </center><br>" +
                    "           </div>" +
                    "       </div>" +
                    "   </div>" +
                    "</div>";
        } catch(SQLException se) {
            System.err.print(se.getMessage());
            return msg;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String getCLdeetails(String user_id,String fcm_id) {
        String client_name = "";
        String client_email = "";

        String msg = "";
        String status_msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_getFLdetails);
            ps.setString(1, user_id);
            ps.setString(1, fcm_id);

            rs = ps.executeQuery();

            if(rs.next()) {
                client_name = rs.getString("client_name");
                client_email = rs.getString("client_email");

                String freelancer_email = rs.getString("freelancer_email");
                String posted_by = rs.getString("posted_by");
                int status = rs.getInt("status");

                if(posted_by.trim().equalsIgnoreCase(client_email.trim())) {
                    if(status == 1) {
                        status_msg = "Approval not required";
                    } else {
                        status_msg = "Approval pending";
                    }
                } else if(posted_by.trim().equalsIgnoreCase(freelancer_email.trim())) {
                    if(status == 1) {
                        status_msg = "Approved";
                    } else {
                        status_msg = "Approval pending";
                    }
                }
            }

            msg =  "<div class='modal-dialog'>" +
                    "   <div class='modal-content' style='max-width: 550px'>" +
                    "       <div class='modal-header' style='background-color:#ff9500;border-radius: 5px 5px 0px 0px'>" +
                    "           <button type='button' class='close' data-dismiss='modal' style='color: white' aria-hidden='true'>&times;</button>" +
                    "           <h3 class='modal-title text-center' style='margin-bottom: 0px;height:15px;color: white' >Edit Client</h3></br>" +
                    "       </div>" +
                    "       <div class='modal-body'> " +
                    "           <div class='row'>" +
                    "               <div class='col-md-2' style=margin-left:10%;'>" +
                    "                   <h5 >Name</h5>" +
                    "               </div>" +
                    "               <div class='col-md-5' style='margin-left:-3%'>" +
                    "                   <input type='text' name='edit_client_name' placeholder='E.g. Adams' class='form-control' id='edit_client_name' style='width:300px'  value="+client_name+">" +
                    "               </div>" +
                    "           </div><br>" +
                    "           <div class='row'>" +
                    "               <div class='col-md-2' style=margin-left:10%;'>" +
                    "                   <h5 >Email</h5>" +
                    "               </div>" +
                    "               <div class='col-md-5' style='margin-left:-3%'>" +
                    "                   <input type='text' name='edit_client_email' placeholder='E.g. adamsxxx@xxx.com' class='form-control' id='edit_client_email' style='width:300px'  value='"+client_email+"'>"+
                    "               </div>" +
                    "           </div><br>" +
                    "           <div id='edit_client_status' align='center' class='alert alert-warning' style='display: none'> </div>" +
                    "           <input type='hidden' name='edit_client_status_msg' id='edit_client_status_msg' value=\"" +status_msg+"\"" +

                    "           <div class='modal-footer'>" +
                    "               <center>" +
                    "                   <button id='fcm_id' class='btn btn-fill btn-warning' data-toggle='button' type='submit' onclick=\"updateCldetails("+fcm_id+");\">Update client</button>&nbsp;&nbsp;" +
                    "                   <button class='btn btn-fill btn-default' data-toggle='button' data-dismiss='modal'>Cancel</button>" +
                    "               </center>" +
                    "           </div>" +
                    "       </div>" +
                    "   </div>" +
                    "</div>";
        } catch(SQLException se) {
            System.err.print(se.getMessage());
            return msg;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String getUserRole(String user_id) {
        int user_type = 0;

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_getUserRole);
            ps.setString(1, user_id);

            rs = ps.executeQuery();

            if(rs.next()) {
                user_type = rs.getInt("user_type");
            }

            msg = getUserRoleForm(user_type);

        } catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String getUserRoleForm(int user_type) {

        String ret = "<div class='row' >" +
                "                        <div class='col-xs-3' style='margin-left:10%;  margin-top: 8px;'>" +
                "                            <h5 for='name' class='text-right'>Role</h5></div>" +
                "                        <div class='col-xs-3' style='margin-left:-1%'>" +

                "                           <div for='radio_checked_client' class='radio" +((user_type == 1) ? " checked" : "")+" ' style='display:inline-block; margin-bottom:2px; margin-top: 15%;' >" +
                "                               <span class='icons'>" +
                "                                   <span class='first-icon fa fa-circle-o'></span>" +
                "                                   <span class='second-icon fa fa-dot-circle-o'></span>" +
                "                               </span>" +

                "                               <input id='radio_checked_client' name='user_role' type='radio' data-toggle='radio' value='1' "+((user_type == 1) ? " checked" : "")+">Client" +
                "                           </div>" +

                "                        </div>" +
                "                        <div class='col-xs-3' style='margin-left:-1%'>" +

                "                           <div for='radio_checked_fl' class='radio" +((user_type == 2) ? " checked" : "")+" ' style='display:inline-block; margin-bottom:2px; margin-top: 15%;' >" +
                "                               <span class='icons'>" +
                "                                   <span class='first-icon fa fa-circle-o'></span>" +
                "                                   <span class='second-icon fa fa-dot-circle-o'></span>" +
                "                               </span>" +

                "                               <input id='radio_checked_fl' name='user_role' type='radio' data-toggle='radio' value='2' "+((user_type == 2) ? " checked" : "")+">Freelancer" +
                "                           </div>" +

                "                        </div>" +
                "                    </div>";
        return ret;
    }

    public String getFLDetails_For_ClientProject(String client_id) {
        ArrayList<String> fl_list = new ArrayList<String>();

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_getFLDetails_For_ClientProject);
            ps.setString(1, client_id);

            rs = ps.executeQuery();

            while(rs.next()) {
                String fl_email = rs.getString("freelancer_mail");
                fl_list.add(fl_email);
            }

            msg = getFLDetails_For_ClientProject_Form(fl_list);

        } catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String getFLDetails_For_ClientProject_Form(ArrayList<String> fl_list) {

        String res = "<select name='addproject_fl' id='addproject_fl' class='form-control'>";

        String fl_options = "<option value='select'>Select</option>";

        for (int i = 0; i < fl_list.size(); i++) {
            String fl_name = fl_list.get(i);

            fl_options += "<option value='"+fl_name+"'>"+fl_name+"</option>";
        }

        res += fl_options;

        res += "</select>";

        return res;
    }

    public String getClientDetails_For_FLProject(String fl_userid) {
        ArrayList<String> client_list = new ArrayList<String>();

        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_getClientDetails_For_FLProject);
            ps.setString(1, fl_userid);

            rs = ps.executeQuery();

            while(rs.next()) {
                String client_email = rs.getString("client_email");
                client_list.add(client_email);
            }

            msg = getClientDetails_For_FLProject_Form(client_list);

        } catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }

    public String getClientDetails_For_FLProject_Form(ArrayList<String> client_list) {

        String res = "<select name='addproject_client' id='addproject_client' class='form-control'>";

        String client_options = "<option value='select'>Select</option>";

        for (int i = 0; i < client_list.size(); i++) {
            String client_name = client_list.get(i);

            client_options += "<option value='"+client_name+"'>"+client_name+"</option>";
        }

        res += client_options;

        res += "</select>";

        return res;
    }

    public boolean changeUserRole(String user_id, String user_role) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_updateUserRole);

            ps.setString(1, user_role);
            ps.setString(2, user_id);

            int cnt = ps.executeUpdate();

            if(cnt > 0) {
                return true;
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String getSearchResultsString(String fl_userid, String fl_email, String skills, String experience, String linkedin_url, String fl_photo_path, String fb_app_id) throws SQLException {

        String recomended_total = recomended(fl_userid);

        String linkedin_str1 = "<button class=\"btn btn-info btn-simple btn-fill btn-sm \" style='cursor: pointer;padding: 0px 5px' data-original-title=\"Linkedin profile\" type=\"button\" title=\"\" rel=\"tooltip\"  onclick=\"window.open('"+linkedin_url+"', '_blank')\"><i class=\"fa fa-linkedin\"></i> </button>";
        String linkedin_str = (linkedin_url != null && linkedin_url.trim().length() > 0 ? linkedin_str1 : "N/A");

        String ret = "<tr>" +
                "<td>" +
                "<button data-original-title='Show Recommendations' data-toggle='modal' type='button' id='showrecommendations_"+fl_userid+"' title='Show Recommendations' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px;' onclick='showFLRecommendations("+fl_userid+");'><i class='fa fa-caret-right'></i></button>" +
                "<button data-original-title='Hide Recommendations' data-toggle='modal' type='button' id='hiderecommendations_"+fl_userid+"' title='Hide Recommendations' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px; display: none;' onclick='hideFLRecommendations("+fl_userid+");'><i class='fa fa-caret-down'></i></button> </td>" +
                "</td>" +
                "<td style='word-break: break-all;'>"+(fl_email != null && fl_email.trim().length() > 0 ? fl_email  : "N/A")+"</td>" +
                "<td style='word-break: break-all;'>"+(skills != null && skills.trim().length() > 0 ? skills  : "N/A")+"</td>" +
                "<td>"+(experience != null && experience.trim().length() > 0 ? experience  : "N/A")+"</td>" +
                "<td style='word-break: break-all;' class='text-center'>"+(linkedin_str)+"</td>" +
                "<td class='text-center'>"+recomended_total+"</td>" +
                "<td class='td-actions'>" +
                "    <button id='search_fl_"+fl_userid+"' style='padding: 1px 5px' class='btn btn-info btn-simple btn-lg' rel='tooltip' type='button' data-toggle='modal' data-original-title='Ask in network' onclick=\"enquireFLInNetwork('search_fl', "+fl_userid+"); return false;\">" +
                "        <i class='fa fa-question-circle fa-lg'></i>" +
                "    </button>" +
                "</td>" +
                "</tr>"+
                "<tr>" +
                "<td colspan='9' id='showfl_"+fl_userid+"' style='display:none;width: 120%; padding-left: 10px;'>"+
                "</td>"+
                "</tr>";

        return ret;
    }



    public String  recomended(String fl_userid) {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String recommend_total ="";

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_getFLRecommendCount);
            ps.setString(1, fl_userid);
            ps.setString(2, fl_userid);

            rs = ps.executeQuery();

            if(rs.next()) {

                String total_count = rs.getString("total_count");
                String recommend_count = rs.getString("recommend_count");
                recommend_total = recommend_count+"/"+total_count;
                //System.out.println("***********"+total_count+":-"+recommend_count+":-"+recommend_total);

            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return recommend_total;
    }

    public String loadActivitiesAsksString(Connection con, String activity_id, String posted_by_photo, String fl_nickname, String comments, String posted_on, String posted_by, String owner_id, Vector fl_list) {
        String Date_str1 = datetimeactivities(activity_id);
        String dropdownStr = "";
        String category_to_display = "asks";

        Iterator it = fl_list.iterator();

        String fl_list_str = "<select id='ask_response_"+activity_id+"_"+owner_id+"' name='ask_response_"+activity_id+"_"+owner_id+"' class='form-control' style='width: 40%; display: inline; padding: 1px;'>";
//        fl_list_str += "<option value='select'>Select</option>";

        while(it.hasNext()) {
            String val = (String)it.next();
            fl_list_str += "<option value='"+val+"'>"+val+"</option>";
        }
        fl_list_str += "</select>";

        String ret = "<li>" +
                "        <div class='fcc_item' style='max-height: 580px;margin-bottom:7px'>" +
                "            <div class='fcc_img' style='max-height:75px'>" +
                "                 <img src='"+posted_by_photo+"' alt='IMAGE NOT AVAILABLE' style='margin-top:1%' title='see details' >" +
                "            </div>" +
                dropdownStr+
                "            <div class='fcc_item_desc'>" +
                "<div class='row'>" +
                " <div class='col-xs-5' style='margin-top:0.5%;margin-left:1%'>    " +
                "          <h5 style='display:inline'>"+fl_nickname+" </h5><span class='text-muted' style='font-size: 13px'>"+category_to_display+" ("+Date_str1+")</span><br> <p style='margin-top:0px;font-size:13px' >"+comments+"</p> </div>" +
                "   <div class='col-xs-6 text-right' style='margin-top:1%'> "+

                "         <button id='broadcast_ask_nf_"+activity_id+"_"+owner_id+"' style='padding: 1px 5px' class='btn btn-info btn-simple btn-lg' rel='tooltip' title='Broadcast' type='button' data-toggle='modal' data-original-title='Broadcast' onclick=\"broadcastAskInNetwork('broadcast_ask_nf', "+activity_id+", "+owner_id+"); return false;\">" +
                "       <img src='images/broadcast_initial.png' width='25px'>" +
                "   </button>" +
//                "   <input type='text' id='ask_response_"+activity_id+"_"+owner_id+"' name='ask_response_"+activity_id+"' style='max-width:180px;display:inline' class='form-control'>" +
                fl_list_str +
                "   <button id='ask_response_btn_"+activity_id+"_"+owner_id+"' style='padding: 1px 5px' class='btn btn-info btn-simple btn-lg' rel='tooltip' title='Suggest freelancer' type='button' data-toggle='modal' data-original-title='Suggest freelancer' onclick=\"postResponseToAsk("+activity_id+", "+owner_id+"); return false;\">" +
                "       <i class='fa fa-arrow-circle-right fa-lg'></i>" +
                "   </button>" +

//                Following 2 (showAskResponses, hideAskResponses) are commented out temporarly, 9-Jan-2016

//                "   <button data-original-title='Show Responses' data-toggle='modal' type='button' id='showaskresponses_"+activity_id+"_"+posted_by+"' title='Show Responses' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 0.1px 0.1px .1px 0px;margin-top: 6%' onclick='showAskResponses("+activity_id+","+posted_by+");'><i class='fa fa-caret-down'></i></button>" +
//                "   <button data-original-title='Hide Responses' data-toggle='modal' type='button' id='hideaskresponses_"+activity_id+"_"+posted_by+"' title='Hide Responses' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 0.1px 0.1px .1px 0px; display: none;margin-top: 6%' onclick='hideAskResponses("+activity_id+","+posted_by+");'><i class='fa fa-caret-up'></i></button>" +

                "</div>"+
                "</div>"+
                "            </div>" +
                "        </div>" +
                "        </div>" +
//                "   <div id='show_ask_responses_"+activity_id+"_"+posted_by+"' class='text-left' style='width: 115%;margin-top: %;max-height: 180px;overflow: auto;'></div>"+
                "</li>";
        return ret;
    }

    public String loadActivitiesEnquireString(Connection con, String activity_id, String posted_by_photo, String fl_userid, String fl_nickname, String comments, String posted_on, String posted_by2, String owner_id) {
        String Date_str1 = datetimeactivities(activity_id);
        PreparedStatement ps = null;
        ResultSet rs = null;

        String email = null;
        String nickname = null;
        String fb_photo_path = null;
        String skills = null;
        String experience = null;
        String linkedin = null;

        String fl_user_details = "";
//        String category_to_display = "asks";
        String category_to_display = "enquires";

        try {
            ps = con.prepareStatement(sql_getFLUserDetails);
            ps.setString(1, fl_userid);

            rs = ps.executeQuery();

            if(rs.next()) {
                email = rs.getString("email");
                nickname = rs.getString("nickname");
                fb_photo_path = rs.getString("fb_photo_path");
                skills = rs.getString("skills");
                experience = rs.getString("experience");
                linkedin = rs.getString("linkedin");
            }

            String linkedin_str1 = "<button class=\"btn btn-info btn-simple btn-fill btn-sm \" style='cursor: pointer;padding: 0px 5px' data-original-title=\"Linkedin profile\" type=\"button\" title=\"\" rel=\"tooltip\"  onclick=\"window.open('"+linkedin+"', '_blank')\"><i class=\"fa fa-linkedin\"></i> </button>";
            String linkedin_str = (linkedin != null && linkedin.trim().length() > 0 ? linkedin_str1 : "N/A");

            fl_user_details += "<br><b>Email:</b> "+(email != null && email.trim().length() > 0 ? email : "N/A")+" <b>LinkedIn:</b> "+(linkedin_str);
            fl_user_details += "<br><b>Experience:</b> "+(experience != null && experience.trim().length() > 0 ? experience : "N/A")+"; <b>Skills:</b> "+(skills != null && skills.trim().length() > 0 ? skills : "N/A");
        } catch(SQLException se) {
            System.err.print(se.getMessage());
        }

        String ret = "<li >" +
                "        <div class='fcc_item' style='max-height: 720px'>" +
                "            <div class='fcc_img'>" +
                "                 <img src='"+posted_by_photo+"' alt='IMAGE NOT AVAILABLE' style='margin-top:2%' title='see details' >" +
                "            </div>" +
                "            <div class='row'> " +
                "               <div class='col-xs-8' style='margin-top:0.7%;margin-left: 1%'>    " +
                "                   <div class='fcc_item_desc' >" +
                "                       <h5 style='margin-top:10px;margin-bottom: 12px;display:inline'>"+fl_nickname+" </h5><span class='text-muted' style='font-size: 13px'>"+category_to_display+" ("+Date_str1+")</span> </div>" +
                "                           <h7 style='margin-top:0px;font-size:13px' >"+comments+"</h7>" +
                "                           <h7 style='margin-top:0px;font-family:monospace' >"+fl_user_details+"</h7>" +
                "                   </div>"+
                "               <div class='col-xs-3 text-right'style='margin-top:2%;' >    " +
                "                   <button data-original-title='Yes, go ahead' data-toggle='modal' type='button' title='Yes, go ahead' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px;' onclick=\"recommendFL('"+activity_id+"','"+fl_userid+"','1'); return false;\"><i class='fa fa-thumbs-o-up fa-lg'></i></button>" +
                "                   <button data-original-title='No' data-toggle='modal' type='button' title='No' rel='tooltip' class='btn btn-danger btn-simple btn-lg' style='padding: 1px 5px;' onclick=\"recommendFL('"+activity_id+"','"+fl_userid+"','0'); return false;\"><i class='fa fa-thumbs-o-down fa-lg'></i></button>" +
                "                   <button id='search_fl_nf_"+fl_userid+"' style='padding: 1px 5px' class='btn btn-info btn-simple btn-lg' rel='tooltip' title='Ask in network' type='button' data-toggle='modal' data-original-title='Ask in network' onclick=\"enquireFLInNetwork('search_fl_nf', "+fl_userid+"); return false;\">" +
                "                       <i class='fa fa-question-circle fa-lg'></i>" +
                "                   </button>" +
                "               </div>"+
                "               <div class='text-right'style='margin-top:2%;' >    " +
                "                   <div id='showdetails' style='margin-left: 95.5%; cursor: default; pointer-events: visible; width: 10px; display: block; margin-top: 72px;' class='fcc_img'>" +
                "                       <button data-original-title='Show Recommendations' data-toggle='modal' type='button' id='showrecommendations_home_"+activity_id+"_"+fl_userid+"' title='Show Recommendations' rel='tooltip' class='btn btn-info btn-simple' onclick='showFLRecommendationsHome("+activity_id+","+fl_userid+");'><i class='fa fa-caret-down fa-lg'></i></button>" +
                "                       <button data-original-title='Hide Recommendations' data-toggle='modal' type='button' id='hiderecommendations_home_"+activity_id+"_"+fl_userid+"' title='Hide Recommendations' rel='tooltip' class='btn btn-info btn-simple' style='display: none;' onclick='hideFLRecommendationsHome("+activity_id+", "+fl_userid+");'><i class='fa fa-caret-up fa-lg'></i></button>" +
                "                   </div>"+
                "               </div>"+
                "            </div>" +
                "        </div>" +
                "        <div id='showfl_home_"+activity_id+"_"+fl_userid+"'  class=\"text-left\"  style='max-width: 115%;max-height: 180px;overflow: auto;'></div>"+
                "</li>";
        return ret;
    }

    public String loadFBFriendsString(Connection con, String friend_userid, String friend_email, String friend_name, String friend_photo_path) {

        String ret = "<li>" +
                "        <div class='fcc_item' style='max-height: 70px;'>" +
                "            <div class='fcc_img'>" +
                "                 <img src='"+friend_photo_path+"' alt='IMAGE NOT AVAILABLE' style='margin-left:9%;height:65px' title='see details' >" +
                "            </div>" +

                "            <div id='showdetails' style='margin-left: -1%; margin-top: 2%; cursor: default; pointer-events: visible; width: 10px; display: block;' class='fcc_img'>" +
                "               <button data-original-title='Show freelancers' data-toggle='modal' type='button' id='showfriends_fl_"+friend_userid+"' title='Show freelancers' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px;' onclick='showfllist("+friend_userid+");'><i class='fa fa-caret-right'></i></button>" +
                "               <button data-original-title='Hide freelancers' data-toggle='modal' type='button' id='hidefriends_fl_"+friend_userid+"' title='Hide freelancers' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px; display: none;' onclick='hideFriendFLs("+friend_userid+");'><i class='fa fa-caret-down'></i></button>" +
                "            </div>"+

                "            <div class='fcc_item_desc' width='50%'>" +
                "                 <h2 style='margin-top:10px;margin-bottom: 12px;font-size:17px'>"+friend_name+
                "                 <h5 style='margin-top:10px;margin-bottom: 12px;font-family:monospace'>"+friend_email+
                "            </div>" +
                "        </div>" +
                "<div id='fllist_"+friend_userid+"' style='display:none;max-width: 99%;background-color:white;overflow:auto'>" +
                "<div class='table-responsive'  style='max-width:99%; max-height: 250px; box-shadow: 0.5px 0px 0.1px  5px rgba(128,150,0, .1);border-radius: 2px;overflow: auto;'>" +
                "    <table class='table' style='margin-bottom:0px;'>" +
                "        <thead><tr>" +
                "            <td max-width='80%'><h5 style='margin: 2px 0 1px;align:left' >Freelancers</h5>" +
                "        </tr></thead>" +
                "    </table>" +
                "    <table class='table' style='margin-bottom:0px;' >" +
                "        <thead>" +
                "        <tr >" +
                "               <th></th> "+
                "            <th width='15%'>Name</th>" +
                "            <th width='25%'>Email</th>" +
                "            <th width='15%'>Skills</th>" +
                "            <th width='5%'>Experience</th>" +
                "            <th width='40%' class='text-center'>LinkedIn</th>" +
                "            <th width='20%'>Recommendations</th>" +
                "            <th width='10%'>Enquire</th>" +
                "        </tr>" +
                "        </thead>" +
                "        <tbody id=fl_"+friend_userid+">" +
                "        </tbody>" +
                "    </table>" +
                "    </div>" +
                "</div>"+
                "</div>"+
                "    </li>";
        return ret;
    }

    public String loadskFriendString(String friend_userid,String friend_photo_path) {

        String ret = "<li>" +
                "        <div class='fcc_item' style='height:80px;'>" +
                "            <div class='fcc_img'>" +
                "                 <img src='"+friend_photo_path+"' alt='fcc_item_img' style='margin-left:9%;height:65px' title='see details' >" +
                "            </div>" +
                "            <div id='showdetails' style='margin-left: -1%; margin-top: 2%; cursor: default; pointer-events: visible; width: 10px; display: block;' class='fcc_img'>" +
                "               <button data-original-title='Show freelancers' data-toggle='modal' type='button' id='showfriends_fl_"+friend_userid+"' title='Show freelancers' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px;' onclick='showfllist("+friend_userid+");'><i class='fa fa-caret-right'></i></button>" +
                "               <button data-original-title='Hide freelancers' data-toggle='modal' type='button' id='hidefriends_fl_"+friend_userid+"' title='Hide freelancers' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px; display: none;' onclick='hideFriendFLs("+friend_userid+");'><i class='fa fa-caret-down'></i></button>" +
                "            </div>"+
                "            <div class='fcc_item_desc' width='50%'>" +
                "                 <h2 style='margin-top:15px;margin-bottom: 12px;font-size:17px'>SK</h2>"+
                "                 <h5 style='margin-top:10px;margin-bottom: 12px;font-family:monospace'></h5>"+
                "            </div>" +
                "        </div>" +
                "<div id='fllist_"+friend_userid+"' style='display:none;max-width: 99%;background-color:white;overflow:auto'>" +
                "<div class='table-responsive'  style='max-width:99%; max-height: 250px; box-shadow: 0.5px 0px 0.1px  5px rgba(128,150,0, .1);border-radius: 2px;overflow: auto;'>" +
                "    <table class='table' style='margin-bottom:0px;'>" +
                "        <thead><tr>" +
                "            <td max-width='80%'><h5 style='margin: 2px 0 1px;align:left' >Freelancers</h5>" +
                "        </tr></thead>" +
                "    </table>" +
                "    <table class='table' style='margin-bottom:0px;' >" +
                "        <thead>" +
                "        <tr >" +
                "               <th></th> "+
                "            <th width='15%'>Name</th>" +
                "            <th width='25%'>Email</th>" +
                "            <th width='15%'>Skills</th>" +
                "            <th width='5%'>Experience</th>" +
                "            <th width='40%' class='text-center'>LinkedIn</th>" +
                "            <th width='20%'>Recommendations</th>" +
                "            <th width='10%'>Enquire</th>" +
                "        </tr>" +
                "        </thead>" +
                "        <tbody id=fl_"+friend_userid+">" +
                "        </tbody>" +
                "    </table>" +
                "    </div>" +
                "</div>"+
                "</div>"+
                "    </li>";
        return ret;
    }

    public String getFlList(String user_id, String fl_userid, String freelancer_name, String freelancer_email, String skills, String experience, String linkedin_url) {
        String ret = "";
        String recomended_totalforfl = recomendedfl(fl_userid);

        String linkedin_str1 = "<button class=\"btn btn-info btn-simple btn-fill btn-sm \" style='cursor: pointer;padding: 0px 5px' data-original-title=\"Linkedin profile\" type=\"button\" title=\"\" rel=\"tooltip\"  onclick=\"window.open('"+linkedin_url+"', '_blank')\"><i class=\"fa fa-linkedin\"></i> </button>";
        String linkedin_str = (linkedin_url != null && linkedin_url.trim().length() > 0 ? linkedin_str1 : "N/A");

        ret = "<tr>" +
                "   <td>" +
                "       <button data-original-title='Show Recommendations' data-toggle='modal' type='button' id='showrecommendations_of_friend_"+fl_userid+"' title='Show Recommendations' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px;' onclick=\"showFLRecommendationsOfFriend('"+fl_userid+"');\"><i class='fa fa-caret-right'></i></button>" +
                "       <button data-original-title='Hide Recommendations' data-toggle='modal' type='button' id='hiderecommendations_of_friend_"+fl_userid+"' title='Hide Recommendations' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px; display: none;' onclick='hideFLRecommendationsOfFriend("+fl_userid+");'><i class='fa fa-caret-down'></i></button> </td>" +
                "   </td>" +
                "   <td width='15%' style='word-break: break-all;'>"+freelancer_name+" </td>" +
                "   <td width='25%' style='word-break: break-all;'>"+freelancer_email+"</td>" +
                "   <td width='25%' style='word-break: break-all;'>"+skills+"</td>" +
                "   <td width='5%' class='text-center'>"+experience+"</td>" +
                "   <td width='25%' style='word-break: break-all;' class='text-center'>"+linkedin_str+"</td>" +
                "   <td width='20%' class='text-center'>"+recomended_totalforfl+"</td>" +
                "   <td class='td-actions' class='text-center'>" +
                "       <button id='search_fl_"+fl_userid+"' style='padding: 1px 5px' class='btn btn-info btn-simple btn-lg' rel='tooltip' type='button' data-toggle='modal' data-original-title='Ask in network' onclick=\"enquireFLInNetwork('search_fl', "+fl_userid+"); return false;\">" +
                "           <i class='fa fa-question-circle fa-lg'></i>" +
                "       </button>" +
                "   </td>" +
                "</tr>"+
                "<tr>" +
                "   <td colspan='9' id='showfl_of_friend_"+fl_userid+"' style='display:none;width: 120%; padding-left: 0px;'>"+
                "   </td>"+
                "</tr>";

        return ret;
    }

    public String  recomendedfl(String fl_userid) {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String recomended_totalforfl ="";

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_getFLRecommendCountoffriend);
            ps.setString(1, fl_userid);
            ps.setString(2, fl_userid);

            rs = ps.executeQuery();

            if(rs.next()) {

                String total_count = rs.getString("total_count");
                String recommend_count = rs.getString("recommend_count");
                recomended_totalforfl = recommend_count+"/"+total_count;
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return recomended_totalforfl;
    }

    public String getFLRecommendationsofFriends(String freelancer_mail) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String ret = "";
        String ret_count = "";
        String ret_list = "<ul class='fcc_content' style='margin: 1px 1px 5px 3px; max-height: 150px; overflow-x: hidden; overflow-y: auto; margin-bottom: 0px;'>";

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_getFLRecommendCount);
            ps.setString(1, freelancer_mail);
            ps.setString(2, freelancer_mail);

            rs = ps.executeQuery();

            if(rs.next()) {
                String total_count = rs.getString("total_count");
                String recommend_count = rs.getString("recommend_count");

                ret_count =  "";
            }

            ret += ret_count;

            ps = con.prepareStatement(sql_getFLRecommendsListoffriend);
            ps.setString(1, freelancer_mail);

            rs = ps.executeQuery();

            while(rs.next()) {
                String recommended_by_email = rs.getString("email");
                String recommended_by_name = rs.getString("nickname");
                String recommended_by_photo = rs.getString("fb_photo_path");
                String recommend_status = rs.getString("recommend_status");
                String recommended_on = rs.getString("recommended_on");
                String activity_id = rs.getString("activity_id");
                ret_list += getFLRecommendationsList(recommended_by_email, recommended_by_name, recommended_by_photo, recommend_status, recommended_on,activity_id);
            }

            ret_list += "</ul>";

            ret = ret_count + ret_list;
        } catch (Exception e) {
            e.printStackTrace();
            return ret;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return ret;
    }

    public String loadAskListString(Connection con,String user_id, String activity_id, String comments, String posted_on) {
        String Date_str = datetime(user_id);
        String ret =  " <dl id="+activity_id+" style='margin-bottom:-4px;margin-top:3%;padding:0px'>" +
                "           <dd class='pos-left clearfix' style='margin-top:-2%;background-color: #F9F9F8;border-radius: 5px 5px 5px 5px;margin-left:10%'>" +
                "              <span class='events' style='margin-bottom:1px'>" +
                "                 <p class='text-left' style='line-height:1.4;font-size: 13px;word-wrap: break-word;margin-left: 3%;margin-bottom:3px;margin-top:1%;margin-right: 3%;' align='left' >"+comments+"</p>" +
                "                   <p class='text-left text-muted' style='line-height:1.3;font-size: 10px;word-wrap: break-word;margin-left: 3%;margin-bottom:4px' align='left' ><b>Posted:&nbsp;</b>"+Date_str+"</p>"+
                "                    <div  align='center' class='event-body' style='margin-bottom:1%;display:inline'>" +
                "                      <div class='pull-center' style='display:inline'> "+
                "                       <button data-original-title='Delete'  onclick=\"getpostdetailstodelete('"+activity_id+"');\" type='button' title='Delete' rel='tooltip' class='btn btn-default btn-simple btn-lg' style='padding: 1px 5px' ><i class='fa fa-times' style='color:red'></i></button>" +
                "			              <button data-original-title='Show Responses' data-toggle='modal' type='button' id='showaskresponses_"+activity_id+"' title='Show Responses' rel='tooltip' class='btn btn-default btn-simple btn-lg' style='padding: 1px 5px' onclick='showAskResponses("+activity_id+");'><i class='fa fa-caret-down fa-lg' style='color:#22A7F0'></i></button>" +
                "                         <button data-original-title='Hide Responses' data-toggle='modal' type='button' id='hideaskresponses_"+activity_id+"' title='Hide Responses' rel='tooltip' class='btn btn-default btn-simple btn-lg' style='padding: 1px 5px; display: none' onclick='hideAskResponses("+activity_id+");'><i class='fa fa-caret-up fa-lg' style='color:#22A7F0'></i></button>" +
                "                      </div> </div><br>"+
                "                   </span>" +
                "               </div>" +
                "           </dd>" +
                "           <div id='show_ask_responses_"+activity_id+"' class='text-left' style='max-width: 98%;margin-bottom: 0%;max-height: 180px;overflow: auto;margin-left:10%'></div>"+
                "       </dl>";
        return ret;
    }

    public String addOrUpdateFLskills(String skills, String experience, String linkedin, String user_id) {
        String status = "failed";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_checkFLSkills);
            ps.setString(1, user_id);

            rs = ps.executeQuery();

            if(rs.next()) {
                ps = con.prepareStatement(sql_updateFLSkills);

                ps.setString(1, skills);
                ps.setString(2, experience);
                ps.setString(3, linkedin);
                ps.setString(4, user_id);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    status = "success";
                }
            } else {
                ps = con.prepareStatement(sql_insertFLSkills);

                ps.setString(1, skills);
                ps.setString(2, experience);
                ps.setString(3, linkedin);
                ps.setString(4, user_id);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    status = "success";
                }
            }
        } catch(SQLException se) {
            System.err.print(se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    public String updateFLdetails(String freelancer_name, String freelancer_email, String fcm_id, String user_id) {
        String status = "failed:Could not update freelancer details. Please try again";

        PreparedStatement ps = null;
        Connection con = null;

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_updateFLdetails);

            ps.setString(1, freelancer_name);
            ps.setString(2, freelancer_email);
            ps.setString(3, fcm_id);

            int cnt = ps.executeUpdate();

            if(cnt > 0) {
                status = "success:";
            }

        } catch(SQLException se) {
            System.err.print(se.getMessage());
            return status;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    public String updateCLdetails(String client_name, String client_email, String fcm_id, String user_id) {
        String status = "failed:Could not update client details. Please try again";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_updateCLdetails);

            ps.setString(1, client_name);
            ps.setString(2, client_email);
            ps.setString(3, fcm_id);

            int cnt = ps.executeUpdate();

            if(cnt > 0) {
                status = "success:";
            }

        } catch(SQLException se) {
            System.err.print(se.getMessage());
            return status;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    public String postEnquiriesInNetwork(String user_id, String fl_user_id, String post_type, String comments) {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_checkCommentsInNetwork);
            ps.setString(1, user_id);
            ps.setString(2, fl_user_id);
            ps.setString(3, post_type);

            rs = ps.executeQuery();

            if(rs.next()) {
                ps = con.prepareStatement(sql_updateCommentsInNetwork);

                ps.setString(1, comments);
                ps.setString(2, user_id);
                ps.setString(3, fl_user_id);
                ps.setString(4, post_type);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    return "success";
                }
            } else {
                ps = con.prepareStatement(sql_postCommentsInNetwork);

                ps.setString(1, user_id);
                ps.setString(2, fl_user_id);
                ps.setString(3, post_type);
                ps.setString(4, comments);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    return "success";
                }
            }
            return "failed";
        } catch (Exception e) {
            e.printStackTrace();
            return "failed";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String postResponseToAsk(String user_id, String fl_userid, String activity_id, String comments) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_checkAskResponse);
            ps.setString(1, activity_id);
            ps.setString(2, user_id);

            rs = ps.executeQuery();

            if(rs.next()) {
                ps = con.prepareStatement(sql_updateAskResponse);

                ps.setString(1, comments);
                ps.setString(2, activity_id);
                ps.setString(3, fl_userid);
                ps.setString(4, user_id);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    return "success";
                }
            } else {
                ps = con.prepareStatement(sql_postAskResponse);

                ps.setString(1, activity_id);
                ps.setString(2, fl_userid);
                ps.setString(3, user_id);
                ps.setString(4, comments);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    return "success";
                }
            }
            return "failed";
        } catch (Exception e) {
            e.printStackTrace();
            return "failed";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String broadcastAskInNetwork(String user_id, String activity_id, String owner_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_checkBroadcastInNetwork);
            ps.setString(1, user_id);
            ps.setString(2, activity_id);
            ps.setString(3, owner_id);

            rs = ps.executeQuery();

            if(rs.next()) {
                return "success";
            } else {
                ps = con.prepareStatement(sql_postBroadcastInNetwork);

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
            e.printStackTrace();
            return "failed";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String postEnquiriesofskinNetwork(String user_id, String fl_userid, String post_type, String comments) {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_checkCommentssskInNetwork);
            ps.setString(1, user_id);
            ps.setString(2, fl_userid);
            ps.setString(3, post_type);

            rs = ps.executeQuery();

            if(rs.next()) {
                ps = con.prepareStatement(sql_updateskCommentsInNetwork);

                ps.setString(1, comments);
                ps.setString(2, user_id);
                ps.setString(3, fl_userid);
                ps.setString(4, post_type);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    return "success";
                }
            } else {
                ps = con.prepareStatement(sql_postskCommentsInNetwork);

                ps.setString(1, user_id);
                ps.setString(2, fl_userid);
                ps.setString(3, post_type);
                ps.setString(4, comments);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    return "success";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "failed";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return "failed";
    }

    public String postCommentsInNetwork(String user_id, String fl_user_id, String post_type, String comments) {

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_postCommentsInNetwork);

            ps.setString(1, user_id);
            ps.setString(2, fl_user_id);
            ps.setString(3, post_type);
            ps.setString(4, comments);

            int cnt = ps.executeUpdate();

            if(cnt > 0) {
                return "success";
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "failed";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return "failed";
    }

    public String recommendFL(String user_id, String fl_userid, String activity_id, String status) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_checkFLRecommend);
            ps.setString(1, activity_id);
            ps.setString(2, user_id);

            rs = ps.executeQuery();

            if(rs.next()) {
                ps = con.prepareStatement(sql_updateRecommend);

                ps.setString(1, status);
                ps.setString(2, activity_id);
                ps.setString(3, fl_userid);
                ps.setString(4, user_id);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    return "success";
                }
            } else {
                ps = con.prepareStatement(sql_postRecommend);

                ps.setString(1, activity_id);
                ps.setString(2, fl_userid);
                ps.setString(3, user_id);
                ps.setString(4, status);

                int cnt = ps.executeUpdate();

                if(cnt > 0) {
                    return "success";
                }
            }
            return "failed";
        } catch (Exception e) {
            e.printStackTrace();
            return "failed";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String getFLRecommendations(String fl_userid) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String ret = "";
        String ret_count = "";
        String ret_list = "<ul class='fcc_content' style='margin: 1px 1px 5px -6px; max-height: 150px; overflow-x: hidden; overflow-y: auto; margin-bottom: 0px;'>";

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_getFLRecommendCount);
            ps.setString(1, fl_userid);
            ps.setString(2, fl_userid);

            rs = ps.executeQuery();

            if(rs.next()) {
                String total_count = rs.getString("total_count");
                String recommend_count = rs.getString("recommend_count");

                ret_count =  "";
            }

            ret += ret_count;

            ps = con.prepareStatement(sql_getFLRecommendsList);
            ps.setString(1, fl_userid);

            rs = ps.executeQuery();

            while(rs.next()) {
                String recommended_by_email = rs.getString("email");
                String recommended_by_name = rs.getString("nickname");
                String recommended_by_photo = rs.getString("fb_photo_path");
                String recommend_status = rs.getString("recommend_status");
                String recommended_on = rs.getString("recommended_on");
                String activity_id = rs.getString("activity_id");

                ret_list += getFLRecommendationsList(recommended_by_email, recommended_by_name, recommended_by_photo, recommend_status, recommended_on,activity_id);
            }

            ret_list += "</ul>";

            ret = ret_count + ret_list;
        } catch (Exception e) {
            e.printStackTrace();
            return ret;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return ret;
    }

    public String getFLRecommendationsList(String recommended_by_email, String recommended_by_name, String recommended_by_photo, String recommend_status, String recommended_on,String activity_id) {
        String Date_strrespose = datetimeactivityresponse(activity_id);
        String status_display = "<button class='btn btn-info btn-simple btn-md' style='padding: 1px 5px; cursor: default;'><i class='fa fa-thumbs-o-up fa-lg'></i></button>";

        if((recommend_status.equals("0"))) {
            status_display = "<button class='btn btn-danger btn-simple btn-md' style='padding: 1px 5px; cursor: default;'><i class='fa fa-thumbs-o-down fa-lg'></i></button>";
        }

        String ret =   " <li>"+
                "<div class='fcc_item' style='max-width:420px;height: 45px;padding:1px 1px 12px 65px;margin-bottom: 0.3%; border: 0.1px solid #f0d89c;'>" +
                "            <div class='fcc_img' style='width: 45px; padding-left: 5px;margin-top: 0.8%'>" +
                "                 <img src='"+recommended_by_photo+"' alt='Photo'>" +
                "            </div>" +
                "            <div class='fcc_item_desc'>" +
                "                 <h5 style='margin-top:0px;margin-bottom: 12px;font-size:13px'><b>"+recommended_by_name+"</b> <span class='text-muted' style='font-size: 13px'> says </span>" +status_display+ "<br> <span class='text-muted' style='font-size: 11px;margin:top:2px'>"+Date_strrespose+"</span></h5>" +
                "               </div>"+
                "            </div>" +
                "        </div>" +
                "    </li>";

        return ret;
    }

    public String getAskResponses(String activity_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String ret_list = "<ul class='fcc_content' style='margin: 1px 1px 5px 3px; max-height: 150px; overflow-x: hidden; overflow-y: auto; margin-bottom: 0px;'>";

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_getAskResponsesList);
            ps.setString(1, activity_id);

            rs = ps.executeQuery();

            while(rs.next()) {
                String recommended_by_email = rs.getString("email");
                String recommended_by_name = rs.getString("nickname");
                String recommended_by_photo = rs.getString("fb_photo_path");
                String comments = rs.getString("comments");
                String recommended_on = rs.getString("recommended_on");

                ret_list += getAskResponsesList(recommended_by_email, recommended_by_name, recommended_by_photo, comments, recommended_on,activity_id);
            }

            ret_list += "</ul>";
        } catch (Exception e) {
            e.printStackTrace();
            return ret_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return ret_list;
    }

    public String getAskResponsesList(String recommended_by_email, String recommended_by_name, String recommended_by_photo, String comments, String recommended_on,String activity_id) {

        String ret =  "<li>"+
                "        <div class='fcc_item' style='max-width:650px;height: 50px;padding:2px 2px 12px 65px;margin-bottom: 0.3%;border:none'>" +
                "            <div class='fcc_img' style='width: 60px; padding-left: 5px;'>" +
                "                 <img src='"+recommended_by_photo+"' alt='Photo' sstyle='width: 60px;height: 60px'>" +
                "            </div>" +
                "				<div class='fcc_item_desc'>" +
                "                 <h5 style='margin-top:10px;margin-bottom: 12px;display:inline'>"+recommended_by_name+"</h5> <span class='text-muted' style='font-size: 12px'> suggests </span><span style='font-size: 13px'>" +comments+ "</span> <span class='text-muted' style='font-size: 12px'>("+recommended_on+")</span>" +
                "               </div>"+
                "            </div>" +
                "        </div>" +
                "    </li>";

        return ret;
    }

    public String getAllTasksForDevelopers(String fl_userid) {

        Connection con = null;
        PreparedStatement getTFD = null;
        ResultSet rs = null;
        String course_list = "";
        String ret = " ";

        try {
            con = getConnection();
            getTFD = con.prepareStatement(sql_getDevelopersTasks);
            getTFD.setString(1, fl_userid);

            rs = getTFD.executeQuery();

            while (rs.next()) {

                ret += "<tr id="+rs.getString("task_id")+">" +
                        "<td width='30%'>"+rs.getString("task_title")+"</td>" +
                        "   <td width='30%'>"+rs.getString("task_title")+"</td>" +
                        "   <td width='30%' class='td-actions' style='text-align:center;' >" +
                        "       <button data-original-title='Share manager' data-toggle='modal' type='button' title='Share class' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-share'></i></button>" +
                        "       <button data-original-title='Delete manager' data-toggle='modal' type='button' title='Share class' rel='tooltip' class='btn btn-danger btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-times'></i></button>" +
                        "   </td>" +
                        "  <td width='20%'><button class='btn btn-sm btn-fill btn-info'  style='width: 70px;margin-left:60px'>Approve </button></td>"+
                        "</tr>";
            }
            return ret;
        } catch (Exception e) {
            e.printStackTrace();
            return "Could not get the developer tasks list. Please try again.";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

/*
    public String getAllTasksForDeveloper(String developer_id) {
        Connection con = null;
        PreparedStatement getTasks = null;
        ResultSet rs = null;
        String course_list = "";

        try {
            con = getConnection();
            getTasks = con.prepareStatement(sql_getDeveloperTasks);
            getTasks.setString(1, developer_id);

            rs = getTasks.executeQuery();

            while (rs.next()) {
                String task_id = rs.getString("task_id");
                String task_title = rs.getString("task_title");
                String task_description = rs.getString("task_description");

                String tr = getStringForDeveloperTask(task_id, task_title, task_description);

                course_list += tr;
            }
            return course_list;
        } catch (Exception e) {
            e.printStackTrace();
            return "Could not get the developer tasks list. Please try again.";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }
*/

    public String[] getUserDetails_ForUserId(String userId)	{

        Connection con =  null;
        ResultSet rs = null;

        try {
            con = getConnection();
            PreparedStatement selectUser = con.prepareStatement(sql_getUserInfo_ForUserId);
            selectUser.setString(1, userId);

            rs = selectUser.executeQuery();
            String[] user_dets = new String[8];

            if (rs.next()) {
                user_dets[0] = rs.getString(1);
                user_dets[1] = rs.getString(2);
                user_dets[2] = rs.getString(3);
                user_dets[3] = rs.getString(4);
                user_dets[4] = rs.getString(5);
                user_dets[5] = rs.getString(6);
                user_dets[6] = rs.getString(7);
                user_dets[7] = rs.getString(8);
            }

            rs.close();
            selectUser.close();

            return user_dets;

        } catch(Throwable t) {
            t.printStackTrace();
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }

        return null;
    }

    public boolean doesUserExist(String userName) {
        Connection conn =  null;
        ResultSet rs = null;
        String res = null;

        try {
            conn = getConnection();

            int rowCount=0;
            PreparedStatement selectDUE = conn.prepareStatement(sql_doesUserExist);

            selectDUE.setString(1, userName.toUpperCase());

            rs = selectDUE.executeQuery();
            if (rs.next()) {
                rowCount=rs.getInt(1);
            }

            rs.close();
            selectDUE.close();

            if (rowCount>0) {
                return  true;
            } else {
                return false;
            }
        } catch(Throwable t) {
            t.printStackTrace();
        } finally {
            if(conn != null ) {
                closeConnection(conn);
            }
        }
        return false;
    }

    public String getUserPassword(String email)	{
        String password = null;

        Connection conn =  null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            PreparedStatement getUP = conn.prepareStatement(sql_getUserPassword);
            getUP.setString(1, email);

            rs = getUP.executeQuery();
            if (rs.next()) {
                password = rs.getString("password");
                return password;
            }

            rs.close();
            getUP.close();

        } catch(Throwable t) {
            t.printStackTrace();
        } finally {
            if(conn != null ) {
                closeConnection(conn);
            }
        }

        return password;
    }

    public long getUserId(String email)	{
        long userid = -1;

        Connection conn =  null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            PreparedStatement getUID = conn.prepareStatement(sql_getUserId);
            getUID.setString(1, email);

            rs = getUID.executeQuery();

            if (rs.next()) {
                userid = rs.getLong("user_id");
                return userid;
            }

            rs.close();
            getUID.close();

        } catch(Throwable t) {
            t.printStackTrace();
        } finally {
            if(conn != null ) {
                closeConnection(conn);
            }
        }

        return userid;
    }

    public boolean insertUserIfNotExist(String email, String name, String gender, String fb_photo_path, String fb_app_id) {
        Connection con = null;
        PreparedStatement checUser = null, insertUser = null;
        ResultSet rs = null;

        boolean userExist = false;

        try {
            con = getConnection();

            checUser = con.prepareStatement(sql_doesUserExist);
            checUser.setString(1, email);

            rs = checUser.executeQuery();

            if (rs.next()) {
                userExist = true;
                return true;
            }

            insertUser = con.prepareStatement(sql_insertUserDetails);

            String password = generateRandomPwd();

            insertUser.setString(1, email);
            insertUser.setString(2, password);
            insertUser.setString(3, name);
            insertUser.setString(4, gender);
            insertUser.setString(5, fb_photo_path);
            insertUser.setString(6, fb_app_id);

            int s = insertUser.executeUpdate();

            if (s > 0) {
                insertUser.close();
                return true;
            } else {
                insertUser.close();
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public static final String sql_checkGeneratedUniqueIsAlreadyPresent = "select " +
            "COUNT(*) AS rowcount from at_question where question_unique_id = ?";

    public boolean checkGeneratedUniqueIsAlreadyPresent(Connection conn, String tempUUID) {
        boolean isIdAlreadyPresent = false;
        ResultSet rs = null;
        PreparedStatement ps = null;
        int cnt = 0;

        try {

            ps = conn.prepareStatement(sql_checkGeneratedUniqueIsAlreadyPresent);
            ps.setString(1, tempUUID);
            rs = ps.executeQuery();
            while (rs.next()) {
                cnt = rs.getInt("rowcount");
                if (cnt > 0) {
                    isIdAlreadyPresent = true;
                }

            }
        } catch (SQLException sqe) {
            sqe.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
            } catch (Exception e) {
            }
        }
        return isIdAlreadyPresent;
    }

    public String generateQuestionUniqueId(Connection conn) {
        String id = "0";
        //Generate a unique id
        String tempid = generateNumericWordGivenLength(16);
        //check whether the generated id is already present in DB. If it is there, generate a new one.

        if (!checkGeneratedUniqueIsAlreadyPresent(conn, tempid)) {
            try {
                id = tempid;
            } catch (Exception e) {
                id = generateQuestionUniqueId(conn);
            }
        } else {
            id = generateQuestionUniqueId(conn);
        }
        return id+"";
    }

    static final String char_digits = "2104356879";

    //this will generate password of given length.
    public static String generateNumericWordGivenLength(int pwdLength) {
        StringBuffer buffer = new StringBuffer(pwdLength);
        int nextCharAt;
        for (int i = 0; i < pwdLength; i++) {
            nextCharAt = (getNextRandomInt()) % 10;
            buffer.append(char_digits.charAt(nextCharAt));
        }
        return buffer.toString();
    }

    private static int getNextRandomInt() {
        int nextRand = ran.nextInt();
        if (nextRand < 0)
            nextRand = nextRand * -1;
        return nextRand;
    }

    static Random ran = new Random();

    static String chars = "xyzfgh43ijklmnop215qrstuvw97680abcde";

    public static String generateRandomPwd() {
        int nextLength = 8;
        StringBuffer buffer = new StringBuffer(4);
        int nextCharAt;
        for (int i = 0; i < nextLength; i++) {
            nextCharAt = (getNextRandomInt()) % 10;
            buffer.append(chars.charAt(nextCharAt));
        }
        return buffer.toString();
    }

/*
    public String getStringForDeveloperTask(String task_id, String task_tile, String task_description) {
        String s = "";

        s = "<tr id='"+task_id+"'>" +
                "   <td width='30%'>"+task_tile+"</td>" +
                "   <td width='30%'>"+task_description+"</td>" +
                "   <td width='30%' class='td-actions' style='text-align:center;' >" +
                "       <button data-original-title='Share manager' data-toggle='modal' type='button' title='Share class' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-share'></i></button>" +
                "       <button data-original-title='Delete manager' data-toggle='modal' type='button' title='Share class' rel='tooltip' class='btn btn-danger btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-times'></i></button>" +
                "   </td>" +
                "  <td width='20%'><button class='btn btn-sm btn-fill btn-info'  style='width: 70px;margin-left:60px'>Approve </button></td>"+
                "</tr>";

        return s;
    }
*/

    public String deletePost(String user_id ,String activity_id ) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();

            ps = con.prepareStatement(sql_deletePost);
            ps.setString(1, activity_id);

            int cnt = ps.executeUpdate();

            if(cnt > 0) {
                return "success";
            }
            return "failed";
        } catch (Exception e) {
            e.printStackTrace();
            return "failed";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }
    final static String sql_deletePost = "update activities set status = 2 where activity_id = ?";


    public String deletepost(String user_id, String activity_id) {
        String  msg =  "<div class='modal-dialog'>" +
                "            <div class='modal-content' style='max-width: 550px'>" +
                "                <div class='modal-header' style='background-color:red;border-radius: 5px 5px 0px 0px'>" +
                "                    <button type='button' class='close' data-dismiss='modal' style='color: white' aria-hidden='true'>&times;</button>" +
                "                    <h3 class='modal-title text-center' style='margin-bottom: 0px;height:15px;color: white' >Delete Post</h3></br>" +
                "                </div>" +
                "                <div class='modal-body'> " +
                "   <p align='center' style='margin-top:5%'>Are you sure you wish to delete this post?</p>" +
                "       <div id='add_cledit_status' align='center' style='display:none'></div>" +
                "         <div class='modal-footer' style='margin-top:-2%;display:inline'>" +
                "          <center>" +
                "             <button id='activity_id' class='btn btn-fill btn-danger'   data-toggle='button' type='submit' onclick='DeletePost("+activity_id+");'>Delete post</button>&nbsp;&nbsp;" +
                "             <button class='btn btn-fill btn-default' data-toggle='button' data-dismiss='modal'>Cancel</button>" +
                "          </center>\n" +
                "        </div>";
        return msg;
    }

    public String deleteCLdetails(String fcm_id) {
        String status = "failed";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_deleteClientFLMapping);
            ps.setString(1, fcm_id);

            int cnt = ps.executeUpdate();

            if(cnt > 0) {
                status = "success";
            }
        } catch(SQLException se) {
            System.err.print(se.getMessage());
            return status;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    public String deleteFLDetails(String fcm_id) {
        String status = "failed";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_deleteClientFLMapping);
            ps.setString(1, fcm_id);

            int cnt = ps.executeUpdate();

            if(cnt > 0) {
                status = "success";
            }
        } catch(SQLException se) {
            System.err.print(se.getMessage());
            return status;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    final String sql_deleteClientFLMapping = "update fl_client_map set status = 2, last_update_time = now() where fcm_id = ?";

    public String getStringForDeveloperTasks(String task_id, String task_tile, String task_description) {
        String s = "";

        s = "<tr id='"+task_id+"'>" +
                "   <td width='30%'>"+task_tile+"</td>" +
                "   <td width='30%'>"+task_description+"</td>" +
                "   <td width='30%' class='td-actions' style='text-align:center;' >" +
                "       <button data-original-title='Share manager' data-toggle='modal' type='button' title='Share class' rel='tooltip' class='btn btn-info btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-share'></i></button>" +
                "       <button data-original-title='Delete manager' data-toggle='modal' type='button' title='Share class' rel='tooltip' class='btn btn-danger btn-simple btn-lg' style='padding: 1px 5px' onclick=''><i class='fa fa-times'></i></button>" +
                "   </td>" +
                "  <td width='20%'><button class='btn btn-sm btn-fill btn-info'  style='width: 70px;margin-left:60px'>Approve </button></td>"+
                "</tr>";

        return s;
    }

    final String sql_getDeveloperTasks = "select * from freelancer_projects where fl_userid = ?";
    final String sql_getDevelopersTasks = "select * from freelancer_projects where fl_userid = ?";
    final static String sql_getUserInfo_ForUserId = "SELECT user_id, email, password, mobile, nickname, sex, age," +
            " FROM users WHERE user_id = ?";

    final static String sql_getUserPassword = "SELECT password FROM users WHERE email = ?";

    final static String sql_getUserId = "SELECT user_id FROM users WHERE email = ?";
    final static String sql_doesUserExist = "SELECT * FROM users WHERE email = ?";
    final static String sql_insertUserDetails = "insert into users(email, password, nickname, sex, fb_photo_path, fb_app_id) values(?, ?, ?, ?, ?, ?) ";

    final static String sql_doesFBFriendMappingExist = "SELECT * FROM user_fb_friends WHERE user_id = ? and fb_friend_app_id = ?";
    final static String sql_insertFBFriendMapping = "insert into user_fb_friends (user_id, fb_friend_app_id) values(?, ?) ";

    public boolean insertUserFBFriendsIfNotExist(long userId, String fb_app_id, List<User> friendsList) {
        Connection con = null;
        PreparedStatement checkMapping = null, insertMapping = null;
        ResultSet rs = null;

        try {
            con = getConnection();

            for (User user1 : friendsList) {
                String fb_friend_app_id = user1.getId();

                checkMapping = con.prepareStatement(sql_doesFBFriendMappingExist);
                checkMapping.setLong(1, userId);
                checkMapping.setString(2, fb_friend_app_id);

                rs = checkMapping.executeQuery();

                if (rs.next()) {
                    continue;
                }

                System.out.println(new java.util.Date()+"\t userId: "+userId+", fb_app_id: "+fb_app_id+", fb_friend_app_id: "+fb_friend_app_id);

                insertMapping = con.prepareStatement(sql_insertFBFriendMapping);

                insertMapping.setLong(1, userId);
//                insertMapping.setString(2, fb_app_id);
                insertMapping.setString(2, fb_friend_app_id);

                int s = insertMapping.executeUpdate();

                if (s > 0) {
                    insertMapping.close();
                } else {
                    insertMapping.close();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return false;
    }

    String mail_host = "webmail.register.com";
    String mail_from = "help@devsquare.com";
    String fromEmail_Password = "LAt123#$y74987";

    public String sendHTMLEMail(String email, String subject, String text) {

        String[] to = {email};

        boolean debug = false;
        // create some properties and get the default Session
        Properties props = System.getProperties();
        props.put("mail.smtp.host", mail_host);
        props.put("mail.smtp.auth", "true");
        props.put("mail.debug", "true");
        props.put("mail.smtp.user", mail_from);
        props.put("mail.smtp.port", "25");
        props.put("mail.smtp.password", fromEmail_Password);

        Authenticator auth = new SMTPAuthenticator(mail_from, fromEmail_Password);
        Session session = Session.getInstance(props, auth);
        session.setDebug(debug);

        try {
            // create a message
            MimeMessage msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(mail_from));

            InternetAddress[] address = new InternetAddress[to.length];

            for (int i = 0; i < to.length; i++) {
                address[i] = new InternetAddress(to[i]);
            }
            msg.setRecipients(Message.RecipientType.TO, address);
            msg.setSubject(subject);

            // create and fill the first message part
            MimeBodyPart mbp1 = new MimeBodyPart();
            mbp1.setContent(text, "text/html");

            // create the Multipart and its parts to it
            Multipart mp = new MimeMultipart();
            mp.addBodyPart(mbp1);
            // add the Multipart to the message
            msg.setContent(mp);

            // set the Date: header
            msg.setSentDate(new Date());

            // send the message
            Transport.send(msg);
            return "send";
        } catch (MessagingException mex) {
            mex.printStackTrace();
            Exception ex = null;
            if ((ex = mex.getNextException()) != null)
                ex.printStackTrace();
        }
        return "error";
    }

    private class SMTPAuthenticator extends javax.mail.Authenticator {
        String username = null;
        String password = null;
        private SMTPAuthenticator(String SMTP_AUTH_USER,String SMTP_AUTH_PWD){
            username = SMTP_AUTH_USER;
            password = SMTP_AUTH_PWD;
        }
        public PasswordAuthentication getPasswordAuthentication() {
            return new PasswordAuthentication(username, password);
        }
    }
%>

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
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.MimeBodyPart" %>
<%@ page import="javax.mail.internet.MimeMessage"%>
<%@ page import="javax.mail.internet.MimeMultipart" %>
<%@ page import="javax.mail.internet.InternetAddress" %>
<%@ page import="javax.mail.Authenticator" %>
<%@ page import="javax.mail.PasswordAuthentication" %>
<%@ page import="org.json.simple.JSONArray" %>
<%@ page import="org.json.simple.JSONObject" %>
<%!
    SimpleDateFormat DAY_MONTH_FORMATTER = new SimpleDateFormat("EEE, MMM d");
    static ArrayList<String[]> contactList_Util;
    static int SET_CONTACTS_INITIAL_LOADING_LIMIT = 2;
    static int SK_USER_ID = 0;
    static String CONTACT_IMAGE_PATH = "D:\\netref\\web\\mobile\\user_contact_images";
    static String PROFILE_IMAGE_PATH = "D:\\netref\\web\\mobile\\profile_images";
    static String server_type = "test";
    static String test_mobile_number = "+919901424531";
    static String test_user_id = "163";
    int level_1 =50;
    int level_2 =100;
    int level_3 =150;
    int level_4 =200;
    int level_5 =300;
    static HashMap iOSContactList;

    final String sql_getLinProfilePictureUrl = "SELECT u.lin_profile_picture_url,u.name FROM users u where u.user_id = ?";

    public String getLinProfilePictureUrl(String user_id) {
        String lin_profile_picture_url = "images/profile.jpg";
        String name = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_getLinProfilePictureUrl);
            ps.setString(1, user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                lin_profile_picture_url = rs.getString("lin_profile_picture_url");
                name = rs.getString("name");
            }
            return lin_profile_picture_url;
        } catch(Exception se) {
            return lin_profile_picture_url;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
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
                byte[] profile_name_bytes = rs.getBytes("profile_name");

                profile_name = new String(profile_name_bytes);
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

    final String sql_checkcompany = "select * from companies where domain_name = ?";
    final String sql_insertcompany = "insert into companies (domain_name, created_by) values (?, ?)";

    public int createCompanyAndMapToUser(String user_id, String domain_name) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        int company_id = -1;

        try {
            con = getConnection();

            ps = getPs(con, sql_checkcompany);
            ps.setString(1, domain_name);

            rs = ps.executeQuery();

            if(rs.next()) {     //If company name already exists, get the company id
                company_id = rs.getInt("company_id");
            } else {            //else, insert company details and get the company id
                ps = con.prepareStatement(sql_insertcompany, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, domain_name);
                ps.setString(2, user_id);

                int id = ps.executeUpdate();

                if(id == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next()) {
                        company_id = rs.getInt(1);
                    }
                }
            }

            int map_status = mapCompanyToUser(con, user_id, company_id);

            if(map_status > 0) {
                return company_id;
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return -1;
    }

    public int createCompanyIfNotExists(String user_id, String domain_name) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        int company_id = 0;

        try {
            con = getConnection();

            ps = getPs(con, sql_checkcompany);
            ps.setString(1, domain_name);

            rs = ps.executeQuery();

            if(rs.next()) {     //If company name already exists, return -1
                return -1;
            } else {            //else, insert company details and get the company id
                ps = con.prepareStatement(sql_insertcompany, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, domain_name);
                ps.setString(2, user_id);

                int id = ps.executeUpdate();

                if(id == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next()) {
                        company_id = rs.getInt(1);
                    }
                }
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return company_id;
    }

    final String sql_checkcompany_map = "select * from user_company_map where user_id = ? and company_id = ?";
    final String sql_insertcompany_map = "insert into user_company_map (user_id, company_id) values (?, ?)";

    public int mapCompanyToUser(String user_id, int company_id) {
        int status = 0;

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();
//            Map company_id to user, if not exists

            ps = getPs(con, sql_checkcompany_map);
            ps.setString(1, user_id);
            ps.setInt(2, company_id);

            rs = ps.executeQuery();

            if(rs.next()) {
//                User to company mapping already exists. Do nothing
            } else {
                ps = getPs(con, sql_insertcompany_map);

                ps.setString(1, user_id);
                ps.setInt(2, company_id);

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

    final String sql_updateUserType = "update users set user_type = ? where user_id = ?";
    public int updateUserType(String user_id, int user_type) {
        int status = 0;

        PreparedStatement ps = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_updateUserType);
            ps.setInt(1, user_type);
            ps.setString(2, user_id);

            status = ps.executeUpdate();
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    public int mapCompanyToUser(Connection con, String user_id, int company_id) {
        int status = 0;

        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
//            Map company_id to user, if not exists

            ps = getPs(con, sql_checkcompany_map);
            ps.setString(1, user_id);
            ps.setInt(2, company_id);

            rs = ps.executeQuery();

            if(rs.next()) {
//                User to company mapping already exists. Do nothing
            } else {
                ps = getPs(con, sql_insertcompany_map);

                ps.setString(1, user_id);
                ps.setInt(2, company_id);

                status = ps.executeUpdate();
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        }
        return status;
    }

    String sql_check_contact = "Select * from users where email = ?";
    String sql_check_contact_map = "Select * from users u, users_mapping rs where u.user_id = rs.from_user_id and u.user_id = ? and rs.to_user_id = (select user_id from users where email = ?)";
    String sql_insert_contact = "insert into users (email) values(?)";

    public int addTeamMembers(Connection con, String user_id, String email_address) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        int to_user_id = -1;

        try {
            ps = getPs(con, sql_check_contact);
            ps.setString(1, email_address);
            rs = ps.executeQuery();

            if(rs.next()) {
                to_user_id = rs.getInt("user_id");

                ps = getPs(con, sql_check_contact_map);

                ps.setString(1, user_id);
                ps.setString(2, email_address);

                rs = ps.executeQuery();

                if(rs.next()) {
//                    Relationship already exists, DO NOTHING; return
                } else {
                    int rs_id = postRelationTypeToDB(con, user_id, to_user_id+"");
                }
            } else {
                ps = con.prepareStatement(sql_insert_contact, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, email_address);

                int id = ps.executeUpdate();

                if(id == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next()) {
                        to_user_id = rs.getInt(1);

                        int rs_id = postRelationTypeToDB(con, user_id, to_user_id+"");
                    }
                }
            }
        } catch(Exception se) {
//            System.err.print(se.getMessage());
            System.err.print(new Date()+"\t "+se.getMessage());
            return to_user_id;
        }

        return to_user_id;
    }

    final String sql_sdendinvite_details = "select u.email,(select domain_name from user_company_map where user_id=?) as domain,(select name from users where user_id=?) as from_name  from users u  where  u.user_id =?";

    public void sendInvite(Connection con, String user_id, String to_user_id) {
        System.out.println("sendInvite:"+user_id +to_user_id);
        PreparedStatement ps = null;
        ResultSet rs = null;
        String send_mail = "";
        String domain_name = "";
        String to_email = "";
        String from_name = "";
        String send_invite_mail = "";
        try {
            ps = getPs(con, sql_sdendinvite_details);
            ps.setString(1, user_id);
            ps.setString(2, user_id);
            ps.setString(3, to_user_id);
            System.out.println("sql_checkUserRelation: "+ps);
            rs = ps.executeQuery();

            while(rs.next()) {
                domain_name = rs.getString("domain");
                to_email = rs.getString("email");
                from_name = rs.getString("from_name");

                sendInvitation(domain_name, to_email, from_name);
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        }

    }

    final String sql_getMycontacts = "select * from users u, users_mapping m where u.user_id=m.to_user_id and m.from_user_id = ? and m.status='1'";

    //TODO, REMOVE after checking with loadMyContacts_AL

    public String loadContacts(String user_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String course_list = "";

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_getMycontacts);
            ps.setString(1, user_id);
            rs = ps.executeQuery();

            while (rs.next()) {
                String email = rs.getString("email");
                String contact_user_id = rs.getString("user_id");
                String lin_profile_picture_url = rs.getString("lin_profile_picture_url");


                String tr = getStringForMycontacts(email, contact_user_id);

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

    //TODO, REMOVE after checking with loadMyContacts_AL
    public String getStringForMycontacts(String email,String contact_user_id) {
        String s = "";

        s = "<tbody>" +
                "       <tr style='height:50px'>" +
                "          <td style='width: 60px'>" +
                "             <div class='pull-left' >" +
                "                <img  class='img-circle' style='max-width:40px;margin-top: 4px;margin-bottom: 4px' src='images/profile.jpg' class='events-object img-rounded'>" +
                "             </div>" +
                "           </td>" +
                "           <td>" +
                "             <h4>"+email+"</h4>" +
                "           </td>" +
                "           <td>" +
                "              <button type='button' style='margin-top:7px' data-toggle='modal' class='btn btn-warning btn-circle' onclick=\"openContactEditForm('"+contact_user_id+"')\"><i class='fa fa-edit'></i>" +
                "              </button> <a style='color: #f0ad4e;font-size:10px'>Edit contact</a> &nbsp;" +
                "              <button type='button' style='margin-top:7px' class='btn btn-danger btn-circle'  data-toggle='modal' onclick=\"getContactDetailsToDelete('"+contact_user_id+"')\"><i class='fa fa-trash-o '></i>" +
                "              </button> <a style='color: #d9534f;font-size:10px'>Delete contact</a> &nbsp;" +
                "              <button type='button' style='margin-top:7px' class='btn btn-primary btn-circle'><i class='fa fa-user-plus'></i>" +
                "              </button> <a style='color: #337ab7;font-size:10px'>Add as employee</a> &nbsp;" +
                "              <button type='button' style='margin-top:7px' class='btn btn-info btn-circle'><i class='fa fa-envelope-o '></i>" +
                "              </button> <a style='color: #5bc0de;font-size:10px'>Send invitation</a> &nbsp;" +
                "              <button type='button' style='margin-top:7px' data-toggle='modal' onclick='getContactProfileDetails("+contact_user_id+");' class='btn btn-success btn-circle'><i class='fa fa-link'></i>" +
                "               </button> <a data-toggle='modal' onclick='getContactProfileDetails();' data-target=#getContactProfileDetails style='color: #5cb85c;font-size:10px'>Refer contact</a>" +
                "          </td>" +
                "       </tr>" +
                " </tbody>";
        return s;
    }

    public ArrayList loadMyContacts_AL(String user_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        ArrayList mycontacts_list = new ArrayList();

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_getMycontacts);
            ps.setString(1, user_id);
            rs = ps.executeQuery();

            while (rs.next()) {
                String email = rs.getString("email");
                String contact_user_id = rs.getString("user_id");
                String lin_profile_picture_url = rs.getString("lin_profile_picture_url");

                HashMap hm = new HashMap();
                hm.put("email", email);
                hm.put("contact_user_id", contact_user_id);
                hm.put("lin_profile_picture_url", lin_profile_picture_url);

                mycontacts_list.add(hm);
            }
            return mycontacts_list;
        } catch (Exception e) {
            e.printStackTrace();
            return mycontacts_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    final String sql_getProfileDetails = "SELECT u.name as profile_name, u.email as profile_email, u.profile_image_file_name, u.businessdetails_image_file_name, u.user_type, s.* " +
            "            FROM users u LEFT JOIN employee_details s " +
            "            ON u.user_id = s.user_id " +
            "            where u.user_id = ?";

    public String getProfileDetails(String contact_user_id) {
        String profile_name = "";
        String profile_email = "";
        String profile_image_file_name = "";
        String profile_skills = "";
        String profile_linkedin = "";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String contact_details = "";

        try {
            con = getConnection();

            ps = getPs(con, sql_getProfileDetails);
            ps.setString(1, contact_user_id);

            rs = ps.executeQuery();

            while (rs.next()) {
                profile_name = rs.getString("profile_name");
                profile_email = rs.getString("profile_email");
                profile_image_file_name = rs.getString("profile_image_file_name");
                profile_linkedin = rs.getString("linkedin");
                profile_skills = rs.getString("expertise");

                profile_email = profile_email != null ? profile_email : "";
                profile_linkedin = profile_linkedin != null ? profile_linkedin : "";
                profile_skills = profile_skills != null ? profile_skills : "";

                contact_details = getContact_details(contact_user_id, profile_name, profile_email, profile_linkedin, profile_skills);
            }
            return contact_details;
        } catch (Exception e) {
            e.printStackTrace();
            return "An error occurred while getting developers list of friend. Please try again.";
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
    }

    public String getContact_details(String contact_user_id, String profile_name, String profile_email, String profile_linkedin, String profile_skills) {
        String s = "";

        profile_name = profile_name != null && profile_name.trim().length() > 0 ? profile_name.trim() : "";

        s = "<div class='line'><h2 class='text-center' style='color: #ffffff;'>Refer contact</h2></div>  " +
                "                   <div class='col-md-12 col-xs-12' align='center'>  " +
                "           <div class='outter'><img id='contactprofile_image_display' src='images/profile.jpg' onError='this.onerror=null;this.src='profile_images/profile.jpg';' class='image-circle'/></div> " +
                "           <input style='width: 250Px;margin-bottom: 15px' id='contactprofile_name' type='text' class='form-control text-center' value='"+profile_name+"'/> " +
                "             </div> " +
                "                 <div class='col-md-12 col-xs-12 login_control'>  " +
                "                     <div class='control'>  " +
                "                             <div class='row'> " +
                "                                   <div class='col-md-4 col-xs-4 login_control '>   " +
                "                                     <div class='label pull-right'>Linkedin</div>  " +
                "                                   </div>  " +
                "                                   <div class='col-md-6 col-xs-6 login_control'>  " +
                "                                       <input id='contactprofile_linkedin' type='text' class='form-control' value='"+profile_linkedin+"'/> " +
                "                                   </div>   " +
                "                                   <div class='col-md-1 col-xs-1 login_control'>  " +
                "                                       <a button class='btn btn-info btn-circle' onclick=\"window.open('https://www.linkedin.com', '_blank')\"   style='margin-top:1px' type='button'>  " +
                "                                           <i class='fa fa-linkedin '></i>  " +
                "                                       </button> </a>  " +
                "                               </div>   " +
                "                           </div>    " +
                "                       </div>        " +
                "                       <div class='control'>   " +
                "                           <div class='row'>   " +
                "                               <div class='col-md-4 col-xs-4 login_control '>   " +
                "                                   <div class='label pull-right'>Skills</div>  " +
                "                               </div>  " +
                "                               <div class='col-md-6 col-xs-6 login_control'>   " +
                "                                   <input id='contactprofile_skills' type='text' class='form-control' value='"+profile_skills+"'/>  " +
                "                               </div>  " +
                "                           </div><br>   " +
                " <div class='row'>" +
                "                <div id='contactprofile_details_status_success' align='center' style='display: none;'></div>" +
                "                <div id='contactprofile_details_status_failed' align='center' style='display: none;'></div>" +
                "            </div>"+
                "                           <div align='center'>   " +
                "                               <button id='contactprofile_save' type='submit'  data-toggle='button' class='btn btn-orange' style='color: #ffffff;' onclick='saveContactProfileDetailsAndRefer("+contact_user_id+");'>Refer</button>   " +
                "                               <button data-dismiss='modal' class='btn btn-orange' style='color: #ffffff;'>Close</button> " +
                "                           </div>  " +
                "                       </div>  " +
                "                       </div>";
        return s;
    }

    final String sql_insertReferAFriend = "insert into activities (posted_by, fl_userid, category, comments) values (?, ?, ?, ?)";
    final String sql_checkReferAFriend = "select * from activities where fl_userid = ? and posted_by = ?";
    final String sql_updateReferAFriend = "update activities set  comments = ? where  posted_by = ? and  fl_userid = ?";

    public int referTeamMember(String from_user_id, String contact_user_id, String contactprofile_linkedin, String contactprofile_name, String contactprofile_skills, String profile_doc, String profile_doc_uploaded_time,  String post_type) {
        int status = 0;
        String linkedin_str1 = "<a class='btn btn-info btn-simple btn-fill btn-sm' style='cursor: pointer; padding: 0px 5px' data-original-title='Linkedin profile' type='button' onclick=\"window.open('"+contactprofile_linkedin+"', '_blank'); event.stopPropagation();\"><i class='fa fa-linkedin'></i></a>";
        String linkedin_str = (contactprofile_linkedin != null && contactprofile_linkedin.trim().length() > 0 ? linkedin_str1 : "");

        String profile_doc_url = "<a class='btn btn-info btn-simple btn-fill btn-sm' style='cursor: pointer; padding: 0px 5px' data-original-title='Profile document' type='button' onclick=\"window.open('profile_doc/"+profile_doc_uploaded_time+"_"+profile_doc+"', '_blank'); event.stopPropagation();\"><i class='fa fa-file-text-o'></i></a>";
        String profile_doc_str = ((profile_doc_uploaded_time) != null && (profile_doc_uploaded_time).trim().length() > 0 ? profile_doc_url : "");

        contactprofile_skills = (contactprofile_skills != null && contactprofile_skills.trim().length() > 0 ? "Skills: "+contactprofile_skills.trim(): "");

        String post = contactprofile_name+" "+linkedin_str+" "+profile_doc_str+" | "+contactprofile_skills+"";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;
        try {
            con = getConnection();

            ps = getPs(con, sql_checkReferAFriend);
            ps.setString(1, contact_user_id);
            ps.setString(2, from_user_id);
            System.out.println(new Date()+"\t sql_checkReferAFriend -> ps: "+ps);
            rs = ps.executeQuery();

            if(rs.next()) {
                ps = getPs(con, sql_updateReferAFriend);
                ps.setString(1, post);
                ps.setString(2, from_user_id);
                ps.setString(3, contact_user_id);
                System.out.println(new Date()+"\t sql_updateReferAFriend -> ps: "+ps);
                status = ps.executeUpdate();
            } else {
                ps = getPs(con, sql_insertReferAFriend);
                ps.setString(1, from_user_id);
                ps.setString(2, contact_user_id);
                ps.setString(3, post_type);
                ps.setString(4, post);
                System.out.println(new Date()+"\t sql_insertReferAFriend -> ps: "+ps);
                status = ps.executeUpdate();
            }
        }
        catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }
    final String sql_checkFLSkills = "select * from employee_details where user_id = ?";
    final String sql_insertContactProfession = "insert into employee_details (linkedin,facebook,expertise, user_id) values (?, ?, ?, ?)";
    final String sql_updateContactProfession = "update employee_details set linkedin = ?, facebook = ?, expertise = ?  where user_id = ?";

    public int addOrUpdateContactProfileDetails(String contact_user_id, String contactprofile_linkedin, String contactprofile_fb, String contactprofile_skills) {
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

                ps.setString(1, contactprofile_linkedin);
                ps.setString(2, contactprofile_fb);
                ps.setString(3, contactprofile_skills);
                ps.setString(4, contact_user_id);

                status = ps.executeUpdate();
            } else {
                ps = getPs(con, sql_insertContactProfession);

                ps.setString(1, contactprofile_linkedin);
                ps.setString(2, contactprofile_fb);
                ps.setString(3, contactprofile_skills);
                ps.setString(4, contact_user_id);

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

    final String sql_check_refer_contact_to_hr = "select * from contact_referrals where from_user_id = ? and contact_user_id = ?";
    final String sql_insert_refer_contact_to_hr = "insert into contact_referrals (from_user_id, contact_user_id, active_status) values (?, ?, ?)";
    final String sql_update_refer_contact_to_hr = "update contact_referrals set active_status = ? where from_user_id = ? and contact_user_id = ?";

    public int referContactToHR(String from_user_id, String contact_user_id) {
        int status = 0;

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_check_refer_contact_to_hr);
            ps.setString(1, from_user_id);
            ps.setString(2, contact_user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                ps = getPs(con, sql_update_refer_contact_to_hr);
                ps.setInt(1, 1);
                ps.setString(2, from_user_id);
                ps.setString(3, contact_user_id);

                status = ps.executeUpdate();
            } else {
                ps = getPs(con, sql_insert_refer_contact_to_hr);
                ps.setString(1, from_user_id);
                ps.setString(2, contact_user_id);
                ps.setInt(3, 1);

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
    final String sql_getContact_details = "select * from users where user_id = ?";

    public String getContactDetails(String contact_user_id) {
        String contact_email = "";
        String contact_name = "";

        String msg = "";
        String status_msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();
            ps = getPs(con, sql_getContact_details);
            ps.setString(1, contact_user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                contact_email = rs.getString("email");
                contact_name = rs.getString("name");

                contact_name = contact_name != null ? contact_name : "";
            }

            msg =  "<div class='modal-dialog'>" +
                    "   <div class='modal-content' style='max-width: 550px'>" +
                    "       <div class='modal-header' style='background-color:#ff9500;border-radius: 5px 5px 0px 0px'>" +
                    "           <button type='button' class='close' data-dismiss='modal' style='color: white' aria-hidden='true'>&times;</button>" +
                    "           <h3 class='modal-title text-center' style='margin-bottom: 0px;height:15px;color: white' >Edit team member</h3></br>" +
                    "       </div>" +
                    "       <div class='modal-body'> " +
                    "           <div class='row'>" +
                    "               <div class='col-md-2' style=margin-left:10%;'>" +
                    "                   <h5 >Name</h5>" +
                    "               </div>" +
                    "               <div class='col-md-5' style='margin-left:-3%'>" +
                    "                   <input type='text' name='edit_contact_name' placeholder='e.g. Adams' class='form-control' id='edit_contact_name' style='width:300px'  value="+contact_name+">" +
                    "               </div>" +
                    "           </div><br>" +
                    "           <div class='row'>" +
                    "               <div class='col-md-2' style=margin-left:10%;'>" +
                    "                   <h5 >Email</h5>" +
                    "               </div>" +
                    "               <div class='col-md-5' style='margin-left:-3%'>" +
                    "                   <input type='text' name='edit_contact_email' placeholder='E.g. adamsxxx@xxx.com' class='form-control' id='edit_contact_email' style='width:300px'  value='"+contact_email+"' readonly>"+
                    "               </div>" +
                    "           </div><br>" +
                    "           <div class='modal-footer'>" +
                    "               <center>" +
                    "                   <button id='fcm_id' class='btn btn-fill btn-warning' data-toggle='button' type='submit' onclick=\"updateContactdetails("+contact_user_id+");\">Save</button>&nbsp;&nbsp;" +
                    "                   <button class='btn btn-secondary' data-toggle='button' data-dismiss='modal'>Cancel</button>" +
                    "               </center>" +
                    "           <div type='hidden' name='edit_client_status_msg' id='edit_contact_status_msg' class='alert alert-success text-center' style='display:none;margin-top:10px'>Successfully saved</div>" +

                    "           </div>" +
                    "       </div>" +
                    "   </div>" +
                    "</div>";
        } catch(Exception se) {
            System.err.print(se.getMessage());
            return msg;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return msg;
    }


    final String sql_deleteContact = "update users_mapping set status = 2 where from_user_id = ? and  to_user_id = ?";       //0 - not active; 1 - active; 2 - deleted

    public int deleteConcatDetails(String user_id,String contact_user_id) {
        int status = 0;

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();
            ps = getPs(con, sql_deleteContact);
            ps.setString(1, contact_user_id);
            ps.setString(2, user_id);
//            System.out.println("sql_deleteContact" + ps);
            status = ps.executeUpdate();
        } catch(Exception se) {
            System.err.print(se.getMessage());
            System.err.print(new Date()+"\t "+se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    //TODO, REMOVE after loadActivities_AL check - NOT USED NOW - 24Jan2017

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
        String post_likes = "";
        String post_dislikes = "";
        String post_comments = "";
        String msg = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        String sql_loadActivities = "" +
                "select u.user_id, u.email, u.name, u.fb_photo_path, a.activity_id, a.fl_userid, a.category, a.comments, a.posted_on, a.posted_by, a.posted_by as owner_id ,\n" +
                "(SELECT  COUNT(p.like_status) FROM post_likes p  WHERE  a.activity_id = p.activity_id and p.like_status='1'   GROUP BY p.activity_id) as post_likes ,\n" +
                "(SELECT  COUNT(p.like_status) FROM post_likes p  WHERE  a.activity_id = p.activity_id and p.like_status='0'   GROUP BY p.activity_id) as post_dislikes,\n" +
                "(SELECT  COUNT(q.activity_id) FROM activities_responses q WHERE  a.activity_id = q.activity_id  GROUP BY q.activity_id)  as post_comments from users_mapping rs, users u, activities a \n" +
                "where rs.to_user_id = u.user_id and rs.to_user_id = a.posted_by and rs.from_user_id = ? and a.status = 1 " +

                "order by posted_on DESC";

        try {
            con = getConnection();

            ps = getPs(con, sql_loadActivities);

            ps.setString(1, user_id);

//            System.out.println(new Date()+"\t loadActivities -> ps: "+ps);

            rs = ps.executeQuery();
            while(rs.next()) {
                posted_by_photo = rs.getString("fb_photo_path");
                activity_id = rs.getString("activity_id");
                category = rs.getString("category");
                comments = rs.getString("comments");
                posted_on = rs.getString("posted_on");
                posted_by = rs.getString("posted_by");
                owner_id = rs.getString("posted_by");
                post_likes = rs.getString("post_likes");
                post_dislikes = rs.getString("post_dislikes");
                post_comments = rs.getString("post_comments");
                fl_name = rs.getString("name");

                if(category.equalsIgnoreCase("asks") || category.equalsIgnoreCase("broadcast")) {
                    msg += loadActivitiesAsksString(con, activity_id, posted_by_photo, fl_name, comments, posted_on, posted_by, owner_id, post_likes,post_dislikes,post_comments);
                    System.out.println(msg);
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

    //TODO, REMOVE after loadActivities_AL check - NOT USED NOW - 24Jan2017

    public String loadActivitiesAsksString(Connection con, String activity_id, String posted_by_photo, String fl_name, String comments, String posted_on, String posted_by, String owner_id, String post_likes,String post_dislikes,String post_comments) {
        posted_by_photo = (posted_by_photo != null && posted_by_photo.trim().length() > 0 ? posted_by_photo : "images/profile.jpg");

        String Date_str1 = datetimeactivities(con, activity_id);

        String ret = " <dl style='margin-bottom:-2px;margin-top:0.5%;padding:0px; width: 99%;'> " +
                "                           <dd class='pos-left clearfix' > " +
                "                               <div class='events' style='margin-top:0px;display:inline;background-color:#f9f8f8;padding-right: 7px; box-shadow: 0.09em 0.09em 0.09em 0.05em #888888;'> " +
                "                            <div class='events-body' style='line-height:1.2'>" +
                "                            <div>     " +
                "                               <p align ='left' class='pull-left' style='font-size: 14px;line-height:1.3;display:inline;margin-bottom:0px;margin-top:2px;margin-left:3px'> " +
                "               "+ comments+" " +
                "                               </p> " +
                "                            </div>  " +
                "                            </div>  " +
                "                                <p class='pull-right' style='margin-left:2%;margin-bottom: 0px'>  " +
                "                               <img class='img-circle' style='max-width:30px' src="+posted_by_photo+" class='events-object img-rounded'> " +
                "                            </p>" +
                "                           <div class='events-right' style='margin-bottom:0%;margin-top: 1%'> " +
                "                               <div align='right' style='margin-left:9px'> " +
                "                                   <h3 class='events-heading text-right' style='display: inline;font-size: 14px'> "+fl_name+"  </h3> " +
                "                                   <p class='text-right text-muted' style='font-size: 10px; margin: 0 0 5px;'>"+Date_str1+"</p> " +
                "                               </div></div> " +
                /*"                                <div  align='center' class='event-body' style='margin-bottom:1%;display:inline'> " +
"                                      <div style='margin-bottom:20px;display:inline;'>  " +
"                     <button  style='padding:0px; margin-top: 5px;background-color:#ffefef;margin-bottom: 5px' class='btn btn-default btn-simple btn-md pull-left' rel='tooltip' title='Post Response' data-original-title='Post Response' type='button' data-toggle='modal' > " +
"                                                5&nbsp;<i class='fa fa-thumbs-o-up' style='color:#5bc0de;font-size: 20px'></i> &nbsp;&nbsp;&nbsp;  " +
"                                            </button>  " +
"                                           <button style='padding:0px; margin-top: 5px;background-color:#ffefef;margin-bottom: 5px;margin-right:15px' class='btn btn-default btn-simple btn-md pull-left' rel='tooltip' title='Post Response' data-original-title='Post Response' type='button' data-toggle='modal' >   " +
"                                               2&nbsp;<i class='fa fa-thumbs-o-down' style='color:#fa8072;font-size: 20px'></i>  " +
"                                           </button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  " +
"                                       <button  onclick=\\getpostdetailstodelete('+activity_id+');\\ data-toggle='modal' type='button'  style='padding:0px; margin-top: 5px;background-color:#ffefef;margin-bottom: 5px' class='btn btn-default btn-simple btn-md pull-left' ><i class='fa fa-times' style='color:#ff6666;font-size: 20px;'></i></button> " +
"\n" +
"                                            <button  id='showaskresponses_+activity_id+'  onclick='showmypost(+activity_id+);' style='padding:0px; margin-top: 5px;background-color:#ffefef;margin-bottom: 5px' class='btn btn-default btn-simple btn-md pull-right' type='button' data-toggle='modal'> " +
"                                                &nbsp;<i class='fa fa-arrow-circle-right' style='color:#5bc0de;font-size: 20px'></i>   " +
"                                           </button>  " +
"                                             <button  style='padding:0px; margin-top: 5px;background-color:#ffefef;margin-bottom: 5px' class='btn btn-default btn-simple btn-md pull-right' type='button' data-toggle='modal'>  " +
"                                                10&nbsp;<i class='fa fa-commenting-o' style='color:#F6BB42;font-size: 20px'></i> &nbsp;&nbsp;  " +
"                                           </button>   " +
"\n" +
"                                     </div> </div><br>"+*/
                "                                   </span> " +
                "                               </div> " +
                "                           </dd> " +
                "                                          <div id='show_ask_responses_+activity_id+' class='text-left' style='max-width: 98%;margin-bottom: 0%;max-height: 180px;overflow: auto;'></div>" +
                "                       </dl>" +
                "                           <div id='show_ask_responses_+activity_id+' class='text-left' style='max-width: 98%;margin-bottom: 0%;max-height: 35vh;overflow: auto;'></div>" +
                "                       </dl>" +
                "                       <p href='' class='pull-left' id='show_comment' onclick='showcommentbox();'><a>Add comment</a></p>" +
                "                <div class='row' style='display:none' id='commentbox'> " +
                "                                                    <div class='col-xs-9 text-left' style='margin-top: 1%;width:78%;padding:0px'> " +
                "                                                        <textarea type='text' class='form-control' style='height:35px;margin-left:6%;width: 95%;' placeholder='Comment' name='post_comment_in_network' id='post_comment_in_network'></textarea> " +
                "                                                    </div> " +
                "                                                <div class='col-xs-2 text-right' style='max-width:100%;margin-top:2.5%;padding:0px;width:20%'> " +
                "                                                    <button class='btn btn-sm btn-fill btn-info' style='margin-top: 1%;width:40px;margin-bottom: 5%;padding:3px' onclick=\\postResponseToAsk(+activity_id+); return false;\\>Post</button> " +
                "                                                </div> " +
                "                                                </div>";
        return ret;
    }

    public ArrayList<HashMap> loadNetworkActivities_AL(String user_id, String company_id) {
        String activity_id = "";
        String fl_userid = "";
        String fl_name = "";
        String category = "";
        String comments = "";
        String posted_on = "";
        String posted_by = "";
        String post_likes = "";
        String post_dislikes = "";
        String post_comments = "";
        String user_type = "";
        String lin_profile_picture_url = "";
        ArrayList activities_list = new ArrayList();

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        String sql_loadActivities_OLD_REMOVE_LATER = "" +
                "select u.user_id, u.email, u.name, u.fb_photo_path, u.lin_profile_picture_url, a.activity_id, a.fl_userid, a.category, a.comments, a.posted_on, a.posted_by, a.posted_by as owner_id, " +
                "(SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='1' GROUP BY p.activity_id) as post_likes ," +
                "(SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='2' GROUP BY p.activity_id) as post_dislikes, " +
                "(SELECT COUNT(q.activity_id) FROM activities_responses q WHERE  a.activity_id = q.activity_id  GROUP BY q.activity_id) as post_comments, " +
                " (SELECT user_type  FROM users WHERE  user_id =?) as user_type" +
                "from users_mapping um, users u, activities a " +
                "where um.to_user_id = u.user_id and um.to_user_id = a.posted_by and um.from_user_id = ? and a.status = 1 " +

                "order by posted_on DESC";

//        List posts posted_by by users who are from the same company_id, (//TODO, do we need to exclude logged in user's posts?)

        String sql_loadActivities = "" +
                "select u.user_id, u.email, u.name, u.fb_photo_path, u.lin_profile_picture_url, a.activity_id, a.fl_userid, a.category, a.comments, a.posted_on, a.posted_by, a.posted_by as owner_id, " +
                "(SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='1' GROUP BY p.activity_id) as post_likes ," +
                "(SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='2' GROUP BY p.activity_id) as post_dislikes, " +
                "(SELECT COUNT(q.activity_id) FROM activities_responses q WHERE  a.activity_id = q.activity_id  GROUP BY q.activity_id) as post_comments, " +
                "(SELECT user_type  FROM users WHERE  user_id =?) as user_type " +
                "FROM users u,  user_company_map ucm, activities a " +
                "WHERE u.user_id = ucm.user_id and ucm.user_id = a.posted_by and ucm.company_id = ? and a.category= 'refer' /*and u.user_id <> ?*/ and a.status = 1 and a.hired <>1  order by posted_on DESC";

        try {
            con = getConnection();

            ps = getPs(con, sql_loadActivities);
            ps.setString(1, user_id);
            ps.setString(2, company_id);

//            System.out.println(new Date()+"\t loadActivities_AL -> ps: "+ps);

            rs = ps.executeQuery();
            while(rs.next()) {
                activity_id = rs.getString("activity_id");
                category = rs.getString("category");
                comments = rs.getString("comments");
                posted_on = rs.getString("posted_on");
                posted_by = rs.getString("posted_by");
                post_likes = rs.getString("post_likes");
                post_dislikes = rs.getString("post_dislikes");
                post_comments = rs.getString("post_comments");
                fl_name = rs.getString("name");
                user_type = rs.getString("user_type");
                lin_profile_picture_url = rs.getString("lin_profile_picture_url");

                String posted_on_format = displayTimeInHoursMinsFormat(posted_on);

                HashMap hm = new HashMap();
                hm.put("activity_id", activity_id);
                hm.put("category", category);
                hm.put("comments", comments);
                hm.put("posted_on", posted_on);
                hm.put("posted_on_format", posted_on_format);
                hm.put("posted_by", posted_by);
                hm.put("post_likes", post_likes);
                hm.put("post_dislikes", post_dislikes);
                hm.put("post_comments", post_comments);
                hm.put("fl_name", fl_name);
                hm.put("lin_profile_picture_url", lin_profile_picture_url);
                hm.put("user_type", user_type);

                activities_list.add(hm);
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return activities_list;
    }

    public ArrayList<HashMap> loadPostRequirementActivities_AL(String user_id, String company_id) {
        String activity_id = "";
        String fl_userid = "";
        String fl_name = "";
        String category = "";
        String comments = "";
        String posted_on = "";
        String posted_by = "";
        String post_likes = "";
        String post_dislikes = "";
        String post_comments = "";
        String suggestion = "";
        String lin_profile_picture_url = "";
        ArrayList post_list = new ArrayList();

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        String sql_loadActivities_OLD_REMOVE_LATER = "" +
                "select u.user_id, u.email, u.name, u.fb_photo_path, u.lin_profile_picture_url, a.activity_id, a.fl_userid, a.category, a.comments, a.posted_on, a.posted_by, a.posted_by as owner_id, " +
                "(SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='1' GROUP BY p.activity_id) as post_likes ," +
                "(SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='2' GROUP BY p.activity_id) as post_dislikes, " +
                "(SELECT COUNT(q.activity_id) FROM activities_responses q WHERE  a.activity_id = q.activity_id  GROUP BY q.activity_id) as post_comments " +
                "from users_mapping um, users u, activities a " +
                "where um.to_user_id = u.user_id and um.to_user_id = a.posted_by and um.from_user_id = ? and a.status = 1 " +

                "order by posted_on DESC";

//        List posts posted_by by users who are from the same company_id, (//TODO, do we need to exclude logged in user's posts?)

        String sql_postrequirementActivities = "" +
                "select u.user_id, u.email, u.name, u.fb_photo_path, u.lin_profile_picture_url, a.activity_id, a.suggestion, a.fl_userid, a.category, a.comments, a.posted_on, a.posted_by, a.posted_by as owner_id, " +
                "(SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='1' GROUP BY p.activity_id) as post_likes ," +
                "(SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='2' GROUP BY p.activity_id) as post_dislikes, " +
                "(SELECT COUNT(q.activity_id) FROM activities_responses q WHERE  a.activity_id = q.activity_id  GROUP BY q.activity_id) as post_comments " +
                "FROM users u,  user_company_map ucm, activities a " +
                "WHERE u.user_id = ucm.user_id and ucm.user_id = a.posted_by and ucm.company_id = ? and a.category= 'asks' /*and u.user_id <> ?*/ and a.status = 1   order by posted_on DESC";

        try {
            con = getConnection();

            ps = getPs(con, sql_postrequirementActivities);
            ps.setString(1, company_id);
//            ps.setString(2, user_id);

//            System.out.println(new Date()+"\t loadActivities_AL -> ps: "+ps);

            rs = ps.executeQuery();
            while(rs.next()) {
                activity_id = rs.getString("activity_id");
                category = rs.getString("category");
                comments = rs.getString("comments");
                posted_on = rs.getString("posted_on");
                posted_by = rs.getString("posted_by");
                post_likes = rs.getString("post_likes");
                post_dislikes = rs.getString("post_dislikes");
                post_comments = rs.getString("post_comments");
                suggestion = rs.getString("suggestion");
                fl_name = rs.getString("name");
                lin_profile_picture_url = rs.getString("lin_profile_picture_url");

                String posted_on_format = displayTimeInHoursMinsFormat(posted_on);

                HashMap hm = new HashMap();
                hm.put("activity_id", activity_id);
                hm.put("category", category);
                hm.put("comments", comments);
                hm.put("posted_on", posted_on);
                hm.put("posted_on_format", posted_on_format);
                hm.put("posted_by", posted_by);
                hm.put("post_likes", post_likes);
                hm.put("post_dislikes", post_dislikes);
                hm.put("post_comments", post_comments);
                hm.put("fl_name", fl_name);
                hm.put("suggestion", suggestion);
                hm.put("lin_profile_picture_url", lin_profile_picture_url);

                post_list.add(hm);
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return post_list;
    }

    public ArrayList<HashMap> loadHiedCandidates_AL(String user_id, String company_id) {
        String activity_id = "";
        String fl_userid = "";
        String fl_name = "";
        String category = "";
        String comments = "";
        String posted_on = "";
        String posted_by = "";
        String post_likes = "";
        String post_dislikes = "";
        String post_comments = "";
        String lin_profile_picture_url = "";
        ArrayList hired_list = new ArrayList();

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

             String sql_hiredCandidates = "" +
                "select u.user_id, u.email, u.name, u.fb_photo_path, u.lin_profile_picture_url, a.activity_id, a.fl_userid, a.category, a.comments, a.posted_on, a.posted_by, a.posted_by as owner_id, " +
                "(SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='1' GROUP BY p.activity_id) as post_likes ," +
                "(SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='2' GROUP BY p.activity_id) as post_dislikes, " +
                "(SELECT COUNT(q.activity_id) FROM activities_responses q WHERE  a.activity_id = q.activity_id  GROUP BY q.activity_id) as post_comments " +
                "FROM users u,  user_company_map ucm, activities a " +
                "WHERE u.user_id = ucm.user_id and ucm.user_id = a.posted_by and ucm.company_id = ? and a.category= 'refer' /*and u.user_id <> ?*/ and a.status = 1 and a.hired =1   order by posted_on DESC";

        try {
            con = getConnection();

            ps = getPs(con, sql_hiredCandidates);
            ps.setString(1, company_id);
//            ps.setString(2, user_id);

//            System.out.println(new Date()+"\t loadActivities_AL -> ps: "+ps);

            rs = ps.executeQuery();
            while(rs.next()) {
                activity_id = rs.getString("activity_id");
                category = rs.getString("category");
                comments = rs.getString("comments");
                posted_on = rs.getString("posted_on");
                posted_by = rs.getString("posted_by");
                post_likes = rs.getString("post_likes");
                post_dislikes = rs.getString("post_dislikes");
                post_comments = rs.getString("post_comments");
                fl_name = rs.getString("name");
                lin_profile_picture_url = rs.getString("lin_profile_picture_url");

                String posted_on_format = displayTimeInHoursMinsFormat(posted_on);

                HashMap hm = new HashMap();
                hm.put("activity_id", activity_id);
                hm.put("category", category);
                hm.put("comments", comments);
                hm.put("posted_on", posted_on);
                hm.put("posted_on_format", posted_on_format);
                hm.put("posted_by", posted_by);
                hm.put("post_likes", post_likes);
                hm.put("post_dislikes", post_dislikes);
                hm.put("post_comments", post_comments);
                hm.put("fl_name", fl_name);
                hm.put("lin_profile_picture_url", lin_profile_picture_url);

                hired_list.add(hm);
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return hired_list;
    }

    public ArrayList<HashMap> loadMyActivities_AL(String user_id) {
        String activity_id = "";
        String fl_userid = "";
        String fl_name = "";
        String category = "";
        String comments = "";
        String posted_on = "";
        String posted_by = "";
        String post_likes = "";
        String post_dislikes = "";
        String post_comments = "";
        ArrayList activities_list = new ArrayList();

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        String sql_loadActivities = "" +
                "select a.*, u.*, " +
                "(SELECT  COUNT(p.like_status) FROM post_likes p  WHERE   p.activity_id =  a.activity_id and  p.like_status = 1 GROUP BY p.activity_id) as post_likes, " +
                "(SELECT  COUNT(p.like_status) FROM post_likes p  WHERE  p.activity_id =  a.activity_id and p.like_status = 2 GROUP BY p.activity_id) as post_dislikes, " +
                "(SELECT  COUNT(q.activity_id) FROM activities_responses q WHERE  a.activity_id = q.activity_id  GROUP BY q.activity_id)  as post_comments " +
                "from activities a,users u " +
                "where posted_by = ? and a.posted_by= u.user_id and category = 'asks' and status = 1 " +
                "order by posted_on DESC";

        try {
            con = getConnection();

            ps = getPs(con, sql_loadActivities);
            ps.setString(1, user_id);

            rs = ps.executeQuery();
            while(rs.next()) {
                activity_id = rs.getString("activity_id");
                category = rs.getString("category");
                comments = rs.getString("comments");
                posted_on = rs.getString("posted_on");
                posted_by = rs.getString("posted_by");
                post_likes = rs.getString("post_likes");
                post_dislikes = rs.getString("post_dislikes");
                post_comments = rs.getString("post_comments");
                fl_name = rs.getString("name");

                String posted_on_format = displayTimeInHoursMinsFormat(posted_on);

                HashMap hm = new HashMap();
                hm.put("activity_id", activity_id);
                hm.put("category", category);
                hm.put("comments", comments);
                hm.put("posted_on", posted_on);
                hm.put("posted_on_format", posted_on_format);
                hm.put("posted_by", posted_by);
                hm.put("post_likes", post_likes);
                hm.put("post_dislikes", post_dislikes);
                hm.put("post_comments", post_comments);
                hm.put("fl_name", fl_name);

                activities_list.add(hm);
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return activities_list;
    }

    public ArrayList<HashMap> loadPost_AL(String user_id, String activity_id) {
        String fl_userid = "";
        String fl_name = "";
        String category = "";
        String comments = "";
        String posted_on = "";
        String posted_by = "";
        String post_likes = "";
        String post_dislikes = "";
        String lin_profile_picture_url = "";
        String post_comments = "";
        ArrayList loadPost_list = new ArrayList();

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        String sql_loadPost = "select a.*, u.*," +
                "                (SELECT  COUNT(p.like_status) FROM post_likes p  WHERE   p.activity_id =  a.activity_id and  p.like_status = 1 GROUP BY p.activity_id) as post_likes, " +
                "                (SELECT  COUNT(p.like_status) FROM post_likes p  WHERE  p.activity_id =  a.activity_id and p.like_status = 2 GROUP BY p.activity_id) as post_dislikes, " +
                "                (SELECT  COUNT(q.activity_id) FROM activities_responses q WHERE  q.activity_id = a.activity_id  GROUP BY q.activity_id)  as post_comments " +
                "               from activities a,users u where activity_id = ? and a.posted_by= u.user_id and (category = 'asks' OR category = 'refer') and status = 1";

        try {
            con = getConnection();

            ps = getPs(con, sql_loadPost);
            ps.setString(1, activity_id);


            rs = ps.executeQuery();
            while(rs.next()) {
                activity_id = rs.getString("activity_id");
                category = rs.getString("category");
                comments = rs.getString("comments");
                posted_on = rs.getString("posted_on");
                posted_by = rs.getString("posted_by");
                post_likes = rs.getString("post_likes");
                post_dislikes = rs.getString("post_dislikes");
                post_comments = rs.getString("post_comments");
                fl_name = rs.getString("name");
                lin_profile_picture_url = rs.getString("lin_profile_picture_url");

                String posted_on_format = displayTimeInHoursMinsFormat(posted_on);

                HashMap hm = new HashMap();
                hm.put("activity_id", activity_id);
                hm.put("category", category);
                hm.put("comments", comments);
                hm.put("posted_on", posted_on);
                hm.put("posted_on_format", posted_on_format);
                hm.put("posted_by", posted_by);
                hm.put("post_likes", post_likes);
                hm.put("post_dislikes", post_dislikes);
                hm.put("post_comments", post_comments);
                hm.put("fl_name", fl_name);
                hm.put("lin_profile_picture_url", lin_profile_picture_url);

                loadPost_list.add(hm);
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return loadPost_list;
    }

    public String displayTimeInHoursMinsFormat(String posted_on) {
        String recommend_dateactivities ="";
        String converted_timeactivities =" ";

        String[] date_time = null;
        date_time = posted_on.split(" ");
        String Date_str = date_time[0];

        SimpleDateFormat originalFormat = new SimpleDateFormat("MM-dd-yyyy HH:mm:ss");
        SimpleDateFormat targettimeFormat = new SimpleDateFormat("HH:mm");

        Date date;
        try {
            date = originalFormat.parse(posted_on);
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

        return recommend_dateactivities;
    }

    final String sql_postCommentsInNetwork = "insert into activities (posted_by, fl_userid, category, comments,suggestion) values (?, ?, ?, ?, ?)";

    public String postCommentsInNetwork(String user_id, String fl_user_id, String post_type, String comments,String suggestion_status) {

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_postCommentsInNetwork);

            ps.setString(1, user_id);
            ps.setString(2, fl_user_id);
            ps.setString(3, post_type);
            ps.setString(4, comments);
            ps.setString(5, suggestion_status);

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

    final String sql_postAskResponse = "insert into activities_responses (activity_id, recommended_by, comments) values (?, ?, ?)";

    public int postResponse_ForPost(String user_id, String activity_id, String comments) {
        Connection con = null;
        PreparedStatement ps = null;
        int cnt = 0;

        try {
            con = getConnection();

            ps = getPs(con, sql_postAskResponse);
            ps.setString(1, activity_id);
            ps.setString(2, user_id);
            ps.setString(3, comments);
            cnt = ps.executeUpdate();

            if(cnt > 0) {
                return 1;
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return 0;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return 0;
    }

    final String sql_getResponses_ForPost = "select ar.s_no as response_id, u.email, u.name, u.fb_photo_path, ar.activity_id, ar.comments, ar.recommended_on,u.lin_profile_picture_url " +
            "from activities_responses ar, users u where ar.recommended_by = u.user_id and ar.activity_id = ? order by ar.recommended_on ASC";

    public ArrayList<HashMap> getResponses_ForPost(String activity_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        ArrayList activity_responses_list = new ArrayList();

        try {
            con = getConnection();

            ps = getPs(con, sql_getResponses_ForPost);
            ps.setString(1, activity_id);

            rs = ps.executeQuery();

            while(rs.next()) {
                String recommended_by_name = "";

                byte[] recommended_by_name_bytes = rs.getBytes("name");       //TODO, Not using email and contact number to display in UI as of now

                try {
//                    byte[] recommended_by_nam_bytes = processDecrypt(recommended_by_name_enc);
                    recommended_by_name = new String(recommended_by_name_bytes);
                } catch(Exception e) {
                    System.out.println(new Date()+"\t "+e.getMessage());
                    e.printStackTrace();
                    continue;
                }

                String response_id = rs.getString("response_id");
                String recommended_by_photo = rs.getString("fb_photo_path");
                String comments = rs.getString("comments");
                String recommended_on = rs.getString("recommended_on");
                String lin_profile_picture_url = rs.getString("lin_profile_picture_url");

                recommended_on = displayTimeInHoursMinsFormat(recommended_on);

                HashMap hm = new HashMap();
                hm.put("response_id", response_id);
                hm.put("recommended_by_name", recommended_by_name);
                hm.put("recommended_by_photo", recommended_by_photo);
                hm.put("comments", comments);
                hm.put("recommended_on", recommended_on);
                hm.put("lin_profile_picture_url", lin_profile_picture_url);

                activity_responses_list.add(hm);
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return activity_responses_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return activity_responses_list;
    }

   // final String sql_getSuggestions_forAsk = "select a.comments,b.name from activities a,users b,employee_details c where c.user_id= a.fl_userid and b.user_id=a.posted_by and expertise LIKE ?";
    final String sql_getSuggestions_forAsk = "select a.comments,b.name from activities a,users b,employee_details c,user_company_map d where c.user_id= a.fl_userid and b.user_id=a.posted_by and a.status = 1 and a.posted_by = d.user_id and expertise RLIKE  ? and d.company_id = ?";


    public ArrayList<HashMap> getSuggestions_forAsk(String comments,String company_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        ArrayList getSuggestions_forAsk_list = new ArrayList();
        String[] comments1 = comments.split(" ");

        try {
            con = getConnection();

            ps = getPs(con, sql_getSuggestions_forAsk);
            for (int i = 0; i < comments1.length; i++) {
                String comments2 = comments1[i];
              //  ps.setString(1, "%"+comments2+"%");
                 ps.setString(1, "([[:blank:][:punct:]]|^)"+comments2+"([[:blank:][:punct:]]|$)");
                ps.setString(2, company_id);
                System.out.println("sql_getSuggestions_forAsk :" + ps);
                rs = ps.executeQuery();

            while(rs.next()) {
                String name = rs.getString("name");
                String suggested_comments = rs.getString("comments");


                HashMap hm = new HashMap();
                hm.put("name", name);
                hm.put("suggested_comments", suggested_comments);

                getSuggestions_forAsk_list.add(hm);
            } }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return getSuggestions_forAsk_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return getSuggestions_forAsk_list;
    }

    final String sql_checfor_askSuggestions = "select a.comments,b.name from activities a,users b,employee_details c where c.user_id= a.fl_userid and b.user_id=a.posted_by and expertise RLIKE  ?";
    final String sql_NoAsk_suggestions = "insert into activities (post_suggestions) values ('1')";
    final String sql_Ask_suggestions_found = "update activities set post_suggestions = '0' where  activity_id = ?";

    public ArrayList<HashMap> checkSuggestions_forAsk(String comments) {
        int post_status = 0;
        System.out.println("comments"+comments);
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;
        String[] comments1 = comments.split(" ");
        System.out.println(comments1.length);
        ArrayList checkSuggestions_forAsk_list = new ArrayList();
        try {
            con = getConnection();
            ps = getPs(con, sql_checfor_askSuggestions);
            for (int i = 0; i < comments1.length; i++) {
                String comments2 = comments1[i];
                //  ps.setString(1, "%"+comments2+"%");
                ps.setString(1, "([[:blank:][:punct:]]|^)"+comments2+"([[:blank:][:punct:]]|$)");
                System.out.println("sql_checfor_askSuggestions :"+ ps);
                rs = ps.executeQuery();
                System.out.println("checkSuggestions_forAsk2");
                while(rs.next()) {
                    String name = rs.getString("name");
                    String suggested_comments = rs.getString("comments");
                    HashMap hm = new HashMap();
                    hm.put("name", name);
                    hm.put("suggested_comments", suggested_comments);

                    checkSuggestions_forAsk_list.add(hm);
                } }
        }  catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return checkSuggestions_forAsk_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return checkSuggestions_forAsk_list;
    }


    final String sql_getPost_likes_details = "SELECT a.name , b.like_status , b.user_id,b.activity_id, a.user_id from users a , post_likes b where a.user_id =b.user_id and b.activity_id =? and  b.like_status =1";

    public ArrayList<HashMap> getPost_like_details(String activity_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        System.out.println("activity_id :"+ activity_id);
        ArrayList my_activity_like_details_list = new ArrayList();

        try {
            con = getConnection();

            ps = getPs(con, sql_getPost_likes_details);
            ps.setString(1, activity_id);
            //  System.out.println("sql_getPost_likes_dislikes_details :"+ ps);
            rs = ps.executeQuery();

            while(rs.next()) {
                String like_details = rs.getString("name");
                HashMap hm = new HashMap();
                hm.put("like_details", like_details);

                my_activity_like_details_list.add(hm);
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return my_activity_like_details_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return my_activity_like_details_list;
    }

    final String sql_getPost_dislikes_details = "SELECT a.name , b.like_status , b.user_id,b.activity_id, a.user_id from users a , post_likes b where a.user_id =b.user_id and b.activity_id =? and  b.like_status =2";

    public ArrayList<HashMap> getPost_dislike_details(String activity_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        System.out.println("activity_id :"+ activity_id);
        ArrayList my_activity_dislike_details_list = new ArrayList();

        try {
            con = getConnection();

            ps = getPs(con, sql_getPost_dislikes_details);
            ps.setString(1, activity_id);
            //  System.out.println("sql_getPost_likes_dislikes_details :"+ ps);
            rs = ps.executeQuery();

            while(rs.next()) {
                String dislike_details = rs.getString("name");

                HashMap hm = new HashMap();
                hm.put("dislike_details", dislike_details);

                my_activity_dislike_details_list.add(hm);
            }
        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return my_activity_dislike_details_list;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return my_activity_dislike_details_list;
    }
    final String sql_checklikes = "select * from post_likes where activity_id = ? and user_id = ?";
    final String sql_insertlikeststus = "insert into post_likes (activity_id, user_id, like_status) values (?, ?, ?)";
    final String sql_updatelikestatus = "update post_likes set like_status = ? where  activity_id = ? and  user_id = ?";

    public int postLikeStatus(String user_id, String activity_id, String like_status) {
        int post_ststus = 0;

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_checklikes);
            ps.setString(1, activity_id);
            ps.setString(2, user_id);

            rs = ps.executeQuery();

            if(rs.next()) {
                ps = getPs(con, sql_updatelikestatus);
                ps.setString(1, like_status);
                ps.setString(2, activity_id);
                ps.setString(3, user_id);
                post_ststus = ps.executeUpdate();
            } else {
                ps = getPs(con, sql_insertlikeststus);
                ps.setString(1, activity_id);
                ps.setString(2, user_id);
                ps.setString(3, like_status);
                post_ststus = ps.executeUpdate();
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return post_ststus;
    }

    final String sql_checkhire = "select * from activities where activity_id = ? and hired = 1";
    final String sql_inserthiretstus = "insert into activities (hired) values (1)";
    final String sql_updatehirestatus = "update activities set hired = 1 where  activity_id = ?";


    public int candidatehired(String activity_id) {
        int post_ststus = 0;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();
            ps = getPs(con, sql_checkhire);
            ps.setString(1, activity_id);

            rs = ps.executeQuery();

            if(rs.next()) {
                ps = getPs(con, sql_inserthiretstus);
                ps.setString(1, activity_id);
                post_ststus = ps.executeUpdate();
            } else {
                ps = getPs(con, sql_updatehirestatus);
                ps.setString(1, activity_id);
                post_ststus = ps.executeUpdate();
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return post_ststus;
    }

    final String sql_getLikesCount_forActivity = "select * from post_likes where activity_id = ?";
    final String sql_getCommentsCount_forActivity = "select * from activities_responses where activity_id = ?";

    public String getNumbers_ForActivity(String activity_id) {
        int likes_no = 0;
        int dislikes_no = 0;
        int comments_no = 0;

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_getLikesCount_forActivity);
            ps.setString(1, activity_id);

            rs = ps.executeQuery();

            while(rs.next()) {
                int like_status = rs.getInt("like_status");

                if(like_status == 1) {
                    likes_no++;
                }
                if(like_status == 2) {
                    dislikes_no++;
                }
            }

            ps = getPs(con, sql_getCommentsCount_forActivity);
            ps.setString(1, activity_id);

            rs = ps.executeQuery();

            while(rs.next()) {
                comments_no++;
            }
        } catch(Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return "success|"+likes_no+"|"+dislikes_no+"|"+comments_no;
    }

    public String deletePostConfirmation(String user_id, String activity_id) {
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
                "             <button id='activity_id' class='btn  btn-info'  style='background-color:#2C93FF' data-toggle='button' type='submit' onclick='DeletePost("+activity_id+");'>Yes, delete</button>&nbsp;&nbsp;" +
                "             <button class='btn btn-secondary active' data-toggle='button' data-dismiss='modal'>Cancel</button>" +
                "          </center>" +
                "                <div id='deletepost_status_success' class='alert alert-success' align='center' style='display: none;margin-top:10px'>Successfully deleted</div>" +
                "        </div>";
        return msg;
    }

    final static String sql_deletePost = "update activities set status = 2 where posted_by = ? and activity_id = ?";
    public String deletePost(String user_id, String activity_id ) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_deletePost);
            ps.setString(1, user_id);
            ps.setString(2, activity_id);

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

    final static String sql_send_mail_to_hr = "select DISTINCT u.email as hremail,u.name as hr_name, d.company_id, COUNT(c.fl_userid ) as no_of_referals from users u,companies b ,activities c, user_company_map d where c.posted_by =  d.user_id and d.company_id = b.company_id and b.created_by = u.user_id and c.posted_on > DATE_ADD(NOW(), INTERVAL -1 DAY) group by b.company_id ";

    final static String sql_get_list_of_referrals_by_company_id = "SELECT ucm.company_id, COUNT(a.fl_userid) as no_of_referals FROM activities a, user_company_map ucm " +
            "WHERE a.posted_on >= CURDATE() and status = 1 and a.posted_by = ucm.user_id and a.category='refer' group by company_id";

    final static String sql_get_hr_details = "SELECT u.user_id, u.name as hr_name, u.email as hr_email from users u, user_company_map ucm " +
            "WHERE u.user_id = ucm.user_id and ucm.company_id = ? and u.user_type = 2";

    public String send_mail_to_hr() {
        Connection con = null;
        PreparedStatement ps = null;
        PreparedStatement ps2 = null;
        ResultSet rs = null;
        ResultSet rs2 = null;
        try {
            con = getConnection();

            ps = getPs(con, sql_get_list_of_referrals_by_company_id);

            rs = ps.executeQuery();
            while(rs.next()) {
                String company_id = rs.getString("company_id");
                String no_of_referals = rs.getString("no_of_referals");

                ps2 = getPs(con, sql_get_hr_details);
                ps2.setString(1, company_id);

                rs2 = ps2.executeQuery();

                while(rs2.next()) {
                    String hr_email = rs2.getString("hr_email");
                    String hr_name = rs2.getString("hr_name");
                    sendReferralStatusToHR(con, hr_name, hr_email, no_of_referals, company_id);
                }
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

    final static String sql_getnewReferaldetails = "select a.name, b.expertise,b.linkedin,a.profile_doc,a.profile_doc_uploaded_time  from users a, employee_details b,  activities c, user_company_map d WHERE a.user_id = b.user_id and b.user_id = c.fl_userid and c.posted_by =  d.user_id and d.company_id = ? and c.posted_on >= CURDATE()";

    public void sendReferralStatusToHR(Connection con, String hr_name, String hr_email, String no_of_referals, String company_id) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        String name = "";
        String expertise = "";
        String linkedin = "";
        String body ="";
        String name_tmp ="";
        String linkedin_tmp ="";
        String expertise_tmp ="";
        String mail_content ="";
        String profile_doc_uploaded_time ="";
        String profile_doc ="";
        String resume_url ="";
        String resume_url_tmp ="";
        ArrayList<HashMap> ud = new ArrayList<HashMap>();
        try {
            ps = getPs(con, sql_getnewReferaldetails);
            ps.setString(1, company_id);
            System.out.println("sql_getnewReferaldetails: "+ps);
            rs = ps.executeQuery();

            while(rs.next()) {
                name = rs.getString("name");
                linkedin = rs.getString("linkedin");
                expertise = rs.getString("expertise");
                profile_doc_uploaded_time = rs.getString("profile_doc_uploaded_time");
                profile_doc = rs.getString("profile_doc");
                System.out.println("profile_doc_uploaded_time"+profile_doc_uploaded_time);
                System.out.println("profile_doc"+profile_doc);


                if(profile_doc != null && profile_doc_uploaded_time != null && profile_doc != "" && profile_doc_uploaded_time != "" ){
                    profile_doc = profile_doc.replaceAll(" ","%20");
                    resume_url= profile_doc_uploaded_time+"_"+profile_doc;
                } else {
                    resume_url = "";
                }

                HashMap hm = new HashMap();
                hm.put("name",name);
                hm.put("linkedin",linkedin);
                hm.put("expertise",expertise);
                hm.put("resume_url",resume_url);

                ud.add(hm);
            }


            for(HashMap hm : ud) {
                name_tmp = (String)hm.get("name");
                linkedin_tmp = (String)hm.get("linkedin");
                expertise_tmp = (String)hm.get("expertise");
                resume_url_tmp = (String)hm.get("resume_url");

                mail_content +=
                        "      <div class='row' style='background-color:#f8fcfc;padding-top:3px;padding-bottom:1px'>  " +
                                "         <div class='col-xs-10 pull-left' style='margin-left: 5px;margin-top:5px;margin-bottom:5px'>   " +
                                "           <p style='font-size: 13px;margin-bottom: 3px;margin-top: 1px;margin-left: 3px'><b>Name  :</b> "+name_tmp+" </p>                                      " +
//                                "           <p style='font-size: 13px;margin-bottom: 3px;margin-top: 1px;margin-left: 3px'><b>Linkedin profile :</b> "+linkedin_tmp+" </p> " +
                                (linkedin_tmp != null && linkedin_tmp.trim().length() > 0 ? "<p style='font-size: 13px;margin-bottom: 3px;margin-top: 1px;margin-left: 3px'><b>Linkedin profile :</b> <a href="+linkedin_tmp+">"+linkedin_tmp+"</a> </p>" : "" )+"" +
                                (resume_url_tmp != null && resume_url_tmp.trim().length() > 0 ? "<p style='font-size: 13px;margin-bottom: 3px;margin-top: 1px;margin-left: 3px'><b>Profile :</b> <a href='http://localhost:8080/coref/profile_doc/"+resume_url_tmp+"'>http://localhost:8080/coref/profile_doc/"+resume_url_tmp+"</a> </p>" : "" )+"" +
                                "           <p style='font-size: 13px;margin-bottom: 3px;margin-top: 1px;margin-left: 3px'><b>Skills :</b> "+expertise_tmp+" </p>                                      " +
                                "    <p></p>        " +
                                "                       " +
                                "        </div>           " +
                                "                        " +
                                "   </div>                  " +
                                "               </div>        " +
                                "                             " +
                                "               </div>          " ;
            }
            body = "Hello "+hr_name+"," +
                    "<p style='font-size:14px'><b>"+no_of_referals+"</b> new referrals  added in your network <br><p>"+
                    mail_content+" " +
                    "               </div>";


            sendMailtoHR(body, hr_email);




        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
        }

    }


    public String sendMailtoHR(String body, String hr_email) {
        String status = "failed";
        try {
                 String result = sendHTMLEMail(hr_email, "Today's referrals and feedback", body);
            if (result.equals("send")) {
                System.out.println("succesfully sent");
            } else {
                System.out.println("mail sent failed");
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
        return status;
    }
    final String sql_getGraphforAnalytics = "SELECT  COUNT(a.fl_userid )as referrals, CAST(a.posted_on AS DATE) AS date  FROM activities a,user_company_map b  where a.posted_by = b.user_id and company_id= ? and fl_userid<>-1   GROUP BY CAST(a.posted_on AS DATE)  desc limit 15";
    public JSONArray getGraphforAnalytics(String company_id) {
        JSONArray arr = new JSONArray();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        ArrayList al2 = new ArrayList();
        String referrals =null;
        String date =null;
        try {

            con = getConnection();
            pstmt = getPs(con, sql_getGraphforAnalytics);
            pstmt.setString(1, company_id);
            rs = pstmt.executeQuery();
            while (rs.next()) {

                date= rs.getString("date");
                referrals = rs.getString("referrals");


                JSONObject tmp = new JSONObject();

                tmp.put("date",date); //some public getters inside GraphUser?
                tmp.put("referrals",referrals); //some public getters inside GraphUser?
                arr.add(tmp);

            }

        } catch (Exception e) {
            System.out.println(new Date() + "\t " + e.getMessage());
            e.printStackTrace();

        } finally {
            if (con != null) {
                closeConnection(con);
            }
        }
        return arr;
    }

    //TODO, REMOVE after loadActivities_AL check - NOT USED NOW - 24Jan2017
    final String sql_getdatetimeactivities = "select * from activities where activity_id = ?";
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

    final String sql_getReferrals = "select u.* ,a.* ," +
            "  (SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='1' GROUP BY p.activity_id) as post_likes ," +
            "  (SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='2' GROUP BY p.activity_id) as post_dislikes, " +
            "  (SELECT COUNT(q.activity_id) FROM activities_responses q WHERE  a.activity_id = q.activity_id  GROUP BY q.activity_id) as post_comments " +
            "  FROM users u, activities a " +
            "  WHERE u.user_id = a.posted_by and a.posted_by= ? and a.fl_userid <> -1  and a.status= 1 order by posted_on DESC";

    public ArrayList loadReferrals_AL(String from_user_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        ArrayList referral_list = new ArrayList();

        try {
            con = getConnection();
            ps = getPs(con, sql_getReferrals);
            ps.setString(1, from_user_id);
//            System.out.println("sql_getReferrals"+ps);
            rs = ps.executeQuery();
            HashMap hm;

            while (rs.next()) {
                String activity_id = rs.getString("activity_id");
                String category = rs.getString("category");
                String comments = rs.getString("comments");
                String posted_on = rs.getString("posted_on");
                String posted_by = rs.getString("posted_by");
                String post_likes = rs.getString("post_likes");
                String post_dislikes = rs.getString("post_dislikes");
                String post_comments = rs.getString("post_comments");
                String fl_name = rs.getString("name");
                String lin_profile_picture_url = rs.getString("lin_profile_picture_url");

                String posted_on_format = displayTimeInHoursMinsFormat(posted_on);
                hm = new HashMap();

                hm.put("activity_id", activity_id);
                hm.put("category", category);
                hm.put("comments", comments);
                hm.put("posted_on_format", posted_on_format);
                hm.put("posted_by", posted_by);
                hm.put("post_likes", post_likes);
                hm.put("post_dislikes", post_dislikes);
                hm.put("post_comments", post_comments);
                hm.put("fl_name", fl_name);
                hm.put("lin_profile_picture_url", lin_profile_picture_url);

                referral_list.add(hm);
            }

            return referral_list;
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

    public void sendInvitation(String domain_name, String to_email, String from_name) {
        System.out.println("send mail:"+domain_name +to_email);
        String status = "failed";
        try {
            String body = "Hello, <br><br>" +
                    "<p dir='ltr' style='margin-left: 20px; margin-right: 0px'>"+
                    "You are invited to join coref by "+from_name+".<br>"+
                    "&nbsp;&nbsp;&nbsp;&nbsp; - Register by visiting this link from PC: <a href=http://coref.co>http://coref.co</a><br>" +

                    "</p>"+

                    "Good Luck! <br>" +
                    "Thanks.";
            String result = sendHTMLEMail(to_email, "Coref invitation", body);
            if (result.equals("send")) {
                System.out.println("succesfully sent");
            } else {
                System.out.println("mail sent failed");
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }
    
    final String sql_getteamMemberReferrals = "select u.* ,a.* ," +
            "  (SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='1' GROUP BY p.activity_id) as post_likes ," +
            "  (SELECT COUNT(p.like_status) FROM post_likes p WHERE a.activity_id = p.activity_id and p.like_status='2' GROUP BY p.activity_id) as post_dislikes, " +
            "  (SELECT COUNT(q.activity_id) FROM activities_responses q WHERE  a.activity_id = q.activity_id  GROUP BY q.activity_id) as post_comments " +
            "  FROM users u, activities a " +
            "  WHERE u.user_id = a.posted_by and a.posted_by= ? and a.fl_userid <>-1 and a.status= 1 order by posted_on DESC";

    public ArrayList teamMember_Referrals_AL(String contact_user_id) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        ArrayList referral_list = new ArrayList();

        try {
            con = getConnection();
            ps = getPs(con, sql_getteamMemberReferrals);
            ps.setString(1, contact_user_id);
            System.out.println("sql_getteamMemberReferrals"+ps);
            rs = ps.executeQuery();
            HashMap hm;

            while (rs.next()) {
                String activity_id = rs.getString("activity_id");
                String category = rs.getString("category");
                String comments = rs.getString("comments");
                String posted_on = rs.getString("posted_on");
                String posted_by = rs.getString("posted_by");
                String post_likes = rs.getString("post_likes");
                String post_dislikes = rs.getString("post_dislikes");
                String post_comments = rs.getString("post_comments");
                String fl_name = rs.getString("name");
                String lin_profile_picture_url = rs.getString("lin_profile_picture_url");

                String posted_on_format = displayTimeInHoursMinsFormat(posted_on);
                hm = new HashMap();

                hm.put("activity_id", activity_id);
                hm.put("category", category);
                hm.put("comments", comments);
                hm.put("posted_on_format", posted_on_format);
                hm.put("posted_by", posted_by);
                hm.put("post_likes", post_likes);
                hm.put("post_dislikes", post_dislikes);
                hm.put("post_comments", post_comments);
                hm.put("fl_name", fl_name);
                hm.put("lin_profile_picture_url", lin_profile_picture_url);

                referral_list.add(hm);
                System.out.println(hm);
            }

            return referral_list;
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
    

    public void inviteTeamMember(String from_name, String to_email, String company_id_enc) {
        try {
            String body = "Hello, <br><br>" +
                    "<p dir='ltr' style='margin-left: 20px; margin-right: 0px'>"+
                    "    You are invited to join Coref by "+from_name+"<br>"+
                    "    &nbsp;&nbsp;&nbsp;&nbsp; - You can join to the network by visiting this link from PC: <a href=http://coref.co/coref/join.html?"+company_id_enc+">http://coref.co/coref/join.html?"+company_id_enc+"</a><br>" +
                    "</p>"+

                    "Good Luck! <br>" +
                    "Thanks.";

            System.out.println(new Date()+"\t inviteTeamMember: "+body);

            String result = sendHTMLEMail(to_email, "Invitation to join Coref", body);
            if (result.equals("send")) {
                System.out.println("succesfully sent");
            } else {
                System.out.println("mail sent failed");
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    final String sql_checkUserRelation = "select * from users_mapping where from_user_id = ? and to_user_id = ?";
    final String sql_insertUserRelation = "insert into users_mapping (from_user_id, to_user_id) values (?, ?)";
    final String  sql_upateUserRelation = "update users_mapping set from_user_id = ?, to_user_id = ?  where from_user_id = ? and to_user_id = ?";

    public int postRelationTypeToDB(Connection con, String user_id, String to_user_id) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        int rs_id = -1;

        try {
            ps = getPs(con, sql_checkUserRelation);
            ps.setString(1, user_id);
            ps.setString(2, to_user_id);
//            System.out.println("sql_checkUserRelation"+ps);
            rs = ps.executeQuery();

            if(rs.next()) {
                ps = getPs(con, sql_upateUserRelation);
                ps.setString(1, user_id);
                ps.setString(2, to_user_id);
                ps.setString(3, user_id);
                ps.setString(4, to_user_id);
//                System.out.println("sql_updatecompany_map ps"+ ps);
                rs_id = ps.executeUpdate();
            } else {
                ps = getPs(con, sql_insertUserRelation);

                ps.setString(1, user_id);
                ps.setString(2, to_user_id);
//                System.out.println("sql_insertcompany_map ps"+ ps);
                rs_id = ps.executeUpdate();
            }

        } catch (Exception e) {
            System.out.println(new Date()+"\t "+e.getMessage());
            e.printStackTrace();
            return rs_id;
        }
        return rs_id;
    }
    final String sql_updateContactdetails = "update users set name = ? where user_id =?";

    public String updateContactdetails(String contact_name, String contact_email, String contact_user_id, String user_id) {
        String status = "failed:Could not update contact details. Please try again";

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();
            ps = con.prepareStatement(sql_updateContactdetails);

            ps.setString(1, contact_name);
            ps.setString(2, contact_user_id);

            int cnt = ps.executeUpdate();

            if(cnt > 0) {
                status = "success:";
            }

        } catch(Exception se) {
            System.err.print(se.getMessage());
            return status;
        } finally {
            if(con != null ) {
                closeConnection(con);
            }
        }
        return status;
    }

    final String sql_getUserProfileDetails = "" +
            "SELECT u.name as profile_name, u.profile_image_file_name, u.businessdetails_image_file_name, " +
            "u.user_type, c.domain_name, s.linkedin, s.expertise, s.hr_consent, s.profession " +
            "FROM users u, companies c, user_company_map m LEFT JOIN employee_details s " +
            "ON m.user_id = s.user_id " +
            "where m.user_id = u.user_id and m.company_id = c.company_id and u.user_id = ? ";

    public ArrayList getProfileDetails_AL(String from_user_id, String lin_publicProfileUrl) {
        String profile_name = "";
        String profile_profession = "";
        String profile_expertise = "";
        String profile_linkedin = "";
        String domain_name = "";
        int user_type = 0;
        String hr_consent = "";

        ArrayList profile_details = new ArrayList();

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_getUserProfileDetails);
            ps.setString(1, from_user_id);
            rs = ps.executeQuery();

            if (rs.next()) {
                profile_profession = rs.getString("profession");
                profile_expertise = rs.getString("expertise");
                profile_linkedin = rs.getString("linkedin");
                user_type = rs.getInt("user_type");
                hr_consent = rs.getString("hr_consent");
                profile_name = rs.getString("profile_name");
                domain_name = rs.getString("domain_name");

                try {
                    profile_name = profile_name != null ? profile_name : "";
                    profile_profession = profile_profession != null ? profile_profession : "";
                    profile_linkedin = profile_linkedin != null ? profile_linkedin : "";
                    lin_publicProfileUrl = lin_publicProfileUrl != null ? lin_publicProfileUrl : "";
                    domain_name = domain_name != null ? domain_name : "";

                    HashMap hm = new HashMap();
                    hm.put("from_user_id", from_user_id);
                    hm.put("profile_name", profile_name);
                    hm.put("profile_profession", profile_profession);
                    hm.put("profile_expertise", profile_expertise);
                    hm.put("profile_linkedin", profile_linkedin);
                    hm.put("user_type", user_type);
                    hm.put("hr_consent", hr_consent);
                    hm.put("lin_publicProfileUrl", lin_publicProfileUrl);
                    hm.put("domain_name", domain_name);

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

    public String saveProfileDetails(String from_user_id, String profile_name,
                                     String profile_expertise, String profile_linkedin,
                                     String hr_consent) {
        int skills_status = addOrUpdateProfileskills(profile_expertise, profile_linkedin, from_user_id, hr_consent);

        if(skills_status > 0) {
            return "success";
        }
        return "failed";
    }

    final String sql_checkProfileSkills = "select * from employee_details where user_id = ?";
    final String sql_insertProfileSkills = "insert into employee_details (expertise,linkedin,  hr_consent, user_id) values (?, ?, ?, ?)";
    final String sql_updateProfileSkills = "update employee_details set  expertise = ?, linkedin = ?,  hr_consent = ? where user_id = ?";

    public int addOrUpdateProfileskills(String expertise, String linkedin,  String from_user_id, String hr_consent) {
        int status = 0;

        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;

        try {
            con = getConnection();

            ps = getPs(con, sql_checkProfileSkills);
            ps.setString(1, from_user_id);
            rs = ps.executeQuery();

            if(rs.next()) {
                ps = getPs(con, sql_updateProfileSkills);

                ps.setString(1, expertise);
                ps.setString(2, linkedin);
                ps.setString(3, hr_consent);
                ps.setString(4, from_user_id);

                status = ps.executeUpdate();
            } else {
                ps = getPs(con, sql_insertProfileSkills);

                ps.setString(1, expertise);
                ps.setString(2, linkedin);
                ps.setString(3, hr_consent);
                ps.setString(4, from_user_id);

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

    final String sql_getGamificationdetails = "SELECT  COUNT(a.fl_userid) AS  referals, b.name  FROM activities a, users b  where a.posted_by = b.user_id and a.posted_by= ? and category = 'refer' and a.status= 1 group by a.posted_by";

    public ArrayList gamification_AL(String posted_by) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String name = null;
        String referals = null;
        String level1 = " ";
        String level2 = " ";
        String level3 = " ";
        String level4 = " ";
        String level5 = " ";
        String progress = " ";
        ArrayList gamification_list = new ArrayList();

        try {
            con = getConnection();

            ps = getPs(con, sql_getGamificationdetails);
            ps.setString(1, posted_by);
      //      System.out.println(new Date()+"\t sql_getGamificationdetails -> ps: "+ps);
            rs = ps.executeQuery();
            HashMap hm;
            while (rs.next()) {
                referals = rs.getString("referals");
                name = rs.getString("name");
                int points = (Integer.parseInt(referals))*2;
                int points_requied_l2 = ((level_2)-points);
                int points_requied_l3 = ((level_3)-points);
                int points_requied_l4 = ((level_4)-points);
                int points_requied_l5 = ((level_5)-points);
                String border_radius_l1 = "";
                String border_radius_l2 = "";
                String border_radius_l3 = "";
                String border_radius_l4 = "";
                String border_radius_l5 = "";
                String opacityl1 = "opacity:0.4";
                String opacityl2 = "opacity:0.4";
                String opacityl3 = "opacity:0.4";
                String opacityl4 = "opacity:0.4";
                String opacityl5 = "opacity:0.4";
                String progress_width ="";
                String points_nxt ="";


                if (points<=level_1){
                    border_radius_l1 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:0.1";
                    opacityl3 = "opacity:0.1";
                    opacityl4 = "opacity:0.1";
                    opacityl5 = "opacity:0.1";
                    if(points<=20) {
                        progress_width = "width:3%";
                    }else if (points>=21 && points<=25){
                        progress_width = "width:8%";
                    }else if (points>=26 && points<=30){
                        progress_width = "width:12%";
                    }else if (points>=31 && points<=35){
                        progress_width = "width:20%";
                    } else if (points>=36 && points<=45) {
                        progress_width = "width:25%";
                    }
                    points_nxt = points_requied_l2+"";
                } else if (points <=level_2){
                    border_radius_l2 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:1";
                    opacityl3 = "opacity:0.1";
                    opacityl4 = "opacity:0.1";
                    opacityl5 = "opacity:0.1";
                    if(points<=60) {
                        progress_width = "width:27%";
                    }else if (points>=61 && points<=65){
                        progress_width = "width:33%";
                    }else if (points>=66 && points<=70){
                        progress_width = "width:38%";
                    }else if (points>=71 && points<=85){
                        progress_width = "width:44%";
                    } else if (points>=86 && points<=90){
                        progress_width = "width:48%";
                    }
                    points_nxt = points_requied_l3+"";
                } else  if (points<=level_3){
                    border_radius_l3 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:1";
                    opacityl3 = "opacity:1";
                    opacityl4 = "opacity:0.1";
                    opacityl5 = "opacity:0.1";
                    if(points<=110) {
                        progress_width = "width:50%";
                    }else if (points>=111 && points<=120){
                        progress_width = "width:57%";
                    }else if (points>=121 && points<=130){
                        progress_width = "width:62%";
                    }else if (points>=131 && points<=140){
                        progress_width = "width:68%";
                    } else if (points>=141 && points<=145){
                        progress_width = "width:72%";
                    }
                    points_nxt = points_requied_l4+"";
                } else if (points<=level_4){
                    border_radius_l4 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:1";
                    opacityl3 = "opacity:1";
                    opacityl4 = "opacity:1";
                    opacityl5 = "opacity:0.1";
                    if(points<=220) {
                        progress_width = "width:75%";
                    }else if (points>=230 && points<=245){
                        progress_width = "width:80%";
                    }else if (points>=246 && points<=255){
                        progress_width = "width:85%";
                    }else if (points>=256 && points<=270){
                        progress_width = "width:90%";
                    } else if (points>=271 && points<=280){
                        progress_width = "width:95%";
                    } else if (points>=281 && points<=295){
                        progress_width = "width:97%";
                    }
                    points_nxt = points_requied_l5+"";
                } else if (points<=level_5){
                    border_radius_l5 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:1";
                    opacityl3 = "opacity:1";
                    opacityl4 = "opacity:1";
                    opacityl5 = "opacity:1";
                    progress_width = "width:100%";

                }
                level1 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#ffffff;border-color: #ffffff;color: #000000;"+opacityl1+"'>" +
                        "    <img   src='images/111.jpg' style='width: 40px;height: 40px;"+border_radius_l1+"'>" +
                        "  </button>";
                level2 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#ffffff;border-color: #ffffff;color: #000000;"+opacityl2+"'>" +
                        "    <img   src='images/222.png' style='width: 40px;height: 40px;"+border_radius_l2+"'>" +
                        "  </button>";
                level3 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#ffffff;border-color: #ffffff;color: #000000;"+opacityl3+"'>" +
                        "    <img   src='images/333.jpg' style='width: 40px;height: 40px;"+border_radius_l3+"'>" +
                        "  </button>";
                level4 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#ffffff;border-color: #ffffff;color: #000000;"+opacityl4+"'>" +
                        "    <img   src='images/444.jpg' style='width: 40px;height: 40px;"+border_radius_l4+"'>" +
                        "  </button>";
                level5 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#ffffff;border-color: #ffffff;color: #000000;"+opacityl5+"'>" +
                        "    <img   src='images/555.png' style='width: 40px;height: 40px;"+border_radius_l5+"'>" +
                        "  </button>";
                progress = "<div class='progress' style='height: 7px;color: #000000;margin-top: 2px;margin-bottom: 0px' >" +
                        "     <div data-percentage='0%' style='"+progress_width+";background-color: #00B8D4;' class='progress-bar progress-bar-success' role='progressbar' aria-valuemin='0' aria-valuemax='100' ></div>" +
                        "  </div>"+
                        "<p class='text-center' style='color: #000000;margin-top: 3px;margin-bottom: 3px;font-size: 12px;font-family: \"Lato\",sans-serif'><b>"+points_nxt+"</b>  more points required for next level</p>";

                hm = new HashMap();
                hm.put("referals", referals);
                hm.put("name", name);
                hm.put("points", points);
                hm.put("level1", level1);
                hm.put("level2", level2);
                hm.put("level3", level3);
                hm.put("level4", level4);
                hm.put("level5", level5);
                hm.put("progress", progress);
                gamification_list.add(hm);
            }
            return gamification_list;
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

    final String sql_getTopreferals = "SELECT COUNT(a.fl_userid) AS  referals, b.name ,b.user_id,b.lin_profile_picture_url FROM activities a, users b,user_company_map c WHERE a.posted_by= b.user_id and a.status=1 and a.category = 'refer' and a.posted_by=c.user_id and c.company_id = ?  GROUP BY a.posted_by ORDER BY referals desc limit 10\n";

    public ArrayList topreferals_AL(String company_id ) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String name = null;
        String referals = null;
        String user_id = null;
        String lin_profile_picture_url = null;
        String topreferal_level1 = " ";
        String  topreferal_level2 = " ";
        String  topreferal_level3 = " ";
        String  topreferal_level4 = " ";
        String  topreferal_level5 = " ";
        String  topreferal_progress = " ";
        ArrayList topreferals_list = new ArrayList();

        try {
            con = getConnection();

            ps = getPs(con, sql_getTopreferals);
            ps.setString(1, company_id);
            rs = ps.executeQuery();
            HashMap hm;
            while (rs.next()) {
                referals = rs.getString("referals");
                name = rs.getString("name");
                user_id = rs.getString("user_id");
                lin_profile_picture_url = rs.getString("lin_profile_picture_url");
                int points = (Integer.parseInt(referals))*2;
                int points_requied_l2 = ((level_2)-points);
                int points_requied_l3 = ((level_3)-points);
                int points_requied_l4 = ((level_4)-points);
                int points_requied_l5 = ((level_5)-points);

                String border_radius_l1 = "";
                String border_radius_l2 = "";
                String border_radius_l3 = "";
                String border_radius_l4 = "";
                String border_radius_l5 = "";
                String opacityl1 = "opacity:0.1";
                String opacityl2 = "opacity:0.1";
                String opacityl3 = "opacity:0.1";
                String opacityl4 = "opacity:0.1";
                String opacityl5 = "opacity:0.1";
                String progress_width ="";
                String points_nxt ="";


                if (points<=level_1){
                    border_radius_l1 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:0.1";
                    opacityl3 = "opacity:0.1";
                    opacityl4 = "opacity:0.1";
                    opacityl5 = "opacity:0.1";
                    if(points<=20) {
                        progress_width = "width:3%";
                    }else if (points>=21 && points<=25){
                        progress_width = "width:8%";
                    }else if (points>=26 && points<=30){
                        progress_width = "width:12%";
                    }else if (points>=31 && points<=35){
                        progress_width = "width:20%";
                    } else if (points>=36 && points<=45) {
                        progress_width = "width:25%";
                    }
                    points_nxt = points_requied_l2+"";
                } else if (points <=level_2){
                    border_radius_l2 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:1";
                    opacityl3 = "opacity:0.1";
                    opacityl4 = "opacity:0.1";
                    opacityl5 = "opacity:0.1";
                    if(points<=60) {
                        progress_width = "width:27%";
                    }else if (points>=61 && points<=65){
                        progress_width = "width:33%";
                    }else if (points>=66 && points<=70){
                        progress_width = "width:38%";
                    }else if (points>=71 && points<=85){
                        progress_width = "width:44%";
                    } else if (points>=86 && points<=90){
                        progress_width = "width:48%";
                    }
                    points_nxt = points_requied_l3+"";
                } else  if (points<=level_3){
                    border_radius_l3 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:1";
                    opacityl3 = "opacity:1";
                    opacityl4 = "opacity:0.1";
                    opacityl5 = "opacity:0.1";
                    if(points<=110) {
                        progress_width = "width:50%";
                    }else if (points>=111 && points<=120){
                        progress_width = "width:57%";
                    }else if (points>=121 && points<=130){
                        progress_width = "width:62%";
                    }else if (points>=131 && points<=140){
                        progress_width = "width:68%";
                    } else if (points>=141 && points<=145){
                        progress_width = "width:72%";
                    }
                    points_nxt = points_requied_l4+"";
                } else if (points<=level_4){
                    border_radius_l4 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:1";
                    opacityl3 = "opacity:1";
                    opacityl4 = "opacity:1";
                    opacityl5 = "opacity:0.1";
                    if(points<=220) {
                        progress_width = "width:75%";
                    }else if (points>=230 && points<=245){
                        progress_width = "width:80%";
                    }else if (points>=246 && points<=255){
                        progress_width = "width:85%";
                    }else if (points>=256 && points<=270){
                        progress_width = "width:90%";
                    } else if (points>=271 && points<=280){
                        progress_width = "width:95%";
                    } else if (points>=281 && points<=295){
                        progress_width = "width:97%";
                    }
                    points_nxt = points_requied_l5+"";
                } else if (points<=level_5){
                    border_radius_l5 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:1";
                    opacityl3 = "opacity:1";
                    opacityl4 = "opacity:1";
                    opacityl5 = "opacity:1";
                    progress_width = "width:100%";

                }
                topreferal_level1 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#f2f2f2;border-color: #f2f2f2;color: #000000;"+opacityl1+"'>" +
                        "    <img   src='images/111.jpg' style='width: 40px;height: 40px;"+border_radius_l1+"'>" +
                        "  </button>";
                topreferal_level2 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#f2f2f2;border-color: #f2f2f2;color: #000000;"+opacityl2+"'>" +
                        "    <img   src='images/222.png' style='width: 40px;height: 40px;"+border_radius_l2+"'>" +
                        "  </button>";
                topreferal_level3 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#f2f2f2;border-color: #f2f2f2;color: #000000;"+opacityl3+"'>" +
                        "    <img   src='images/333.jpg' style='width: 40px;height: 40px;"+border_radius_l3+"'>" +
                        "  </button>";
                topreferal_level4 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#f2f2f2;border-color: #f2f2f2;color: #000000;"+opacityl4+"'>" +
                        "    <img   src='images/444.jpg' style='width: 40px;height: 40px;"+border_radius_l4+"'>" +
                        "  </button>";
                topreferal_level5 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#f2f2f2;border-color: #f2f2f2;color: #000000;"+opacityl5+"'>" +
                        "    <img   src='images/555.png' style='width: 40px;height: 40px;"+border_radius_l5+"'>" +
                        "  </button>";
                topreferal_progress = "<div class='progress' style='height: 7px;color: #000000;margin-top: 2px;margin-bottom: 0px' >" +
                        "     <div data-percentage='0%' style='"+progress_width+";background-color: #00B8D4;' class='progress-bar progress-bar-success' role='progressbar' aria-valuemin='0' aria-valuemax='100' ></div>" +
                        "  </div>"+
                        "<p class='text-center' style='color: #000000;margin-top: 3px;margin-bottom: 3px;font-size: 12px;font-family: \"Lato\",sans-serif'><b>"+points_nxt+"</b>  more points required for next level</p>";

                hm = new HashMap();
                hm.put("referals", referals);
                hm.put("name", name);
                hm.put("user_id", user_id);
                hm.put("points", points);
                hm.put("topreferal_level1", topreferal_level1);
                hm.put("topreferal_level2", topreferal_level2);
                hm.put("topreferal_level3", topreferal_level3);
                hm.put("topreferal_level4", topreferal_level4);
                hm.put("topreferal_level5", topreferal_level5);
                hm.put("topreferal_progress", topreferal_progress);
                hm.put("lin_profile_picture_url", lin_profile_picture_url);

                topreferals_list.add(hm);
            }
            return topreferals_list;
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


    final String sql_getrainmaker = "SELECT COUNT(a.fl_userid) AS  referals, b.name ,b.user_id,b.lin_profile_picture_url FROM activities a, users b,user_company_map c  WHERE a.posted_by= b.user_id and a.status=1 and a.category = 'refer' and a.posted_by=c.user_id and c.company_id = ? and posted_on BETWEEN (SELECT CURDATE() - INTERVAL (WEEKDAY(CURDATE())+1) DAY) AND (SELECT DATE_ADD((SELECT CURDATE() - INTERVAL (WEEKDAY(CURDATE())+1)DAY),INTERVAL 7 DAY))GROUP BY a.posted_by ORDER BY referals desc limit 1";


    public ArrayList rainmaker_AL(String company_id ) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String name = null;
        String referals = null;
        String user_id = null;
        String lin_profile_picture_url = null;
        String topreferal_level1 = " ";
        String  topreferal_level2 = " ";
        String  topreferal_level3 = " ";
        String  topreferal_level4 = " ";
        String  topreferal_level5 = " ";
        String  topreferal_progress = " ";
        ArrayList rainmaker_list_json = new ArrayList();

        try {
            con = getConnection();

            ps = getPs(con, sql_getrainmaker);
            ps.setString(1, company_id);
            rs = ps.executeQuery();
            HashMap hm;
            while (rs.next()) {
                referals = rs.getString("referals");
                name = rs.getString("name");
                user_id = rs.getString("user_id");
                lin_profile_picture_url = rs.getString("lin_profile_picture_url");
                int points = (Integer.parseInt(referals))*2;
                int points_requied_l2 = ((level_2)-points);
                int points_requied_l3 = ((level_3)-points);
                int points_requied_l4 = ((level_4)-points);
                int points_requied_l5 = ((level_5)-points);

                String border_radius_l1 = "";
                String border_radius_l2 = "";
                String border_radius_l3 = "";
                String border_radius_l4 = "";
                String border_radius_l5 = "";
                String opacityl1 = "opacity:0.1";
                String opacityl2 = "opacity:0.1";
                String opacityl3 = "opacity:0.1";
                String opacityl4 = "opacity:0.1";
                String opacityl5 = "opacity:0.1";
                String progress_width ="";
                String points_nxt ="";


                if (points<=level_1){
                    border_radius_l1 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:0.1";
                    opacityl3 = "opacity:0.1";
                    opacityl4 = "opacity:0.1";
                    opacityl5 = "opacity:0.1";
                    if(points<=20) {
                        progress_width = "width:3%";
                    }else if (points>=21 && points<=25){
                        progress_width = "width:8%";
                    }else if (points>=26 && points<=30){
                        progress_width = "width:12%";
                    }else if (points>=31 && points<=35){
                        progress_width = "width:20%";
                    } else if (points>=36 && points<=45) {
                        progress_width = "width:25%";
                    }
                    points_nxt = points_requied_l2+"";
                } else if (points <=level_2){
                    border_radius_l2 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:1";
                    opacityl3 = "opacity:0.1";
                    opacityl4 = "opacity:0.1";
                    opacityl5 = "opacity:0.1";
                    if(points<=60) {
                        progress_width = "width:27%";
                    }else if (points>=61 && points<=65){
                        progress_width = "width:33%";
                    }else if (points>=66 && points<=70){
                        progress_width = "width:38%";
                    }else if (points>=71 && points<=85){
                        progress_width = "width:44%";
                    } else if (points>=86 && points<=90){
                        progress_width = "width:48%";
                    }
                    points_nxt = points_requied_l3+"";
                } else  if (points<=level_3){
                    border_radius_l3 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:1";
                    opacityl3 = "opacity:1";
                    opacityl4 = "opacity:0.1";
                    opacityl5 = "opacity:0.1";
                    if(points<=110) {
                        progress_width = "width:50%";
                    }else if (points>=111 && points<=120){
                        progress_width = "width:57%";
                    }else if (points>=121 && points<=130){
                        progress_width = "width:62%";
                    }else if (points>=131 && points<=140){
                        progress_width = "width:68%";
                    } else if (points>=141 && points<=145){
                        progress_width = "width:72%";
                    }
                    points_nxt = points_requied_l4+"";
                } else if (points<=level_4){
                    border_radius_l4 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:1";
                    opacityl3 = "opacity:1";
                    opacityl4 = "opacity:1";
                    opacityl5 = "opacity:0.1";
                    if(points<=220) {
                        progress_width = "width:75%";
                    }else if (points>=230 && points<=245){
                        progress_width = "width:80%";
                    }else if (points>=246 && points<=255){
                        progress_width = "width:85%";
                    }else if (points>=256 && points<=270){
                        progress_width = "width:90%";
                    } else if (points>=271 && points<=280){
                        progress_width = "width:95%";
                    } else if (points>=281 && points<=295){
                        progress_width = "width:97%";
                    }
                    points_nxt = points_requied_l5+"";
                } else if (points<=level_5){
                    border_radius_l5 = "border-radius:35%;border:#ff6666 solid;";
                    opacityl1 = "opacity:1";
                    opacityl2 = "opacity:1";
                    opacityl3 = "opacity:1";
                    opacityl4 = "opacity:1";
                    opacityl5 = "opacity:1";
                    progress_width = "width:100%";

                }
                topreferal_level1 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#d9edf7;border-color: #d9edf7;color: #000000;"+opacityl1+"'>" +
                        "    <img   src='images/111.jpg' style='width: 40px;height: 40px;"+border_radius_l1+"'>" +
                        "  </button>";
                topreferal_level2 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#d9edf7;border-color: #d9edf7;color: #000000;"+opacityl2+"'>" +
                        "    <img   src='images/222.png' style='width: 40px;height: 40px;"+border_radius_l2+"'>" +
                        "  </button>";
                topreferal_level3 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#d9edf7;border-color: #d9edf7;color: #000000;"+opacityl3+"'>" +
                        "    <img   src='images/333.jpg' style='width: 40px;height: 40px;"+border_radius_l3+"'>" +
                        "  </button>";
                topreferal_level4 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#d9edf7;border-color: #d9edf7;color: #000000;"+opacityl4+"'>" +
                        "    <img   src='images/444.jpg' style='width: 40px;height: 40px;"+border_radius_l4+"'>" +
                        "  </button>";
                topreferal_level5 = " <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='background-color:#d9edf7;border-color: #d9edf7;color: #000000;"+opacityl5+"'>" +
                        "    <img   src='images/555.png' style='width: 40px;height: 40px;"+border_radius_l5+"'>" +
                        "  </button>";
                topreferal_progress = "<div class='progress' style='height: 7px;color: #000000;margin-top: 2px;margin-bottom: 0px' >" +
                        "     <div data-percentage='0%' style='"+progress_width+";background-color: #00B8D4;' class='progress-bar progress-bar-success' role='progressbar' aria-valuemin='0' aria-valuemax='100' ></div>" +
                        "  </div>"+
                        "<p class='text-center' style='color: #000000;margin-top: 3px;margin-bottom: 3px;font-size: 12px'><b>"+points_nxt+"</b>  more points required for next level</p>";

                hm = new HashMap();
                hm.put("referals", referals);
                hm.put("name", name);
                hm.put("user_id", user_id);
                hm.put("points", points);
                hm.put("topreferal_level1", topreferal_level1);
                hm.put("topreferal_level2", topreferal_level2);
                hm.put("topreferal_level3", topreferal_level3);
                hm.put("topreferal_level4", topreferal_level4);
                hm.put("topreferal_level5", topreferal_level5);
                hm.put("topreferal_progress", topreferal_progress);
                hm.put("lin_profile_picture_url", lin_profile_picture_url);

                rainmaker_list_json.add(hm);
            }
            return rainmaker_list_json;
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
    public String sendHTMLEMail(String email, String subject, String text) {
        String mail_host = "webmail.register.com";
        String mail_from = "help@devsquare.com";
         //      String fromEmail_Password = "#";
        String fromEmail_Password = "LAt123#$y74987";
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
            msg.setRecipients(javax.mail.Message.RecipientType.TO, address);
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

    public String getReferAFriendForm() {
        String res = "<div class='line'><h2 class='text-center' style='color: #ffffff;'>Refer a friend</h2></div>  " +
                    "   <div class='col-md-12 col-xs-12 login_control'>  " +
                     "       <div class='control'>  " +
		                        "           <div class='row'> " +
		                        "               <div class='col-md-4 col-xs-4 login_control '>   " +
		                        "                   <div class='label pull-right'>Linkedin</div>  " +
		                        "               </div>  " +
		                        "               <div class='col-md-6 col-xs-6 login_control'>  " +
		                        "                   <input id='raf_linkedin' type='text' class='form-control' value=''/> " +
		                        "               </div>   " +
		                        "               <div class='col-md-1 col-xs-1 login_control'>  " +
		                        "                   <a button class='btn btn-info btn-circle' onclick=\"window.open('https://www.linkedin.com', '_blank')\" style='margin-top:1px' type='button'>  " +
		                        "                       <i class='fa fa-linkedin '></i>  " +
		                        "                   </a>  " +
		                        "               </div>   " +
		                        "           </div>    " +
                    "       </div>        " +
                    "       <div class='control'>   " +
                    "           <div class='row'>   " +
                    "               <div class='col-md-4 col-xs-4 login_control'>   " +
                    "                   <div class='label pull-right'>Name</div>  " +
                    "               </div>  " +
                    "               <div class='col-md-6 col-xs-6 login_control'>   " +
                    "                   <input id='raf_name' type='text' class='form-control' value=''/>  " +
                    "               </div>  " +
                    "           </div>" +
                    "       </div>" +
                    "       <div class='control'>   " +
                    "           <div class='row'>   " +
                    "               <div class='col-md-4 col-xs-4 login_control'>   " +
                    "                   <div class='label pull-right'>Email</div>  " +
                    "               </div>  " +
                    "               <div class='col-md-6 col-xs-6 login_control'>   " +
                    "                   <input id='raf_email' type='text' class='form-control' value=''/>  " +
                    "               </div>  " +
                    "           </div>" +
                    "       </div>" +
                   
                    "       <div class='control'>  " +
                    "           <div class='row'> " +
                    "               <div class='col-md-4 col-xs-4 login_control '>   " +
                    "                   <div class='label pull-right'>Profile</div>  " +
                    "               </div>  " +
                    "               <div class='col-md-6 col-xs-6 login_control'>  " +
                    "                   <input id='raf_profile' type='text' class='form-control' value='' placeholder='Upload profile document' readonly onclick='uploadProfileSimulate();'/> " +
                    "               </div>   " +
                    "               <div class='col-md-1 col-xs-1 login_control'>  " +
                    "                   <a class='btn btn-info btn-circle' style='margin-top:1px' type='button' onclick='uploadProfileSimulate();'>  " +
                    "                       <i class='fa fa fa-file-text-o'>" +
                    "                       </i>  " +
                    "                   </a>  " +
                    "                   <input id='uploadProfileSelector' enctype='multipart/form-data' type='file' style='position:absolute; width:200px;height:30px; opacity:0;' onChange='uploadProfile()'/>" +
                    "               </div>" +
                    "           </div> " +
                    "       </div> " +
                    "       <div class='control'>   " +
                    "           <div class='row'>   " +
                    "               <div class='col-md-4 col-xs-4 login_control'>   " +
                    "                   <div class='label pull-right'>Skills</div>  " +
                    "               </div>  " +
                    "               <div class='col-md-6 col-xs-6 login_control'>   " +
                    "                   <input id='raf_skills' type='text' class='form-control' value=''/>  " +
                    "               </div>  " +
                    "           </div>" +
                    "       </div><br>   " +
                    "       <div class='row'>" +
                    "           <div id='raf_status_success' align='center' style='display: none;'></div>" +
                    "           <div id='raf_status_failed' align='center' style='display: none;'></div>" +
                    "       </div>"+
                    "       <div align='center'>   " +
                    "           <button id='contactprofile_save' type='submit' data-toggle='button' class='btn btn-orange' style='color: #ffffff;' onclick='referAFriend();'>Refer</button>   " +
                    "           <button data-dismiss='modal' class='btn btn-orange' style='color: #ffffff;'>Close</button> " +
                    "       </div>  " +
                    "   </div>  " +
                    "</div>";
        return res;
    }

    public int insertFriendIfNotExists(String raf_name, String raf_email, String raf_linkedin, String raf_skills, String profile_doc, String profile_doc_uploaded_time) {
        ResultSet rs = null;
        Connection conn = null;
        PreparedStatement ps = null;
        PreparedStatement ps_checkEmail = null;
        ResultSet rsEmail = null;
        int userId = -1;

        try {
            conn = getConnection();
            String sql_checkEmail = "select * from users where email = ?";
            ps_checkEmail = conn.prepareStatement(sql_checkEmail);
            ps_checkEmail.setString(1, raf_email);
            rsEmail = ps_checkEmail.executeQuery();

            if (rsEmail.next()) {               //User already exists, get the userId
                userId = rsEmail.getInt(1);
            } else {                            //User doesn't exist, insert and get the userId
                String insertQuery = "insert into users(email, name, profile_doc, profile_doc_uploaded_time) values (?, ?, ?, ?)";

                ps = conn.prepareStatement(insertQuery,Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, raf_email);
                ps.setString(2, raf_name);
                ps.setString(3, profile_doc);
                ps.setString(4, profile_doc_uploaded_time);

                int id = ps.executeUpdate();
                if(id == 1) {
                    rs = ps.getGeneratedKeys();
                    if(rs.next())
                        userId = rs.getInt(1);
                }
            }
        } catch (Throwable t) {
            t.printStackTrace();
        } finally {
            try {
                if (ps != null) ps.close();
                if (rs != null) rs.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            if(conn != null)
                closeConnection( conn);
        }
        return userId;
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
    String get_suggested_keywords = "select expertise from employee_details";
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
%>

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
<%@ include file="dec_enc.jsp"%>

<%!
    public String reminderInvited_user() {
        String invite_id = "";
        String from_user_id = "";
        String from_name = "";
        String to_name = "";
        String msg = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;
//       String sql_loadReminders_Admin = "select ui.* from user_invitations ui, users u where ui.to_userid = u.user_id and u.registered = 0 and ui.invitation_status = 1";
        String sql_loadReminders_Admin = "select ui.* from user_invitations ui, users u where ui.to_userid = u.user_id and ui.invitation_status = 1  and connection='appInvite'";
        try {
            con = getConnection();
            ps = getPs(con, sql_loadReminders_Admin);
            rs = ps.executeQuery();
            while (rs.next()) {
                invite_id = rs.getString("inv_id");
                from_user_id = rs.getString("from_userid");
                byte[] from_name_enc = rs.getBytes("from_name");
                byte[] to_name_enc = rs.getBytes("to_name");
                String to_userid = rs.getString("to_userid");

                int no_of_relationship = getrelationship(con, to_userid);
                boolean status = getRegistrationStatus(con, to_userid);

                String connection = rs.getString("connection");
                String invitation_sent_time = rs.getString("invitation_sent_time");
                try {
                    byte[] from_name_ba = processDecrypt(from_name_enc);
                    from_name = new String(from_name_ba);
                } catch (Exception e) {
                    System.out.println(new Date() + "\t " + e.getMessage());
                    e.printStackTrace();
                }
                try {
                    byte[] to_name_ba = processDecrypt(to_name_enc);
                    to_name = new String(to_name_ba);
                } catch (Exception e) {
                    System.out.println(new Date() + "\t " + e.getMessage());
                    e.printStackTrace();
                }
                if (from_name != null && from_name.trim().length() > 0) {
                    msg += loadRemindInvited_userString_Admin(invite_id, from_user_id, from_name, to_userid, to_name, invitation_sent_time, connection, no_of_relationship, status);
                }
            }
            return msg;
        } catch (Exception se) {
            System.err.print(new Date() + "\t " + se.getMessage());
            return msg;
        } finally {
            if (con != null) {
                closeConnection(con);
            }
        }
    }

    /*---------------------------------------*/
    public String inviteNotRegistered_Admin() {
        String invite_id = "";
        String from_user_id = "";
        String from_name = "";
        String to_name = "";
        String msg = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;
        //get the records for whom invitations are already sent but not registered yet
        String sql_loadReminders_Admin = "select ui.* from user_invitations ui, users u where u.mobile = ui.to_mobile and  u.registered = 0 and ui.invitation_status = 1 and connection='appInvite'";
        try {
            con = getConnection();
            ps = getPs(con, sql_loadReminders_Admin);
            rs = ps.executeQuery();
            while(rs.next()) {
                invite_id = rs.getString("inv_id");
                from_user_id = rs.getString("from_userid");
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
                    msg += loadRemindersString_AdminInvNReg(invite_id, from_user_id, from_name, to_userid, to_name, invitation_sent_time, connection);
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

    /*-------------------------------------Registered------------------------*/
    public String loadInvitedRegistered_Admin() {
        String invite_id = "";
        String from_user_id = "";
        String from_name = "";
        String to_name = "";
        String msg = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;
        //get the records for whom invitations are already sent but not registered yet
        String sql_loadReminders_Admin = "select ui.* from user_invitations ui, users u where u.mobile = ui.to_mobile and  u.registered = 1 and ui.invitation_status = 1 and connection='appInvite'";
        try {
            con = getConnection();
            ps = getPs(con, sql_loadReminders_Admin);
            rs = ps.executeQuery();
            while(rs.next()) {
                invite_id = rs.getString("inv_id");
                from_user_id = rs.getString("from_userid");
                byte[] from_name_enc = rs.getBytes("from_name");
                byte[] to_name_enc = rs.getBytes("to_name");
                String to_userid = rs.getString("to_userid");

                int no_of_relationship = getrelationship(con, to_userid);

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
                    msg += loadInvitedRegisteredRemindersString(invite_id, from_user_id, from_name, to_userid, to_name, invitation_sent_time, connection, no_of_relationship);
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

    /*-------------------Not active--------------------*/
    public String loadInActive_Admin() {
        String invite_id = "";
        String from_user_id = "";
        String from_name = "";
        String to_name = "";
        String msg = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection con = null;
        //get the records for whom invitations are already sent but not registered yet
        String sql_loadReminders_Admin = "select ui.* from user_invitations ui, users u where  ui.to_userid NOT IN (select distinct(from_user_id) from relationship )  and u.mobile = ui.to_mobile and  u.registered = 1 and  ui.invitation_status = 1 and connection='appInvite'";
        try {
            con = getConnection();
            ps = getPs(con, sql_loadReminders_Admin);
            rs = ps.executeQuery();
            while(rs.next()) {
                invite_id = rs.getString("inv_id");
                from_user_id = rs.getString("from_userid");
                byte[] from_name_enc = rs.getBytes("from_name");
                byte[] to_name_enc = rs.getBytes("to_name");
                String to_userid = rs.getString("to_userid");

                boolean status = getRegistrationStatus(con, to_userid);

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
                    msg += loadInactiveRemindersString_Admin(invite_id, from_user_id, from_name, to_userid, to_name, invitation_sent_time, connection, status);
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





    public static String get_count_relationship = "Select count(*) from relationship r where from_user_id = ? ";
    public int getrelationship(Connection con, String to_userid){

        PreparedStatement ps = null;
        ResultSet rs = null;
        int count = 0;
        try{
            ps = getPs(con, get_count_relationship);
            ps.setString(1, to_userid);
            rs = ps.executeQuery();
            while(rs.next()) {
                count = rs.getInt(1);
            }
        } catch(Exception se) {
            System.err.println(new Date() + "\t " + se.getMessage());
        }
        return count;
    }


    public static String get_RegistrationStatus = "Select count(*) from users where user_id = ? and registered = 1";
    public boolean getRegistrationStatus(Connection con, String to_userid){

        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean status = false;
        try{
            ps = getPs(con, get_RegistrationStatus);
            ps.setString(1, to_userid);
            rs = ps.executeQuery();

            while(rs.next()) {
                int val = rs.getInt(1);
                if (val == 0){
                    status = false;
                }else {
                    status = true;
                }
            }
        } catch(Exception se) {
            System.err.println(new Date() + "\t " + se.getMessage());
        }
        return status;
    }


    public String loadRemindInvited_userString_Admin(String invite_id, String from_userid, String from_name, String to_userid, String to_name, String invitation_sent_time, String connection, int no_of_relationship, boolean status) {
        boolean display_flag = false;
        if (connection.equalsIgnoreCase("appinvite")) {
            connection = "App invitation";
            display_flag = true;
        }
        if(display_flag) {
            String ret = "  <tr>" +
                    "                            <td width='15%'><h5 style='margin-top:0px;margin-bottom:3px;font-size:15px;color:;margin-left:8px'>"+(to_name != null && to_name.trim().length() > 0 ? to_name +" invited by "  : "")+"<b>"+(from_name != null && from_name.trim().length() > 0 ? from_name  : "N/A")+" &nbsp;</b></h5></td>" +
                    "                            <td width='19%'><h4 class='text-muted' style='margin-bottom:2px;font-family:monospace;overflow:auto; font-size-adjust: 0.58;line-height:1.1;font-size:12px;margin-left:8px'>"+connection+" sent on: " +invitation_sent_time+"</h4></td>" +
                    "                            <td width='14%' class='text-center'>"+(status == false ? "<font color='red'>N ": "<font color='Black'>Y")+"</td>" +
                    "                            <td width='14%' class='text-center' >"+(no_of_relationship == 0 ? " <font color='red'>N "  : "<font color='Black'>Y")+"</font></td>" +
                    "                            <td width='14%' class='text-center'>" +
                    "                                <div class='pull-center'  style='width:50%;'>" +
                    "                                    <button id='remind_btn_"+invite_id+"'  type='button' class='btn btn-info btn-sm pull-right' style='display:inline;border-radius:15px'>" +
                    "                                        Remind </button>" +
                    "                                    <button id='remindsuccess_btn_"+invite_id+"' type='button' class='btn btn-success btn-sm pull-right' style='display:inline;border-radius:15px;display:none'>" +
                    "                                        Success</button>" +
                    "                                </div>" +
                    "                            </td>" +
                    "                        </tr>";
            return ret;
        }
        return "";
    }


    public String loadInvitedRegisteredRemindersString(String invite_id, String from_userid, String from_name, String to_userid, String to_name, String invitation_sent_time, String connection, int no_of_relationship) {
        boolean display_flag = false;
        if (connection.equalsIgnoreCase("appinvite")) {
            connection = "App invitation";
            display_flag = true;
        }
        if(display_flag) {
            String ret = "  <tr>" +
                    "                            <td width='15%'><h5 style='margin-top:0px;margin-bottom:3px;font-size:15px;color:;margin-left:8px'>"+(to_name != null && to_name.trim().length() > 0 ? to_name +" invited by "  : "")+"<b>"+(from_name != null && from_name.trim().length() > 0 ? from_name  : "N/A")+" &nbsp;</b></h5></td>" +
                    "                            <td width='19%'><h4 class='text-muted' style='margin-bottom:2px;font-family:monospace;overflow:auto; font-size-adjust: 0.58;line-height:1.1;font-size:12px;margin-left:8px'>"+connection+" sent on: " +invitation_sent_time+"</h4></td>" +
                    "                            <td width='14%' class='text-center'>Y</td>" +
                    "                            <td width='14%' class='text-center' >"+(no_of_relationship == 0 ? " <font color='red'>N "  : "<font color='Black'>Y")+"</font></td>" +
                    "                            <td width='14%' class='text-center'>" +
                    "                                <div class='pull-center'  style='width:50%;'>" +
                    "                                    <button id='remind_btn_"+invite_id+"'  type='button' class='btn btn-info btn-sm pull-right' style='display:inline;border-radius:15px'>" +
                    "                                        Remind </button>" +
                    "                                    <button id='remindsuccess_btn_"+invite_id+"' type='button' class='btn btn-success btn-sm pull-right' style='display:inline;border-radius:15px;display:none'>" +
                    "                                        Success</button>" +
                    "                                </div>" +
                    "                            </td>" +
                    "                        </tr>";
            return ret;
        }
        return "";
    }

    public String loadRemindersString_AdminInvNReg(String invite_id, String from_userid, String from_name, String to_userid, String to_name, String invitation_sent_time, String connection) {
        boolean display_flag = false;
        if (connection.equalsIgnoreCase("appinvite")) {
            connection = "App invitation";
            display_flag = true;
        }
        if(display_flag) {
            String ret = "  <tr>" +
                    "                            <td width='15%'><h5 style='margin-top:0px;margin-bottom:3px;font-size:15px;color:;margin-left:8px'>"+(to_name != null && to_name.trim().length() > 0 ? to_name +" invited by "  : "")+"<b>"+(from_name != null && from_name.trim().length() > 0 ? from_name  : "N/A")+" &nbsp;</b></h5></td>" +
                    "                            <td width='19%'><h4 class='text-muted' style='margin-bottom:2px;font-family:monospace;overflow:auto; font-size-adjust: 0.58;line-height:1.1;font-size:12px;margin-left:8px'>"+connection+" sent on: " +invitation_sent_time+"</h4></td>" +
                    "                            <td width='14%' class='text-center'>N</td>" +
                    "                            <td width='14%' class='text-center' ><font color='red'>N</font></td>" +
                    "                            <td width='14%' class='text-center'>" +
                    "                                <div class='pull-center'  style='width:50%;'>" +
                    "                                    <button id='remind_btn_"+invite_id+"'  type='button' class='btn btn-info btn-sm pull-right' style='display:inline;border-radius:15px'>" +
                    "                                        Remind </button>" +
                    "                                    <button id='remindsuccess_btn_"+invite_id+"' type='button' class='btn btn-success btn-sm pull-right' style='display:inline;border-radius:15px;display:none'>" +
                    "                                        Success</button>" +
                    "                                </div>" +
                    "                            </td>" +
                    "                        </tr>";
            return ret;
        }
        return "";
    }

    public String loadInactiveRemindersString_Admin(String invite_id, String from_userid, String from_name, String to_userid, String to_name, String invitation_sent_time, String connection, boolean status) {
        boolean display_flag = false;
        if (connection.equalsIgnoreCase("appinvite")) {
            connection = "App invitation";
            display_flag = true;
        }
        if(display_flag) {
            String ret = "  <tr>" +
                    "                            <td width='15%'><h5 style='margin-top:0px;margin-bottom:3px;font-size:15px;color:;margin-left:8px'>"+(to_name != null && to_name.trim().length() > 0 ? to_name +" invited by "  : "")+"<b>"+(from_name != null && from_name.trim().length() > 0 ? from_name  : "N/A")+" &nbsp;</b></h5></td>" +
                    "                            <td width='19%'><h4 class='text-muted' style='margin-bottom:2px;font-family:monospace;overflow:auto; font-size-adjust: 0.58;line-height:1.1;font-size:12px;margin-left:8px'>"+connection+" sent on: " +invitation_sent_time+"</h4></td>" +
                    "                            <td width='14%' class='text-center'>"+(status == false ? "<font color='red'>N ": "<font color='Black'>Y")+"</td>" +
                    "                            <td width='14%' class='text-center' ><font color='red'>N</font></td>" +
                    "                            <td width='14%' class='text-center'>" +
                    "                                <div class='pull-center'  style='width:50%;'>" +
                    "                                    <button id='remind_btn_"+invite_id+"'  type='button' class='btn btn-info btn-sm pull-right' style='display:inline;border-radius:15px'>" +
                    "                                        Remind </button>" +
                    "                                    <button id='remindsuccess_btn_"+invite_id+"' type='button' class='btn btn-success btn-sm pull-right' style='display:inline;border-radius:15px;display:none'>" +
                    "                                        Success</button>" +
                    "                                </div>" +
                    "                            </td>" +
                    "                        </tr>";
            return ret;
        }
        return "";
    }


%>

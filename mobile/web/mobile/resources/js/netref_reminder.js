
$(document).ready(function() {
    /*------------------Invited---------------------*/
    window.showReminders_Admin = function () {

        $('#invited_list').attr("class", "option active");
        $('#invitedand_notreg').attr("class", "option");
        $('#invitedand_reg').attr("class", "option");
        $('#notactive').attr("class", "option");

        $('#reminders_ref').html();
        $("#reminders_loading").show();

        loadReminders_Admin();

        $("#reminders_loading").hide();                         //hiding contacts loading symbol
        $("#reminders_page").show();                               //showing reminders tab
    };

    window.loadReminders_Admin = function() {
        $.ajax({
            type:         "post",
            url:         "action/load_reminders_admin.jsp",
            data:       "rem_type=invited",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);
                if(msg == null || msg == ""){
                    $("#reminders_ref").html("<div class='events-body'><div style='margin-top: 10px; margin-bottom: 10px;'><center>Not found</center></div></div>");
                } else if(msg != null) {
                    $("#reminders_ref").html(msg.trim());
                }
            }
        });
    };


    /*-----------------------------Not Registered (Invited and Not Registered)-----------------------------------*/

    window.showInvitedandNotRegistered = function () {
        $('#invited_list').attr("class", "option ");
        $('#invitedand_notreg').attr("class", "option active");
        $('#invitedand_reg').attr("class", "option");
        $('#notactive').attr("class", "option");

        $('#reminders_ref').html('');
        $("#reminders_loading").show();

        load_Invited_Not_Reg_Admin();

        $("#reminders_loading").hide();                         //hiding contacts loading symbol
        $("#reminders_page").show();
    };

    window.load_Invited_Not_Reg_Admin = function () {
        $.ajax({
            type: "post",
            url: "action/load_reminders_admin.jsp",
            data: "rem_type=notregistered",
            success: function (msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);
                //alert("msg2 : "+msg);
                if (msg == null || msg == "") {
                    $("#reminders_ref").html("<div class='events-body'><div style='margin-top: 10px; margin-bottom: 10px;'><center>Not found</center></div></div>");
                } else if (msg != null) {
                    $("#reminders_ref").html(msg);
                }
            }
        });
    };

    /*-----------------------------Registered (Invited and Registered)-----------------------------------------------*/
    window.showInvitedandRegistered = function () {

        $('#invited_list').attr("class", "option ");
        $('#invitedand_notreg').attr("class", "option ");
        $('#invitedand_reg').attr("class", "option active");
        $('#notactive').attr("class", "option");

        $('#reminders_ref').html('');
        $("#reminders_loading").show();
        load_Invited_and_Reg_Admin();
        $("#reminders_loading").hide();                         //hiding contacts loading symbol
        $("#reminders_page").show();
    };

    window.load_Invited_and_Reg_Admin = function () {
        $.ajax({
            type: "post",
            url: "action/load_reminders_admin.jsp",
            data: "rem_type=registered",
            success: function (msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);
                //alert("msg3 : "+msg);
                if (msg == null || msg == "") {
                    $("#reminders_ref").html("<div class='events-body'><div style='margin-top: 10px; margin-bottom: 10px;'><center>Not found</center></div></div>");
                } else if (msg != null) {
                    $("#reminders_ref").html(msg);
                }
            }
        });
    };

    /*-----------------------NotActive (Invited and Registered But not selected professional)-----------------------*/

    window.showInactive = function () {

        $('#invited_list').attr("class", "option ");
        $('#invitedand_notreg').attr("class", "option ");
        $('#invitedand_reg').attr("class", "option ");
        $('#notactive').attr("class", "option active");

        $('#reminders_ref').html('');
        $("#reminders_loading").show();
        load_Inactive_Admin();

        $("#reminders_loading").hide();                         //hiding contacts loading symbol
        $("#reminders_page").show();
    };

    window.load_Inactive_Admin = function () {
        $.ajax({
            type: "post",
            url: "action/load_reminders_admin.jsp",
            data: "rem_type=notactive",
            success: function (msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);
                //alert("msg4 : "+msg);
                if (msg == null || msg == "") {
                    $("#reminders_ref").html("<div class='events-body'><div style='margin-top: 10px; margin-bottom: 10px;'><center>Not found</center></div></div>");
                } else if (msg != null) {
                    $("#reminders_ref").html(msg);
                }
            }
        });
    };
});


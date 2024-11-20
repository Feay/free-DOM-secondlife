/*  API
BUTTON_NAME,ACTION_TYPE,PAYLOAD,,,,,,
    payload can be anything, we process the data differently based on the type given
USER_ID,MENU_NAME,PAGE_NUMBER
    menu name is same as note card name
listen_channel
    negative integer from llhash of "owner key + object key"
*/
//..  GLOBAL CONSTANTS
string globaltoken="┐"; // for convenavce only should be hard coded
integer page_name_lenght=5; // page name lenght, leading space is ignored with ints so can be 4
string page_name="PAGE "; // ease of translation
string main_name="MAINMENU"; // ease of translation
//.. GLOBAL VARS THAT NEED TO BE PREINITALIZED WITH A CONSTANT
integer listen_channel; // (integer)("0xF" + llGetSubString(llGetOwner(),0,6));
string name="main"; // internal name of primdrive data main menu file
integer cur_page=1; // remeber current page
//..  GLOBAL VARS
list cur_list; // resued
//list cur_desc; // mostly empty
list payload; // list gotten from current button press
integer len=0; // lenght resued
integer seek; // seek pointer of payload
string desc; // description of menu
integer mode=0;



showMenu(key userTouched, string menu, integer page ) {
     // only update what menu we are on if we needed too
    if(menu!=""){
        llOwnerSay("Loading menu: "+ menu);
        llOwnerSay("Loading: "+ menu);
        if(mode==2){mode=0;}
        if(mode){mode=2;}
        cur_list=[];
        name=menu;
        desc=llLinksetDataRead(menu+globaltoken+"0");
        string tobeloaded="tits";
        len=1; // everymenu must have atlest ONE BUTTON
            @loopL; // issue is while won't stop soon so it always adds a blank element
            tobeloaded=llLinksetDataRead(menu+globaltoken+(string)len);
            if(tobeloaded==""){jump stopL;}
            cur_list=cur_list+llList2String(llCSV2List(tobeloaded),0); // its possible some jerk has an aniamtion with a comma???
            len=len+1;
            jump loopL;
            @stopL;
            len=len-1; // deincrament by one
        }

integer line; // sticky so we walk list from where we left off
    if(page > 1) {
        line = (page*9)-9;
    } else {
        line = 0;
    }
string exclude_first_page = "";
string exclude_last_page = "";
integer page_bucket = 0;
list menu_buttons = [];
   // dances_text_list = "";

    while(page_bucket < 9) {
        if(llList2String(cur_list, line) != "") {
            menu_buttons = (menu_buttons = []) + menu_buttons + llList2String(cur_list, line);
        }
        ++page_bucket;
        ++line; // note line is a mutpiple of current page
    }
    cur_page=page; // page is a local var, argument of this function, save it to a global
    if(page == 1) {
        exclude_first_page = "---";
    } else {
        exclude_first_page = page_name + (string)(page-1);
    }

    if(llGetListLength(menu_buttons) < 9 || (page*9) >= len) {
        exclude_last_page = "---";
    } else {
        exclude_last_page = page_name + (string)(page+1);
    }

    menu_buttons = (menu_buttons = []) + main_name + exclude_first_page + exclude_last_page + menu_buttons;
    // this mode thing is for dynamic menus set via script using the
    // description as info and buttons as numbers
    if(mode){desc=llDumpList2String(llList2List(llCSV2List(llLinksetDataRead(name+globaltoken+"0")),(page*9)-8,(page*9)),"\n");}
// mode makes menu buttons based on alist that is the description
// since these are not supposed to have buttons loaded in prim memory they should use the blank type and emmit their names as the payload, such as 1 2 3...my issue is math to get the modulo
//.. pop menu
    llDialog(userTouched,desc , menu_buttons, listen_channel);
}

//...
default
{
state_entry()
    {
    listen_channel=(-1)*llHash((string)llGetOwner() + (string)llGetKey());
// llOwnerSay((string)llGetUsedMemory()); // 64K possible with mono
//  current 10246
    // predicable but random channel
        page_name_lenght=(llStringLength(page_name)); // make page name agnostic to it's len incase we are making a translated menu
        llListen(listen_channel, "", NULL_KEY, "");
        llListen(0, "", llGetOwner(), ""); // only listen to owner on channel 0
    }

touch_start(integer i)
    {
        if(mode){name="main";cur_page=1;}
        showMenu(llDetectedKey(0), name, cur_page);
        // to always open on last menu and page for ease of life trust the user, unless dynamic mode was set
    }

listen(integer channel, string person, key id, string message) {
    seek=llListFindList(cur_list,[message]);
    string temp=(string)llList2String(cur_list, seek);
        if( temp==message){
        seek=seek+1; // remember desc consumes 0 entry, and thus curlist does not contain it
        payload=llCSV2List(llLinksetDataRead(name+globaltoken+(string)seek));
        temp=llList2String(payload,1);
        //llOwnerSay("button recived: "+temp);
        //llOwnerSay(llLinksetDataRead(name+globaltoken+(string)seek));
        // common name,action-type,payload,,,,,
        if(temp=="t"){ // t means to-menu, example GOTOFARTS,t,submenu1,2
        showMenu(id, llList2String(payload,2), (integer)llList2String(payload,3) );
            }
        else if(temp=="a"){
        } //animator
        else if(temp=="c"){} //couple animator
        else if(temp=="r"){} //rlv menus that need to be dynamic
        else if(temp=="g"){ llMessageLinked(LINK_THIS,867530900,llList2String(payload,2),id); } // menu giver sensor thingy
        else if(temp=="h"){ llMessageLinked(LINK_THIS,867530901,llList2String(payload,2),id); } // menu giver sensor thingy
        else if(temp=="b"){} // textbox for input
        else if(temp=="o"){} // okay single button
        else if(temp=="y"){} // y/n chooser
        else if(temp=="z"){mode=0; showMenu(id, "main", 1);} // error and pop menu
        else if(temp==""||temp=="e"){ // e is for emmitter, just emit
        // common-name,e,string,number
            if(temp!=""){message=llList2String(payload,2);}
            llMessageLinked(LINK_THIS,(integer)llList2String(payload,3),message,id);
            } // blank action type, default to emetter

        }
// if temp==message was true above
        else if(message == main_name) {showMenu(id, "main", 1 );}
        else if(0==(llSubStringIndex( message, page_name ))) {
            showMenu(id,"",(integer)llGetSubString(message,page_name_lenght,-1)); // gets ending of page for page num
        } else if(message == "---") {
            // Do nothing here
        }
    } // end of listen
link_message(integer sender_num, integer num, string str, key id)
    { if(num==666699991){ mode=0; // redunatacy
        showMenu(id,str,1); // assume page 1, less complicated
        }
    if(num==666699992){ // dynamic mode, use desc for info buttons as numbers
        mode=1;
        showMenu(id,str,1); // assume page 1, less complicated
    }
    if(num==987654321){ llResetScript();}

        }
}
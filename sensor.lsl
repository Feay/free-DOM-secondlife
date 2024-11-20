// load buttons as numbers
// ad a mode switch to menu where it forces a desc update for each modulo of page...something like
// and desc is mearly it's own list
// Only 32 objects will be scanned each time. (Increased from 16 with Release 2024-03-18.8333615376 on Tuesday, March 19, 2024)
string SCAN;
//list _objectKeys;
list _menuItems;
string globaltoken="┐"; // and tmp list
string tempmenu="tmp";
key keyid;
default
{
    state_entry()
    {  keyid=llGetOwner();

        SCAN = "sit";
        llSensor("", "", (PASSIVE | ACTIVE), 9, PI);
        return;
    }
     no_sensor()
     {
        llLinksetDataWrite("err"+globaltoken+"0","No objects or Person in range");
        llMessageLinked(LINK_THIS,666699991,"err",keyid);
     }
        sensor(integer num) {
           // llSetTimerEvent(60);
            _menuItems = [];
           // _objectKeys = [];
            llOwnerSay(llDetectedName(0));
            // num starts at highest number found, 0 indexed, -1 is nothing
            llLinksetDataDelete(tempmenu+globaltoken+(string)(num+1));
           //llLinksetDataWrite(tempmenu+globaltoken+(string)(num),"");
            // insert blank entry at last item to stop overrun!!
            --num;
            llOwnerSay((string)num);
            do
            {
              _menuItems = [(string)(num+1)+":"+llDetectedName(num)]+ _menuItems;
            /// myList = [new_item] + myList;
            llLinksetDataWrite(tempmenu+globaltoken+(string)(num+1),(string)(num+1)+",h,"+(string)llDetectedKey(num));
               // _objectKeys += llDetectedKey(num);
               llOwnerSay((string)num);
            }
            while(--num>-1);
            _menuItems = ["0 blank"]+ _menuItems;
            //llOwnerSay(llList2CSV(_menuItems));
            //llOwnerSay((string)llGetListLength(_menuItems));
            // write description to name 0, this is rewriting 0 :(
            llLinksetDataWrite(tempmenu+globaltoken+"0",llList2CSV(_menuItems));
//llOwnerSay(llLinksetDataRead(tempmenu+globaltoken+"0"));
            llMessageLinked(LINK_THIS,666699992,tempmenu,keyid);
                return;

        }
timer(){}
link_message(integer sender_num, integer num, string str, key id)
{
    if(867530900==num){
        keyid=id;
    if(str == "gosit") { // add num of some sort later
        SCAN = "sit";
        llInstantMessage(id, "[QuickCollar?]: Scanning for nearby objects, please wait...");
        llSensor("", "", (PASSIVE | ACTIVE), 10, PI);
        return;
    }
    if(str == "goto") {
        SCAN = "go";
        llInstantMessage(id, "[QuickCollar?]: Scanning for nearby targets, please wait...");
        llSensor("", "", (AGENT | PASSIVE | ACTIVE), 10, PI);
        return;
    }
    if(str == "lesto" ) {
        SCAN = "leash";
       llInstantMessage(id, "[QuickCollar?]: Scanning for nearby objects & targets, please wait...");
       llSensor("", "", (AGENT | PASSIVE | ACTIVE), 10, PI);
       return;
    }
}
else if(867530901==num){
llOwnerSay(llKey2Name(str));

    }
}
}

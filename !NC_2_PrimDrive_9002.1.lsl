// uses jump labels, must be compiled with mono
string NC_current="!NC_2_primdrive";
// if edited be sure to edit lines if(NC_current=="!NC_2_primdrive")
key callback;
list cur_list;
integer line=0;
integer line2=0;
integer count;
integer len;
string globaltoken="┐"; // for convenavce only should be hard coded +
// pd« is the prim drive name of loade NCs saved to prim drive "┐"

default
{
    state_entry(){ llLinksetDataReset( ); callback=llGetNotecardLine(NC_current,0);}

    dataserver(key id, string data)
    {
    if (id == callback)
        {
        if (data != EOF)
            {
            if((llSubStringIndex(data, "#") == 0)||(llSubStringIndex(data, "//") == 0) ||(data==""))
                {
                //llOwnerSay(NC_current+" comment or blank line:" + (string)line);
                --line2; // skip line
                jump retry;
                }
                if(NC_current=="!NC_2_primdrive")
                    {cur_list += data; jump retry;
                    }
                //llOwnerSay("get here only if other notecards need reading: "+NC_current);
                    string name = NC_current+globaltoken+(string)line2;
                   // llOwnerSay(NC_current+" name: "+name+" value: "+data);
                    llLinksetDataWrite(name,data);
                    jump retry;


              //  llOwnerSay("warning:"+(string)line+":"+data); // only get here if bad line no token
            @retry;
            ++line;   // increment line count
            ++line2;
            callback = llGetNotecardLine(NC_current, line);
            }
        else if(data == EOF) // means EOF
            {
            if(NC_current=="!NC_2_primdrive")
                { //
                llOwnerSay("NCs to be Loaded into primdrive: "+llList2CSV(cur_list));
                len=llGetListLength(cur_list);
                    if(len>0)
                    { line=0;
                      line2=0;
                    NC_current=llList2String(cur_list, count);

                        if(llGetInventoryType(NC_current) != INVENTORY_NOTECARD){
                            llOwnerSay("Missing 1st NC: " + NC_current+" trying again");
                            jump nexttry;
                        }
                    callback=llGetNotecardLine(NC_current,0);
                    jump end; // this return nessary!!!!!!!
                   }
                }
            @nexttry;
            count=1+count;
            while(count != len) // while faster than if..don't know why
                { line=0;line2=0;

                NC_current=llList2String(cur_list, count);
                  if(llGetInventoryType(NC_current) != INVENTORY_NOTECARD)
                    { llOwnerSay("Missing NC: " + NC_current);
                    jump nexttry;
                   }
                callback=llGetNotecardLine(NC_current,0); jump end;
                }
                //notify end of read

                state done; jump end;
            } // was eof true, gets here each line no matter what even with llGetNotecardLine
        } // was callback id , gets here each line no matter what even with llGetNotecardLine
    @end; return;
    }
}
state done
{
state_entry(){
llOwnerSay("All NCs loaded into prim-memory, except missing");
llLinksetDataWrite("pd«",llList2CSV(cur_list));
//llMessageLinked( LINK_THIS, 123456789,"pd«",""); // tell nsprim drive to load NCs
// make sure prim drive doesn't clobber this list, so using token «
cur_list=[]; // empty list
//llOwnerSay((string)llGetUsedMemory()); // seems to be  8598
llSetMemoryLimit(llGetUsedMemory()+188); // shouldn't need much else
}

// after read masters NC go to
link_message(integer sender_num, integer num, string str, key id)
    {
    if(num==987654321){ llResetScript();}
    if(num==999999999){ llMessageLinked( LINK_THIS, 123456789,"pd«","");} // resend if script needs this value with out forcing a reread or sending this list.
    if(num==999999998){ llMessageLinked( LINK_THIS, 999999997, globaltoken,"");}
    }
//changed(integer pram){ while(CHANGED_INVENTORY == pram){llSleep(2.0); llResetScript();}}
}
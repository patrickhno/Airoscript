#!/bin/bash
# Internal functions file for airoscript.
# Recommends: wlandecrypter 

# Copyright (C) 2009 David Francos Cuartero
#        This program is free software; you can redistribute it and/or
#        modify it under the terms of the GNU General Public License
#        as published by the Free Software Foundation; either version 2
#        of the License, or (at your option) any later version.

#        This program is distributed in the hope that it will be useful,
#        but WITHOUT ANY WARRANTY; without even the implied warranty of
#        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#        GNU General Public License for more details.

#        You should have received a copy of the GNU General Public License
#        along with this program; if not, write to the Free Software
#        Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

execute(){ 
    title=$1; shift;

    if [ $TERMINAL == "screen" ]; then
		$CDCMD screen -S airoscript -c $SCREENRC -D -RR -X screen -t $title
		$CDCMD screen -S airoscript -c $SCREENRC -X at "*" stuff "${@}"
    else
        if [ $QUIET ] && [ $SCAN != 1 ]; then 
            ${@} &> /dev/null &
        else
            $CDCMD $TERMINAL $HOLD $TITLEFLAG "$title" $TOPLEFTBIG $BGC $BACKGROUND_COLOR $FGC $DUMPING_COLOR $EXECFLAG "${@}";
        fi
    fi 
    save_pids $!
}

save_pids(){
    mkdir /var/run/airoscript 2>/dev/null
    for i in `get_childs $1`; do touch "/var/run/airoscript/$i"; done
}

get_childs(){echo $( ps axo ppid,pid|awk "/$1/ {print \$2}"|grep -v "$pid") } 
clean_processes(){ for i in `ls /var/run/airoscript/`; do kill $i; done; }

arrow(){ echo -e -n "\t\n||\t\n||\t\n\/"; }
fill_menu(){ len=$(( $1 - $2 )); for i in `seq 0 $len`; do echo -n "$3"; done; }
fill(){
    menu_w="$3"; separator="$2"; title="$1"; len_1=$((${#title} + 3))
    half_len_1=$(( $len_1 / 2 )) ; loop_times=$(( $menu_w / 2 - $half_len_1 ))
    fill_menu $loop_times 1 "$separator";echo -n "$title";fill_menu $loop_times 1 "$separator"
}

mkmenu(){ # TODO IMPLEMENT INDENTATION LEVELS.
    $clear
    separator="|"; menu_t=$1 && shift; n=0; max=1;
    for i in "${@}"; do if [ "${#i}" -gt "$max" ]; then max=${#i}; fi; done;

    echo -n "+"; fill "$menu_t" "$separator_h" "$(( $max + ${#menu_t} ))" center; echo "+"
    for i in "${@}"; do n=$(( $n + 1 ))
        echo -n "$separator_v $n) " `gettext "$i"`
            if [ $n -gt 9 ]; then fill_menu $(( $max - 1 )) ${#i} " ";
            else fill_menu $max ${#i} " ";fi
        echo -e "$separator_v"
    done

    echo -n "+"; fill_menu $(( $max + 5 )) 0 "-" ; echo "+"
}

monmode(){ $iwconfig $1 |grep "Monitor" && if [ $? != 0 ]; then $AIRMON start $1 $2; fi;}
reso() {
	while true; do
		if [ "$resonset" = "" ]; then mkmenu "Resolutions" 640x480 800x480 800x600 1024x768 1280x768 1280x1024 1600x1200; read reson; fi

		case $reson in
			1 ) TLX="83";TLY="11";TRX="60";TRY="18";BLX="75";BLY="18";
                BRX="27";BRY="17";bLX="100";bLY="30";bRX="54";bRY="25"; setterminal; break;;
			2 ) TLX="90";TLY="11";TRX="60";TRY="18";BLX="78";BLY="26";
                BRX="52";BRY="15";bLX="130";bLY="30";bRX="78";bRY="25"; setterminal; break;;
			3 ) TLX="92";TLY="11";TRX="68";TRY="25";BLX="78";BLY="26";
                BRX="52";BRY="15";bLX="92" ;bLY="39";bRX="78";bRY="24"; setterminal; break;;
			4 ) TLX="92";TLY="14";TRX="68";TRY="25";BLX="92";BLY="36";
                BRX="74";BRY="20";bLX="100";bLY="52";bRX="54";bRY="25"; setterminal; break;;
			5 ) TLX="100";TLY="20";TRX="109";TRY="20";BLX="100";BLY="30";
                BRX="109";BRY="20";bLX="100";bLY="52";bRX="109";bRY="30"; setterminal; break;;
			6 ) TLX="110";TLY="35";TRX="99";TRY="40";BLX="110";BLY="35";
                BRX="99";BRY="30";bLX="110";bLY="72";bRX="99";bRY="40"; setterminal; break;;
			7 ) TLX="130";TLY="40";TRX="68";TRY="25";BLX="130";BLY="40";
                BRX="132";BRY="35";bLX="130";bLY="85";bRX="132";bRY="48"; setterminal; break;;
			* ) echo -e "`gettext \"Unknown response. Try again\"`"; sleep 1; $clear ;;
		esac
	done
}

function setterminal {
	$clear && getterminal
	echo -e "`gettext '\tIm going to set terminal options for your terminal now'`...`gettext 'done'`" 

    case $TERMINAL in 
		xterm|uxterm ) 
			TOPLEFT="-geometry $TLX*$TLY+0+0 "
			TOPRIGHT="-geometry $TRX*$TRY-0+0 "
			BOTTOMLEFT="-geometry $BLX*$BLY+0-0 "
			BOTTOMRIGHT="-geometry $BRX*$BRY-0-0 "
			TOPLEFTBIG="-geometry $bLX*$bLY+0+0 "
			TOPRIGHTBIG="-geometry $bLX*$bLY+0-0 "
			HOLDFLAG="-hold"
			TITLEFLAG="-T"
			FGC="-fg"
			BGC="-bg"
			EXECFLAG="-e"
            ;;
		gnome-terminal|gnome-terminal.wrapper ) 
			TOPLEFT="-geometry=$TLX*$TLY+0+0 "
			TOPRIGHT="-geometry=$TRX*$TRY-0+0 "
			BOTTOMLEFT="-geometry=$BLX*$BLY+0-0 "
			BOTTOMRIGHT="-geometry=$BRX*$BRY-0-0 "
			TOPLEFTBIG="-geometry=$bLX*$bLY+0+0 "
			TOPRIGHTBIG="-geometry=$bLX*$bLY+0-0 "
			EXECFLAG="-e "
			HOLDFLAG="" 
			TITLEFLAG="-t"
			FGC=""
			DUMPING_COLOR=""
			INJECTION_COLOR=""
			ASSOCIATION_COLOR=""
			DEAUTH_COLOR=""
			BACKGROUND_COLOR=""
			BGC=""
            ;;

		airosperl ) airosperl & exit ;;
	esac
    [[ "$DEBUG" = "1" ]] && echo $TOPLEFT \
				$TOPRIGHT \
				$BOTTOMLEFT \
				$BOTTOMRIGHT \
				$TOPLEFTBIG \
				$TOPRIGHTBIG \
				$HOLDFLAG\
				$TITLEFLAG\
				$FGC\
			    $BGC\
				printf -- "$EXECFLAG \n"
}


# this function allows debugging, called from main menu.
function debug {
	if [ "$DEBUG" = "1" ]; then
		export HOLD=$HOLDFLAG; echo "`gettext \" \tDebug Mode enabled, you\'ll have to manually close windows\"`"
	else export HOLD="" ;fi
}

function getterminal {
    [[ "$TERMINAL" = "GUI" ]] && TERMINAL="airoscript"
    if [ -x $TERMBIN/$TERMINAL ]; then
			echo -en "\t`gettext \"Using configured terminal\"`"
	else
		echo -en "$TERMINAL was not used, not found on path"
		echo -en '`gettext "Using default terminal"`' 
			TERMINAL=`ls -l1 /etc/alternatives/x-terminal-emulator|cut -d ">" -f 2|cut -d " " -f 2|head -n1`;        
	fi

	if [ -x $TERMBIN/$TERMINAL ]; then D="1" && echo " ($TERMINAL)" 
	else
        if [ -e $TERM ]; then 
			echo -e "`gettext \"Using environment defined terminal ($TERM)\n\"`"
			TERMINAL=$TERM
		else
            if [ -x "$TERMBIN/xterm" ]; then
				TERMINAL="xterm" && echo -e "Using Xterm\n"
			else
			echo -e 
				"`gettext \"I cant find any good terminal, please set one on your conffile
				Your TERMINAL var contains no valid temrinal
				Your alternative against x-terminal-emulator contains no terminal
				Xterm can\'t be found on your system, Maybe not in /usr/bin?\n\"`"
				exit
			fi
		fi     
	fi
}

select_ap(){
		if [ -e $DUMP_PATH/dump-01.csv ]; then
			Parseforap; $clear
			if [ "$Host_SSID" = $'\r' ]; then blankssid;
			elif [ "$Host_SSID" = "No SSID has been detected" ]; then blankssid; fi
			target; choosetarget; $clear
		else $clear && echo "`gettext 'ERROR: You have to scan for targets first'`"; fi
}

doexit(){
		echo -n `gettext "	Do you want me to stop monitor mode on $WIFI? (y/N) "`
		read dis; if [ "$dis" = "y" ]; then
			echo -n `gettext 'Deconfiguring interface...'` 
			airmon-ng stop $WIFI > /dev/null
			echo "`gettext 'done'`"
		fi

		echo -n `gettext 'Do you want me to delete temporary data dir? (y/N) '`;
		read del; if [ "$del" = "y" ]; then
			echo -n `gettext 'Deleting'` " $DUMP_PATH ... "
			rm -r $DUMP_PATH 2>/dev/null *.cap 2>/dev/null
			echo `gettext 'done'`
		fi
		exit

}

if [ "$UNSTABLE" = "1" ] && [ -e $UNSTABLEF ]; then . $UNSTABLEF; fi
if [ "$EXTERNAL" = "1" ] && [ -e $EXTF ]; then . $EXTF; fi

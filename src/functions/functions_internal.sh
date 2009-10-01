#!/bin/bash

monmode(){ $iwconfig $1 |grep "Monitor" && if [ $? != 0 ]; then $AIRMON start $1 $2; fi;}
function reso {
	while true; do
		if [ "$resonset" = "" ]; then
            echo -en "`gettext \"   ______Resolutions_____\"`"
            echo -e "\n   #                    #\n"\
            "  #  1) 640x480        #\n"\
            "  #  2) 800x480        #\n"\
            "  #  3) 800x600        #\n"\
            "  #  4) 1024x768       #\n"\
            "  #  5) 1280x768       #\n"\
            "  #  6) 1280x1024      #\n"\
            "  #  7) 1600x1200      #\n"\
            "  #____________________#\n"\
            "Option: \n"
read reson
		fi

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

		screen | "screen" | "screen " ) . $SCREEN_FUNCTIONS && echo "Screen functons loaded, replacing functions";;
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
	if [ "$DEBUG" = "1" ]
	then
		export HOLD=$HOLDFLAG
		echo "`gettext \" 	Debug Mode enabled, you\'ll have to manually close windows\"`"
	else
		export HOLD=""
	fi
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

if [ "$UNSTABLE" = "1" ] && [ -e $UNSTABLEF ]; then . $UNSTABLEF; fi
if [ "$EXTERNAL" = "1" ] && [ -e $EXTF ]; then . $EXTF; fi

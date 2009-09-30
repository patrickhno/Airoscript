#! /bin/bash

# Program:	Airopdate
# Copyright (C) -2008 David Francos Cuartero
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
#        Along with this program; if not, write to the Free Software
#        Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

DUMP_PATH=`mktemp -d`

askforopts(){
    echo "--------MAKE----------------+"\
         "| Enter special opts to make|"\
         "+---------------------------+"\
         "Opts: "
    read MKOPTS
}

installsvn(){
    echo \
    "+--------------AIRCRACK-NG-----------+ "\
    "|     Select build options           | "\
    "|                                    | "\
    "|     1) None                        | "\
    "|     2) Build Experimental tools    | "\
    "|     3) Custom options (will ask)   | "\
    "+------------------------------------+ "

    read opts; case opts in 
      1) MKOPTS="";;
      2) MKOPTS="EXPERIMENTAL=1";;
      3) askforopts;;
    esac

    cd aircrack-ng$VER &&
    make clean $MKOPTS &&
    make uninstall $MKOPTS &&
    make $MKOPTS&&
    make install $MKOPTS &&
    cd $DUMP_PATH
}

chooseversion(){

while true; do
  clear
  echo \
  "+--------------AIRCRACK-NG-----------+ "\
  "|     Select aircrack-ng version     | "\
  "|                                    | "\
  "|     1) Legacy 0.9.3                | "\
  "|     2) Latest Version (trunk)      | "\
  "|     3) Specific revision           | "\
  "+------------------------------------+ "

  read yn
  case $yn in
    1 ) VER="-0.9.3"; svn co http://trac.aircrack-ng.org/svn/tags/0.9.3/ aircrack-ng-$VER ; installsvn ; break ;;
    2 ) VER="-1.0-rc3"; svn co http://trac.aircrack-ng.org/svn/trunk/ aircrack-ng-$VER ; installsvn ; break ;;
    3 ) svnrev ; break ;;
    * ) echo "unknown response. Try again" ;;
  esac
done
}

function svnrev {
	  echo "+----------------SVN------------------+"
	  echo "|       Input revision number         |"
	  echo "+-------------------------------------+"

	read rev && echo You typed: $rev
	if [ $rev ]; then svn co -r $rev http://trac.aircrack-ng.org/svn/trunk/ aircrack-ng"$rev"
	else svn co  http://trac.aircrack-ng.org/svn/trunk/ aircrack-ng; fi
    VER=$rev installsvn
}

function airoscript {
	svn co http://trac.aircrack-ng.org/svn/branch/airoscript/ airoscript
	cd airoscript && make && cd $DUMP_PATH
}

function menu {
  echo "+-------------Select_Action-------------------+ "\
       "|   1) Aircrack-ng   - Get aircrack-ng        | "\
       "|   2) Airoscript-ng - Get airoscript         | "\
       "|   3) Quit          - Exit this script       | "\
       "+---------------------------------------------+ "
}

cd $DUMP_PATH && clear && menu
select choix in "1 2 3"; do
	if [ "$choix" = "1" ]; then clear; chooseversion && clear && menu
	elif [ "$choix" = "3" ]; then
		clear && get_airoscript && clear
		echo "Installed lastest airoscript version"
		menu
	elif [ "$choix" = "4" ]; then clear && exit; 
    else clear && echo "Wrong number entered" && menu; fi
done

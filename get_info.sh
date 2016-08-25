#!/bin/bash

# Functions

function checkVar {
#Prints value of env. variable or says when not set
  VAR="$1"

  if [[ -n ${!VAR} ]]; then
    printf "%-25s: ${!VAR}\n" "$VAR"
  else
    printf "%-25s: ***NOT SET***\n" "$VAR"
  fi
}

function getEnv {
#Reads environment variables listed in csv file
#Stop script if list not found
  if [ ! -e ./env-vars.txt ];
  then
    echo "ERROR: Cannot find env-vars.txt"
    echo "Make sure it is copied over to remote server."
    exit
  fi

  LIST=./env-vars.txt

  OLD_IFS="$IFS"
  IFS=","

  while read VAR VALUE ; do 

    #Allow # as a comment and skip blank lines
    if [[ ${#VAR} -eq 0  || $VAR =~ ^\ *# ]] ; then 
      continue
    fi
  
    checkVar "$VAR"

  done < $LIST
  IFS=$OLD_IFS
}


function getJavaInfo {
#Taken From: http://goo.gl/eUAywy
  if type -p java; then
    echo found java executable in PATH
    _java=java
  elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo found java executable in JAVA_HOME     
    _java="$JAVA_HOME/bin/java"
  else
    echo "no java"
  fi

  if [[ "$_java" ]]; then
    version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo version "$version"
  fi
}

function centSix {
  echo "Services"
  echo "--------"
  echo "cpuspeed: "
  /sbin/service cpuspeed status
  echo ""
  echo "ntpd: "
  /sbin/service ntpd status
  echo "" 

  echo "chkconfig output:"
  echo "-----------------"
  /sbin/chkconfig
  echo ""
}

function centSeven {
  echo "CPU Speed"
  cpupower frequency-info
  echo ""

  echo "systemctl output:" 
  echo "-----------------"
  systemctl list-unit-files --type=service
  echo ""
}

function getServices {
  #Version of centOS
  centVer=$( cat /etc/redhat-release | sed 's/[^0-9]*//g' )
  #centVer=$( echo "CentOS release 6.5 (Final)" | sed 's/[^0-9]*//g' )
  majorVer=${centVer:0:1}

  case $majorVer in 
    "6")
      centSix
      ;;

    "7")
      centSeven
      ;;
    
    *) #default
      echo "ERROR finding Redhat Version"
      echo "centVer: $centVer"
      echo "majorVer: $majorVer"
      echo ""
      ;;
  esac
}

function getStaticData {
  head -1 /etc/redhat-release

  echo "~~~STATIC INFO~~~"

  #hardware specs
  echo -e "$(lscpu)\n"

  #processor
  echo "Processor:       $(uname -p)"
  #kernal name
  echo "Kernel Name:     $(uname -s)"
  #kernal release
  echo "Kernel Release:  $(uname -r)"
  #kernal version
  echo "Kernel Version:  $(uname -v)"
  #nodename
  echo "Node Name:       $(uname -n)"
  #machine
  echo -e "Machine:         $(uname -m)\n"

  #network configs
  echo "Ethernet interfaces: "
  /sbin/ip addr
  echo ""

  #hostname
  echo -e "/etc/hosts\n----------"
  cat /etc/hosts
  echo ""

  #fstab
  echo -e "/etc/fstab\n----------"
  cat /etc/fstab
  echo ""

  #Environment veriables
  echo "Environment Variables"
  getEnv
  echo ""

  #Java info
  echo "Java Information"
  getJavaInfo
  echo ""

  #Services
  getServices 
}

function getDynamicData {

  echo "~~~DYNAMIC INFO~~~"

  #partitions
  df -h >> "$DYNAMIC"
  echo "" >> "$DYNAMIC"

  #memory
  free="$( free -m )"
  echo -e "$(free -m)\n"

  #time registered
  echo "Time and Date:"
  echo "$( date )"
}


# Body
 
#Static info
STATIC="stc-$1.txt"
#Dynamic info
DYNAMIC="dyn-$1.txt"

if [ $# -eq 0 ]
  then
    echo "No arguments supplied."
    echo "Need: ServerName"
    exit
fi

getStaticData > "$STATIC"
getDynamicData > "$DYNAMIC"


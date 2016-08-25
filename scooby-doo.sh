#!/bin/bash

#Functions

function archiveSSH {
#Takes static and dynamic data and saves to archive txt file
  now=$(ssh -n $2 "date +"%Y_%m-%d_%H-%M"")    #timestamp
  archname="$1_$now.txt"    #archive n ame

  #Create archive file with timestamp on top
  ssh -n $2 "printf 'Date: %s \nServer: %s \n' "$now" "$1" > $archname"

  #Put static info and dynamic info in one file
  ssh -n $2 cat "stc-$1.txt >> $archname"
  ssh -n $2 cat "dyn-$1.txt >> $archname"

  #Copy file over to local directory
  mkdir -p ./archives/$1
  scp $2:~/$archname "./archives/$1"

  #Remove file instances on server
  ssh -n $2 "rm ./stc-$1.txt"
  ssh -n $2 "rm ./dyn-$1.txt"
  ssh -n $2 "rm ./$archname"
}

function archiveLocal {
#Archives output files if running script locally
  now=$( date +"%Y_%m-%d_%H-%M" )
  archname="$1_$now.txt"

  #Create archive file with date and timestamp on it
  printf 'Date: %s \nServer: %s \n' "$now" "$1" > $archname
  
  #Put static and dynamic data into one file
  cat stc-$1.txt >> $archname
  cat dyn-$1.txt >> $archname

  #Make archive directory and move archive file into directory
  mkdir -p ./archives/$1
  echo "Storing $archname"
  mv ./$archname ./archives/$1/

  #Remove temporary static and dynamic files
  rm ./stc-$1.txt
  rm ./dyn-$1.txt

}

function diffSSH {
#Calls diff command on acquired static data and gold file.  Makes gold file if cannot find existing gold file.
  diffout="./diff-out/$1/diff-$1-$(date +"%Y_%m-%d_%H-%M").txt"

  #If Gold file or directory does NOT exist
  if [ ! -f ./gold/gold-$1.txt ]; 
  then
    mkdir -p ./gold
    echo "Could not find gold file. Creating with current output file."
    #Copy static file from remote server and create gold file
    scp $2:~/stc-$1.txt ./gold/gold-$1.txt    
  else
    #If gold file exists already, diff with newest static data and put output in diff-out file
    mkdir -p ./diff-out/$1  
    echo "$1 diff output" > ./$diffout
    echo "Date: $(date +"%Y_%m-%d_%H-%M")" >> ./$diffout
    ssh -n $2 "cat stc-$1.txt" | diff - ./gold/gold-$1.txt >> ./$diffout
    DIFF_RETURN=$?
    echo "Checking configurations: "
    #echo "DIFF RETURN CODE: $DIFF_RETURN"
    if [ $DIFF_RETURN -eq 0 ];  #no changes
    then
      echo "no change" >> ./$diffout
      echo "no change"
    elif [ $DIFF_RETURN -eq 1 ]; #change exists
    then
      echo "There is a change. For more details go to: "
      echo "$diffout"
    else
      echo "Something is wrong Diff returned: error code $DIFF_RETURN"
    fi
  fi
}

function diffLocal {
#Calls diff command on acquired static data and gold file.  Makes gold file if cannot find existing gold file.
  diffout="./diff-out/$1/diff-$1-$(date +"%Y_%m-%d_%H-%M").txt"

  #If Gold file does NOT exist
  if [ ! -f ./gold/gold-$1.txt ]; 
  then
    mkdir -p ./gold
    echo "Could not find gold file. Creating with current output file."
    cp ./stc-$1.txt ./gold/gold-$1.txt
  else
    mkdir -p ./diff-out/$1  
    echo "$1 diff output" > ./$diffout
    echo "Date: $( date +"%Y_%m-%d_%H-%M" )" >> ./$diffout
    cat stc-$1.txt | diff - ./gold/gold-$1.txt >> ./$diffout
    DIFF_RETURN=$?
    echo "Checking configurations: "
    #echo "DIFF RETURN CODE: $DIFF_RETURN"
    if [ $DIFF_RETURN -eq 0 ];  #no changes
    then
      echo "no change" >> ./$diffout
      echo "no change"
    elif [ $DIFF_RETURN -eq 1 ]; #change exists
    then
      echo "There is a change. For more details go to: "
      echo "$diffout"
    else
      echo "Something is wrong Diff returned error code $DIFF_RETURN"
    fi
  fi

}

function connect {
  echo "Getting info..."
  echo "Connecting to $1 via $2..."
  # Check ssh connection first
  ssh -n $2 exit
  if [ $? -eq 0 ];
  then
    echo "Connection successful"
    #Stop script if list not found
    if [ ! -e ./env-vars.txt ];
    then
      echo "ERROR: Cannot find env-vars.txt"
      echo "Make sure it is in local directory."
      exit
    fi
    scp ./env-vars.txt $2:~/env-vars.txt
    ssh $2 "bash -s" < ./get_info.sh "$1" #Run script on server
    ssh -n $2 "rm ./env-vars.txt"
    diffSSH $1 $2 
    archiveSSH $1 $2  # archive and get output file
  else 
    echo "ERROR: Cannot ssh to $1"
  fi
}

function sshToServers {

  # Stop script if list not found
  if [ ! -e ./server-list.txt ];
  then
    echo "ERROR: Cannot find list.txt"  
    echo "Make sure it is in this directory."
    exit
  fi

  LIST=./server-list.txt

  OLD_IFS=$IFS
  IFS=","

  #Iterate through CSV file
  while read SERVER LOGIN ; do

    #Allow # as a comment and skip blank lines
    if [[ ${#SERVER} -eq 0  || $SERVER =~ ^\ *# ]] ; then 
      continue
    fi

    echo "server: $SERVER"
    echo "login:  $LOGIN"
    echo "working..."

    #Check ssh connection before moving on
    ssh -n $LOGIN exit
    if [ ! $? -eq 0 ];
    then
      echo "======================="
      continue    #Iterate to next server in list
    fi

    connect $SERVER $LOGIN
    echo "done!"
    echo "======================="

  done<"$LIST"
}

function runLocally {
  ./get_info.sh "$1"
  diffLocal "$1"
  archiveLocal "$1"
}


#Body
while [ ! "$input" == "y" ] && [ ! "$input" == "n" ];
do
  #Prompt user for input
  read -p "Run locally? (y/n) or press ENTER to run locally: " input

  #If user press ENTER
  if [ "$input" == "" ];
  then
    input="y"
  fi

  if [ "$input" == "n" ]; 
  then
    echo "Running remotely"
    sshToServers
  elif [ "$input" == "y" ];
  then
    echo "Running locally"
    runLocally $( uname -n )
  else
    echo "Invalid input:" 
    echo "Please enter y or n or just press ENTER to run locally"
    input=""
  fi
done

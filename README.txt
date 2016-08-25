Purpose
-------
This script gathers information from a remote server and looks for any 
inconsistencies in the current configurations. Any gathered data is archived 
in a local directory for future reference and troubleshooting purposes.

Files needed
------------
Files necessary to run properly:
- scooby-doo.sh
- get_info.sh
- server-list.txt
- env-vars.txt

server-list.txt is NOT needed to run script locally

Preparation
-----------
Make sure that scripts are executable.
If not, use 'chmod +x [file.sh]'

server-list.txt and env-vars.txt are both csv files.

server-list.txt: SERVER_NAME,SSH_LOGIN
env-vars.txt: ENV_VARIABLE,PATH_VALUE

A "#" can be used to 'comment out' any lines to exclude it in runtime.

Script execution
----------------
- Execute script by typing "./scooby-doo.sh" in the directory that the 
  script is located at.
- Follow on-screen instructions to run the script locally or remotely.

What to expect after execution
------------------------------
Date convention: YYYY_mm-dd_HH-MM
                 year_month-day_hour-minute
The script will make the following directories if they don't already exist:
- archives
- diff-out
- gold

archives
--------
- Archive files holds all information about a machine at the date specified.
- Each script execution will create a new archive file specified with
  current date and time.

diff-out
--------
- The diff output holds the the ouptut of a diff command between the gold 
  file and the recent data collected from the machine.
- The diff output is useful to generally find out where on the archive file
  there is any unexpected configurations or settings.
- HOW TO READ: refer to man page of diff 

gold
----
- Contains the file with desired configurations and will be used to compare 
  against future script executions.
- IMPORTANT: A gold file will be created if one does not already exist.

Concluding notes
----------------
- With a complete run, this script will not leave any files on remote servers.
- Running this script multiple times in the same minute will overwrite any
  archive files produced from previous executions in that same minute.

Known bugs
----------
- Commands in get_info.sh listed below returned "[command]: command not found"
  errors.  I only get this error when I try and run the command remotely over ssh.  
  I worked around this by putting in the full path to the command. 
  I noticed that all of these commands were in the /sbin/ folder so maybe that
  can give a hint as to the underlying problem. 
  Commands that throw error:
  - service
  - chkconfig
  - ip
  





















                                            :\                  
                                            ;\\                 
                                            ; ;;  __            
                                            :/ :-",dP    _.ggp. 
                                            :     (*).-"" :$$$$;
                                            ;              T$$$;
                                           :     _,-        `TP 
                                           ;      `.  _      ;  
                                           ;        "" \    /   
                                           ;            `-+'    
                                           :            .-'     
                                            ;      \;   ;       
                                            :       `--+'-.     
 .---.                                       ;         ;`       
:_    `.                                     :         ;        
  "-,   ;                                   / "-.      :        
     ;  :                                .p""-.  ""--..:        
     ;  :                             .-T$$P   ""--..___l-,     
     ;  :                          .-"   ""            :\()l    
     ;  ;              _________.-"         $$          ;`-'    
     ;  ; bug     .--""$$$$$$$P                         :       
     ;  '._____.-"_.   'T$$P^'                          :       
     :         .-"                                 \    :       
     '.___...-"                                     ;   :       
           /                                        ;   ;       
          :                   .            /       /   /        
          ;                 .J__          :       /  .'         
          ;               .;    "-.       ;      j.-"           
          :             .'/        "-.    ;     : :             
           ;          .' /            "---:     ; ;             
           :       .-"  /                 :    : :              
           ;    .-"  .-"                   ;   ; ;              
          /   .'  .-"                      :  : :               
         /  .'  .'                         :  | ;               
        :  /\  :                           :  ;:                
        ; :  ; ;                           : : ;                
       :  ;  : :__                         ; | :                
       ; _L__J   -`,                      :  : '--.             
       :  l l l____l                       \ _`-,-:             
      ( l ;_:-'                            /  l |`;             
       """                                :_l :_;_l             
                                             "      


#!/bin/bash
DUMP_FILE="file1"
PATTERN_GREP="CREATE DATABASE \/\*\!32312 IF NOT EXISTS\*\/"

list_databases () {

        #Keep the last line number
        last_line=`wc -l $DUMP_FILE`

        echo "Searching databases in progress... Thanks you wait"
        RESULT_GREP=`pp -l $DUMP_FILE | grep -n "$PATTERN_GREP"`
                                                                                                                                                                                              
        echo "---------------------------------------------------------------\n"                                                                                                              
        echo "- Please, choose a database :\n "                                                                                                                                    
        echo "---------------------------------------------------------------\n"                                                                                                              
                                                                                                                                                                                              
        #For each grep result, we keep the database name 
        i=1                                                                                                                                                                                   
        for elt in $(echo $RESULT_GREP | tr -s ";" "\n" | awk '{print $7}' | tr -s "\`" " ")                                                                                                  
        do                                                                                                                                                                                    
                echo -e "\033[1m-$i)\033[0m $elt"
                ((i++))
        done
        # $j The number of databases inside the dump
        j=$(($i-1))

        read -p " Database number ? : " return_param
        i=1
        #We parse again the grep result, but i get the line number where the database dump begin
        for elt in `echo $RESULT_GREP | tr -s ";" "\n" | awk '{print $1}' | cut -d ":" -f 1`
        do
                #When i found the selected database
                if [[ $i -eq $return_param ]]
                then
                        #I get the begin line number
                        start_line=$elt
                        #If the database selectioned is the last one
                        if [[ $i -eq $j ]]
                        then
                                #We leave, because the last line of dump file, is the last line of database dump selected by the user 
                                break;
                        else
                                i=1
                                for elt in `echo $RESULT_GREP | tr -s ";" "\n" | awk '{print $1}' | cut -d ":" -f 1`
                                do
                                        if [[ $i -eq $j ]]
                                        then
                                                last_line=$elt
                                                break;
                                        fi
                                        ((i++))
                                done
                        fi
                fi
                ((i++))
        done
        echo "var1 : $start_line var2 : $last_line"
        #We extract the database with sed
        sed -n '$last_line"q";$start_line,$(($last_line-1))"p"' $DUMP_FILE > export.sql
        echo "sed -n '$last_line"q";$start_line,$(($last_line-1))"p"' $DUMP_FILE > export.sql"
}


################################################ MAIN ################################################
menu() {
   echo -en "\033[32m 1) Extraire une base de données\033[0m\n"
   echo -en "\033[32m 3) Extraire une table en particulier\033[0m\n"
   echo -en "\033[32m 5) Sortir\033[0m\n"
}


#Check if DUMP_FILE is empty
if [[ ! $DUMP_FILE ]]
then
        echo "$DUMP_FILE is empty"
        exit 1
fi


menu
while read -p "Votre choix : " CHOIX; do
   case $CHOIX in
      1) list_databases ;;
      2) list_tables;;
      3) break;;
      *) echo "Invalid choice"  ;;
   esac
menu
done

exit

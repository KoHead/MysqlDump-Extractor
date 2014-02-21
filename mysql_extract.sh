#!/bin/bash

#Please, specify the name of you sql file dump 
DUMP_FILE="databases_dump.sql"

#Pattern for grep
PATTERN_GREP="CREATE DATABASE \/\*\!32312 IF NOT EXISTS\*\/"

get_database_name () {
	
	i=1
	for elt in $(echo $RESULT_GREP | tr -s ";" "\n" | awk '{print $7}' | tr -s "\`" " ")
	do	
		if [[ $i -eq $j ]]
		then
			return $elt
			break;
		fi
		(($i++))
	done
}
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
        

	#Now, we keeping  the database name choosing by the user
        i=1
        for elt in $(echo $RESULT_GREP | tr -s ";" "\n" | awk '{print $7}' | tr -s "\`" " ")
        do
                if [[ $i -eq $return_param ]]
                then
                       database_name=$elt
                fi
                ((i++))
        done

        #We parse again the grep result, but i get the line number where the database dump begin
	i=1
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

	#We extract the database with sed
	echo "Extract in progress..."
	sed -n '$last_line"q";$start_line,$(($last_line-1))"p"' $DUMP_FILE > $database_name.sql

	echo "Your database is extracted in the $database_name.sql file"
}


################################################ MAIN ################################################
menu() {
   echo -en "\033[32m 1) Select and extract one database\033[0m\n"
   #echo -en "\033[32m 2) Select and extract one table\033[0m\n"
   echo -en "\033[32m 2) Exit\033[0m\n"
}


#Check if DUMP_FILE is empty
if [[ ! $DUMP_FILE ]]
then
        echo "$DUMP_FILE is empty"
        exit 1
fi


menu
while read -p " Your choice ?: " CHOICE; do
   case $CHOICE in
      1) list_databases ;;
      2) list_tables;;
      3) break;;
      *) echo "Invalid choice"  ;;
   esac
menu
done

exit

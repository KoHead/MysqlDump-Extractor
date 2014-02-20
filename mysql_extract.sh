#!/bin/bash
DUMP_FILE="file1"
PATTERN_GREP="CREATE DATABASE \/\*\!32312 IF NOT EXISTS\*\/"

list_databases () {

        #On récupère le numéro de la dernière ligne
        last_line=`wc -l $DUMP_FILE`

        echo "Recherche des bases en cours, merci de patienter"
        RESULT_GREP=`pp -l $DUMP_FILE | grep -n "$PATTERN_GREP"`
                                                                                                                                                                                              
        echo "---------------------------------------------------------------\n"                                                                                                              
        echo "- Veuillez choisir une base de données :\n "                                                                                                                                    
        echo "---------------------------------------------------------------\n"                                                                                                              
                                                                                                                                                                                              
        #Pour chaque résultat du grep on sort le nom de la base                                                                                                                               
        i=1                                                                                                                                                                                   
        for elt in $(echo $RESULT_GREP | tr -s ";" "\n" | awk '{print $7}' | tr -s "\`" " ")                                                                                                  
        do                                                                                                                                                                                    
                echo -e "\033[1m-$i)\033[0m $elt"
                ((i++))
        done
        # $j représente le nombre de base contenu dans le dump
        j=$(($i-1))

        read -p " Base numero ? : " return_param
        i=1
        #On re-parcours le résultat du grep en prenant cette fois-ci le numéro de ligne ou commence le dump de la base
        for elt in `echo $RESULT_GREP | tr -s ";" "\n" | awk '{print $1}' | cut -d ":" -f 1`
        do
                #Lorsque l'on trouve la base en question
                if [[ $i -eq $return_param ]]
                then
                        #On récupère le numéro de ligne de commencement
                        start_line=$elt
                        #Si c'est la dernière base de sélectionnée
                        if [[ $i -eq $j ]]
                        then
                                #On sort, cela veut dire que la dernière ligne du fichier correspond a la dernière ligne du dump en question
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
        #On extrait la base avec sed
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

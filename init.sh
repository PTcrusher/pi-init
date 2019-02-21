#!/bin/bash
: '
ERROR CODES
  0 - no errors
  499 - execution aborted

Author: Edgar Santos
Description: Script to automate the tune up of a raspberry pi node

Requirements: This script need bash version 4.3+ to run
              The standalone scripts DESCRIPTION & GUID must be unique

Multi-select code as found in
https://serverfault.com/questions/144939/multi-select-menu-in-bash-script 
(2013-05-10 - Dennis Williamson)
'
: '
    Method to toggle the selection in the in the install selection menu
    Arguments: $1 - hash to be changed
               $2 - selected value
'
choice () {
    local -n hashA=$1
    local choice=$2

    if [[ "$choice" == *+ ]]; then choice=${choice%?}; fi
    local set_unset=`echo "${hashA[$choice]}" | cut -d':' -f2`

    if [[ -z "${set_unset}" ]] # toggle
    then
        hashA[$choice]="${hashA[$choice]}+"            
    else
        hashA[$choice]="${hashA[$choice]%?}" 
    fi
}

: '
    Helper method to help in the creation of the dependancies structure
    as described in the fill_dependancies() method
    Arguments: $1 - name of the script to be analysed
               $2 - folder used to fill the structure
'
dependancies () {
    local fl=$1 
    local path=$2 
    set_variable DEPENDANCIES "${fl}" 4

    if [ ${#DEPENDANCIES[@]} -ne 0 ]; then
        for related_fl in "${DEPENDANCIES[@]}"
        do
            mkdir -p "${path}/${related_fl}" 
            dependancies ${related_fl} "${path}/${related_fl}"
        done
    fi
}

: '
    Helper method to extract information from the standalone scripts
    Arguments: $1 - variable that will hold the extracted info
               $2 - GUID of the standalone script where the information will be extracted
               $3 - line number to extract from the standalone script
'
set_variable () {
    local -n key=$1
    local filename=$2
    local linenumber=$3

    eval key=`sed -n "${linenumber}{p;q}" "functions/${filename}.sh" | cut -d"=" -f2`
}

: '
    Method to fill an hash with the standalone scripts found in the functions/ folder
    Arguments: $1 - hash to be filled
               $2 - use standalone script GUID as the hash key
'
fill_hash_with_standalone_scripts () {
    local -n hashA=$1
    local guid_is_key=$2
    for fil in functions/*.sh;
    do
        #extension="${fil##*.}"
        fil=`basename -- "${fil}"`; fil="${fil%.*}"

        set_variable GUID "${fil}" 2
        set_variable DESCRIPTION "${fil}" 3

        if [ "${guid_is_key}" = true ]
        then
            hashA+=( ["${GUID}"]="${DESCRIPTION}" )
        else
            hashA+=( ["${DESCRIPTION}"]="${GUID}:" )   
        fi
    done
}

: '
    Method that creates a folder structure used to find out which dependancies
    a particular standalone script have. This folder structure is particularly usefull
    in the installation process.  
'
fill_dependancies() {
    for fil in functions/*.sh;
    do
        fil=`basename -- "${fil}"`; fil="${fil%.*}"
        set_variable GUID "${fil}" 2
        mkdir -p "temp/${GUID}"
        dependancies ${fil} "temp/${GUID}"
    done
}

: '
    Method to reverse an array
    Arguments: $1 - array to be reversed
               $2 - reversed array
'
reverse_array() {
    local -n arrA=$1
    local -n arrB=$2

    for (( idx=${#arrA[@]}-1 ; idx>=0 ; idx-- )); do
        arrB+=( "${arrA[idx]}" )
    done
}

##MAIN

# set environment
shopt -s nullglob
unset VERBOSE
# end of set environment region

# handle command line options
NO_DEPENDANCY_CHECK=false
while getopts "vn" c
do
    echo "Processing $c : OPTIND is $OPTIND"
    case $c in
        v) VERBOSE=true ;;
        n) NO_DEPENDANCY_CHECK=true;;
    esac
done

echo "Out of the getopts loop. OPTIND is now $OPTIND"
shift $((OPTIND-1))
if [ $VERBOSE ]; then set -x; fi
# end of handle command line options region

# declare arrays
EXIT_CODE="0"
declare -A options_hash
declare -A count_of_scripts
declare -a unordered_install
declare -a ordered_install
# end of declare arrays region

echo "Searching for standalone scripts..."
fill_hash_with_standalone_scripts options_hash false
echo "Checking for script dependancies..."
rm -Rf temp/
fill_dependancies

#add the 'standalone scripts' description to the list valid_options
#add the 'standalone scripts' description with a (+) sign appended
printf -v valid_options "%s|" "${!options_hash[@]}"; printf -v valid_options_plus "%s+|" "${!options_hash[@]}"
#normalize data, data must separated by a pipe '|' to be valid
valid_options=( "${valid_options[@]}""${valid_options_plus[@]}" ); valid_options=`echo ${valid_options[@]} | sed "s/ /*/g"`; valid_options=${valid_options%?}

PS3='Please select what to install: '
while :
do
    clear
    
    # add options to the selection menu
    #for instance if the script 'Install Papirus' is selected the entry in the hash would be 
    # ['<Script Description>']='<Script GUID>:<(+) for selected, () no sign for unselected>'
    # ['Install Papirus']='67952747-d79b-45fd-8678-62be0bebb822:+'
    unset options_for_menu
    declare -a options_for_menu
    for key in "${!options_hash[@]}"
    do
        val=`echo "${options_hash[$key]}" | cut -d':' -f2`
        options_for_menu+=( "${key}""${val}" )
    done
    options_for_menu+=( "Done" )
    # end of add options to the selection menu window

    select opt in "${options_for_menu[@]}"
    do
        eval "case \"${opt}\" in
            ${valid_options}) 
                choice options_hash \"${opt}\"
                break
                ;;
            \"Done\")
                break 2
                ;;
            *) printf \"%s\n\" \"invalid option\";;
        esac"
    done
done

echo -e "\nOptions chosen:"
for opt in "${!options_hash[@]}"
do
    guid=`echo "${options_hash[$opt]}" | cut -d':' -f1`
    flagged=`echo "${options_hash[$opt]}" | cut -d':' -f2`
    if ! [[ -z "${flagged}" ]]
    then
        #use the dependancies structure to find out the correct install sequence
        #add the select installation script first
        if [[ -z "${count_of_scripts[$guid]}" ]]
        then
            count_of_scripts+=( ["${guid}"]=1 )
            unordered_install+=( "${guid}" )
        else
            count_of_scripts[${guid}]++
        fi
        #end of add the selected installation script first region
        let i=1
        while [ `find temp/${guid}/ -mindepth $i -maxdepth $i -type d -printf '%f\n' | awk 'END{ print NR }'` -ne 0 ] && [ "${NO_DEPENDANCY_CHECK}" = false ]
        do
            for direct in `find temp/${guid}/ -mindepth $i -maxdepth $i -type d -printf '%f\n'`;
            do
                if [[ -z "${count_of_scripts[$direct]}" ]]
                then
                    count_of_scripts+=( ["${direct}"]=1 )
                    unordered_install+=( "${direct}" )
                else
                    count_of_scripts[${direct}]++
                fi
            done    
            let i++
        done
        #end of use the dependancies structure to find out the correct install sequence region

        echo "${guid}: ${opt}"  
    fi
done

reverse_array unordered_install ordered_install
unset options_hash
declare -A options_hash
fill_hash_with_standalone_scripts options_hash true

echo -e "\nInstall order*:"
for opt in "${ordered_install[@]}"
do
    echo "${opt}: ${options_hash[$opt]}"
done
echo "* you may see additional entries in this list due to dependancies"

echo ""
proceed=false
while :
do
    read -p "About to begin installation. Do you wan to proceed? (y/n)? " answer
    case ${answer:0:1} in
        y|Y )
            proceed=true
            break
            ;;
        n|N )
            EXIT_CODE="499"
            break 2
            ;;
        * ) ;;
    esac
done

if [ "${proceed}" = true ]
then
    echo -e "\nBeggining installation of the standalone scripts..."
    for opt in "${ordered_install[@]}"
    do
        echo "Calling ${opt}: ${options_hash[$opt]}..."
        . functions/${opt}.sh
    done
     echo -e "\nFinished installation!"
fi

exit $EXIT_CODE
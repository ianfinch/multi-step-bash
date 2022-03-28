#!/bin/bash 

# Colours
WHITE=$( echo -e "\033[38;2;255;255;255m" )
GREY=$( echo -e "\033[38;5;245m" )
GREEN=$( echo -e "\033[38;5;46m" )
AMBER=$( echo -e "\033[38;5;166m" )
RED=$( echo -e "\033[38;5;204m" )
BLUE=$( echo -e "\033[38;5;39m" )
YELLOW=$( echo -e "\033[38;5;226m" )
PLAIN=$( echo -e "\033[0m" )

# Backgrounds
BG_WHITE=$( echo -e "\033[48;2;255;255;255m" )
BG_SOLARIZED=$( echo -e "\033[48;2;0;43;54m" )

# Icons
PENDING=$( echo -e "\u2505" )
RUNNING=$( echo -e "\u2692" )
TICK=$( echo -e "\u2714" )
CROSS=$( echo -e "\u2718" )

# Control sequences
BOLD=$( echo -e "\033[1m" )
CLEAR=$( echo -e "\033[H\033[J" )
CLEAR_LINE=$( echo -e "\033[K" )
CLEAR_BELOW=$( echo -e "\033[J" )

# Constants
startTime=$( date '+%s' )
timestamp=$startTime
width=$( tput cols )
box_h=$( echo -e "\u2550" )
box_v=$( echo -e "\u2551" )
hrule=$( printf "%${width}s" | sed "s/ /${box_h}/g" )

# We use 'bc' for calculations, so make sure we have it
bc=$( which bc )
if [[ "$bc" == "" ]] ; then
    echo "FATAL: bc is not installed"
    exit 1
fi

# Make sure we've got a title
if [[ "$title" == "" ]] ; then
   title="MULTI-STEP PROCESS"
fi

# Also need steps
if [[ "$steps" == "" ]] ; then
   steps=( "No steps defined" )
fi

# Counter for current step number
__step_number=0

# An array of step statuses
__step_status=()

# Initial display of the steps
__display_steps() {

    # Set up scrolling area
    endOfSteps=$( echo "${#steps[@]} + 5" | bc )
    echo -e "\033[${endOfSteps}r"

    # Display header
    echo "${CLEAR}${BG_SOLARIZED}${YELLOW}$hrule${PLAIN}"
    echo "${BG_SOLARIZED}${CLEAR_LINE}${YELLOW}${BOLD} ${title}${PLAIN}"
    echo "${BG_SOLARIZED}${YELLOW}$hrule${PLAIN}"

    # Display the steps
    for ((idx=0; idx < ${#steps[@]}; ++idx)); do

        if [[ "${__step_status[$idx]}" == "" ]] ; then
            echo "${BG_SOLARIZED}${CLEAR_LINE}${GREY} ${PENDING} ${steps[$idx]}${PLAIN}"
        else
            statusFlag=$( echo ${__step_status[$idx]} | cut -c1-1 )
            timer=$( echo ${__step_status[$idx]} | sed 's/^.//' )

            if [[ "$statusFlag" == "S" ]] ; then
                echo "${BG_SOLARIZED}${CLEAR_LINE}${GREEN} ${TICK} ${steps[$idx]} (${timer})${PLAIN}"
            elif [[ "$statusFlag" == "F" ]] ; then
                echo "${BG_SOLARIZED}${CLEAR_LINE}${RED} ${CROSS} ${steps[$idx]} (${timer})${PLAIN}"
            else
                echo "${BG_SOLARIZED}${CLEAR_LINE}${GREY} ${PENDING} ${steps[$idx]}${PLAIN}"
            fi
        fi
    done

    # Separator
    echo "${BG_SOLARIZED}${YELLOW}$hrule${PLAIN}"
}

# Clear the output area
__clear_output() {
    endOfSteps=$( echo "${#steps[@]} + 5" | bc )
    RESUME=$( echo -e "\033[${endOfSteps};H" )
    echo -n "${RESUME}${CLEAR_BELOW}"
}

# Clear the scrolling region from the terminal
__reset_scrolling() {
    echo -e "\033[r"
    __clear_output
}

# Calculate how long from start until now
__get_time() {

    startTime=$1
    timestamp=$2

    now=$( expr $( date '+%s' ) )

    totalTime=$( expr ${now} - ${startTime} )
    totalMins=$( expr ${totalTime} / 60 )
    totalSecs=$( expr ${totalTime} - $( expr ${totalMins} '*' 60) )

    lapTime=$( expr ${now} - ${timestamp} )
    lapMins=$( expr ${lapTime} / 60 )
    lapSecs=$( expr ${lapTime} - $( expr ${lapMins} '*' 60) )

    echo "${lapMins}m${lapSecs}s / ${totalMins}m${totalSecs}s"
}

# Set the position for displaying a step
__set_step_position() {

    hpos=$( echo "${__step_number} + 4" | bc )
    POSITION=$( echo -e "\033[${hpos};H" )
    echo -n "${POSITION}"
}

# Start a specific step - parameter is number
__start_step() {

    if [[ ${__step_number} -ge ${#steps[@]} ]] ; then
        steps[${#steps[@]}]="Unexpected step"
        __display_steps
    fi

    __set_step_position "${__step_number}"
    echo "${POSITION}${BG_SOLARIZED}${CLEAR_LINE}${WHITE} ${RUNNING} ${steps[${__step_number}]}${PLAIN}"
    __clear_output
}

# Mark a step as successful
__step_success() {

    __step_status[${#__step_status[@]}]="S$( __get_time "${startTime}" "${timestamp}" )"
    now=$( expr $( date '+%s' ) )
    timestamp=${now}
    __display_steps
    __step_number=$( echo "${__step_number} + 1" | bc )
}

# Mark a step as failed
__step_failure() {

    __step_status[${#__step_status[@]}]="F$( __get_time "${startTime}" "${timestamp}" )"
    now=$( expr $( date '+%s' ) )
    timestamp=${now}
    __display_steps
    __step_number=$( echo "${__step_number} + 1" | bc )
}

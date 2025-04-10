#!/bin/bash

# Define colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
NC='\e[0m' # No color


# Print the banner
echo -e "${CYAN}"
echo "                                                              ,----,                                                         "      
echo "                   ____ ,-.----.                            ,/   .\`|                                                            ,--.        ,--.                            "      
echo "     ,---,       ,'  , \`\    /  \   .--.--.               ,\`   .'  :,----..            .--.--.    ,----..    ,---,             ,--.'|      ,--.'|   ,---,,-.----.           "     
echo "  ,\`--.' |    ,-+-,.' _ |   :    \ /  /    '.           ;    ;     /   /   \          /  /    '. /   /   \  '  .' \        ,--,:  : |  ,--,:  : | ,'  .' \    /  \          "      
echo "  |   :  : ,-+-. ;   , ||   |  .\ |  :  /\`. /         .'___,/    ,|   :     :        |  :  /\`. /|   :     :/  ;    '.   ,\`--.'\`|  ' ,\`--.'\`|  ' ,---.'   ;   :    \         "      
echo "  :   |  ',--.'|'   |  ;.   :  |: ;  |  |--\`          |    :     |.   |  ;. /        ;  |  |--\` .   |  ;. :  :       \  |   :  :  | |   :  :  | |   |   .|   | .\ :         "      
echo "  |   :  |   |  ,', |  '|   |   \ |  :  ;_            ;    |.';  ;.   ; /--\`         |  :  ;_   .   ; /--\`:  |   /\   \ :   |   \ | :   |   \ | :   :  |-.   : |: |         "      
echo "  '   '  |   | /  | |  ||   : .   /\  \    \`.         \`----'  |  |;   | ;             \  \    \`.;   | ;   |  :  ' ;.   :|   : '  '; |   : '  '; :   |  ;/|   |  \ :         "      
echo "  |   |  '   | :  | :  |;   | |\`-'  \`----.   \            '   :  ;|   : |              \`----.   |   : |   |  |  ;/  \   '   ' ;.    '   ' ;.    |   :   .|   : .  /         "      
echo "  '   :  ;   . |  ; |--'|   | ;     __ \  \  |            |   |  '.   | '___           __ \  \  .   | '___'  :  | \  \ ,|   | | \   |   | | \   |   |  |-;   | |  \         "      
echo "  |   |  |   : |  | ,   :   ' |    /  /\`--'  /            '   :  |'   ; : .'|         /  /\`--'  '   ; : .'|  |  '  '--' '   : |  ; .'   : |  ; .'   :  ;/|   | ;\  \        "      
echo "  '   :  |   : '  |/    :   : :   '--'.     /             ;   |.' '   | '/  :        '--'.     /'   | '/  |  :  :       |   | \`\`--' |   | \`\`--' |   |    :   ' | \.'        "      
echo "  ;   |.';   | |\`-'     |   | :     \`--'---'              '---'   |   :    /           \`--'---' |   :    /|  | ,'       '   : |     '   : |     |   :   .:   : :-'          "      
echo "  '---'  |   ;/         \`---'.|                                    \   \ .'                      \   \ .' \`--''         ;   |.'     ;   |.'     |   | ,' |   |.'            "      
echo "         '---'            \`---\`                                     \`---\`                         \`---\`                 '---'       '---'       \`----'   \`---'              "    
echo -e "${NC}"

#Script to download log file from bucket and search transaction ids from a file recursively

#functions used

consent_counter=0
readConsent() {
    local message="$1"
   echo -e "${YELLOW}${message}${NC}" >&2  #redirection to stderr neccessary due to command substitution.
    #if echo output is not redirected to stderr, it will be sent to stdout and whatever is sent to stdout will be captured by the variable calling
    #function. That's why redirect it to stderr or /dev/tty directly.


    while true; do
        # Prompt for input and ensure the message is shown in the same line
        read -n 1 -p "Press 'y' for Yes or 'n' for No: " consent
        echo >&2 # Add a new line after user input for better readability

        # Validate the input
        if [[ "$consent" =~ ^[YyNn]$ ]]; then
        	#here no redirection because we want to print it to stdout so that variable calling the method can store it.
            echo "$consent"  # Return the consent if valid
            break  # Exit the loop if valid input
        else
            ((consent_counter++))  # Increment the invalid attempt counter
            if [ "$consent_counter" -gt 2 ]; then
                echo -e "${RED}Number of invalid tries exceeded. Exiting the script.${NC}"
                #Here redirection not required anymore because the script encounters exit which immediately exits the scripts and echo message thus gets 
                #printed normally instead of getting stored in a variable.
                exit 1
            fi
            echo -e "${RED}Invalid input! Please enter 'y' or 'n'.${NC}" >&2
        fi
    done
}


# # Function to show spinning visual while downloading log files. 
# spin() {
#     local pid=$1
#     local delay=0.1
#     local spinchars="/-\\|"

#     #loop through the spinchars one by one and show the animation effect for progress wheel.
#     #/dev/null is used to supress the output of the ps command. 
#     while ps -p $pid > /dev/null; do
#         for ((i=0; i<${#spinchars}; i++)); do
#         	# \r=carriage return, it takes the cursor back to the start of the line so that character is overwritten.
#             printf "\r${spinchars:$i:1} Downloading..."
#             sleep $delay
#         done
#     done
#     printf "\r"  # Clear the spinner after the download is complete
# }


# # Download logs in parallel with dynamic job handling
# download_logs_in_parallel() {
#     echo -e "${GREEN}Fetching log files for txn date: $txn_date${NC}"
#     log_files=$(gsutil ls gs://<URL>/ | grep "$txn_date" | sort -t '.' -k5,5n)
#     total_files=$(echo "$log_files" | wc -l)
    
#     # Check if log files exist for the date
#     if [ "$total_files" -eq 0 ]; then
#         echo -e "${RED}No log files found for the specified date: $txn_date${NC}"
#         exit 1
#     fi
    
#     mkdir -p "$log_file_folder"
#     counter=0
#     jobs_running=0
#     max_parallel_jobs=10

#     for log_file in $log_files; do
#         echo -e "${BLUE}Downloading log file: $log_file ${NC}"
#         gsutil -q cp "$log_file" "$log_file_folder"/ &
#         ((jobs_running++))

#         if [ "$jobs_running" -ge "$max_parallel_jobs" ]; then
#             wait -n  # Wait for any one job to finish
#             jobs_running=$((jobs_running - 1))  # Decrement running job count
#         fi

#         ((counter++))
#         percentage=$((counter * 100 / total_files))
#         echo -e "${GREEN}Progress: $counter of $total_files files downloaded (${percentage}% completed)${NC}"
#     done

#     wait  # Wait for all remaining jobs to finish
#     echo -e "${GREEN}Download complete. All logs saved to $log_file_folder${NC}"
# }

# Temporary file to hold the jobs_running variable and progress
progress_file=$(mktemp)

# Initialize the progress file with jobs_running = 0
echo -e "0" > "$progress_file"  # jobs_running
echo -e "0" >> "$progress_file"  # download_counter

# Function to show spinning visual while downloads are in progress
spin() {
    local delay=0.1
    local spinchars="/-\\|"

    tput civis  # Hide cursor
    tput sc     # Save the cursor position
    while true; do
        jobs_running=$(sed -n '1p' "$progress_file")  # Read jobs_running from the file
        if [ "$jobs_running" -eq 0 ]; then
            break  # Exit the spinner loop when no jobs are running
        fi
        for ((i=0; i<${#spinchars}; i++)); do
            tput cup $(($(tput lines)-1))  # Move cursor to the last line
            printf "\r${spinchars:$i:1} Downloading..."
            sleep $delay
        done
    done
    tput rc     # Restore cursor position
    tput cnorm  # Restore cursor
    printf "\r"  # Clear the spinner after the download is complete
}

# Assuming these values are declared globally or outside the function
max_parallel_jobs=10


# Download logs in parallel with dynamic job handling
download_logs_in_parallel() {
    echo -e "${GREEN}Fetching log files for txn date: $txn_date${NC}"
    log_files=$(gsutil ls gs://<URL>/ | grep "$txn_date" | sort -t '.' -k5,5n)
    total_files=$(echo "$log_files" | wc -l)

    # Check if log files exist for the date
    if [ "$total_files" -eq 0 ]; then
        echo -e "${RED}No log files found for the specified date: $txn_date${NC}"
        exit 1
    fi

    mkdir -p "$log_file_folder"

    # Start the spinner in the background
    spin &

    for log_file in $log_files; do
        # Start downloading the file in the background
        {
            gsutil -q cp "$log_file" "$log_file_folder"/
            
            # Increment counter after each download finishes
            jobs_running=$(sed -n '1p' "$progress_file")
            download_counter=$(sed -n '2p' "$progress_file")
            download_counter=$((download_counter + 1))
            #echo "$jobs_running" > "$progress_file"  # Keep jobs_running unchanged
            sed -i "1s/.*/$jobs_running/" "$progress_file"
            #echo "$download_counter" >> "$progress_file"  # Update download_counter
            sed -i "2s/.*/$download_counter/" "$progress_file"
            percentage=$((download_counter * 100 / total_files))
            echo -e "${GREEN}Progress: $download_counter of $total_files files downloaded (${percentage}% completed)${NC}" >&2
            # Decrement running job count
            jobs_running=$(sed -n '1p' "$progress_file")
            jobs_running=$((jobs_running - 1))
            sed -i "1s/.*/$jobs_running/" "$progress_file"
        } &

        # Increment running job count
        jobs_running=$(sed -n '1p' "$progress_file")
        jobs_running=$((jobs_running + 1))
        sed -i "1s/.*/$jobs_running/" "$progress_file"

        if [ "$jobs_running" -ge "$max_parallel_jobs" ]; then
            wait -n  # Wait for any one job to finish before starting another
        fi
    done

    wait  # Wait for all remaining jobs to finish

    # Stop the spinner
    jobs_running=0
    sed -i "1s/.*/$jobs_running/" "$progress_file"  # Ensure the spinner exits

    # Final message after all downloads
    tput el  # Clear any spinner left behind
    echo -e "${GREEN}Download complete. All logs saved to $log_file_folder${NC}"

    rm "$progress_file"  # Clean up the temporary progress file
}


#function end


#script begin

# Download all the log files for that particular date
echo -e "${YELLOW}Please enter the date of transaction you are searching for. Enter date in this format: 2023-01-12${NC}"
read txn_date
echo
log_file_folder="imps_logs_$txn_date"
output_file="imps_output_$txn_date".txt

logs_already_present=0

if [ -f "$output_file" ]; then
	consent=$(readConsent "Truncating previous output file..")

	if [ "$consent" = "Y" ] || [ "$consent" = "y" ]; then
		> "$output_file"
	else
		echo -e "${RED}Exiting script, bye bye... (take backup of previous output file then run again)${NC}"
		echo
		exit 1
	fi
else
	touch "$output_file"
fi

echo

if [ -d "$log_file_folder" ]; then
    consent=$(readConsent "INFO: Logs are already present for the given date. Do you want to skip download then press 'y' or else if you want to continue with existing logs then press 'n'.")
    
    if [ "$consent" = "Y" ] || [ "$consent" = "y" ]; then
    	logs_already_present=1
    else
    	logs_already_present=0
	fi
fi

if [ "$logs_already_present" -eq 0 ]; then
	download_logs_in_parallel
fi
echo
log_files=$(find "$log_file_folder"/ -mindepth 1 -maxdepth 1)

# Path to the file containing transaction IDs
echo -e "${YELLOW}Enter the name of the file containing the ids. [Note: If you haven't uploaded the file yet, go back by pressing (CTRL+C) then upload it to home folder and run the script again.]${NC}"
echo -e "${BLUE}Here is a list of files available in the home directory:${NC}"
# prints only file names, handles names with spaces.
echo -e "${CYAN}"
find . -mindepth 1 -maxdepth 1 -exec basename {} \;
echo -e "${NC}"
read transaction_ids_file
echo

# Clean the txn_id file
sed -i 's/\r$//' "$transaction_ids_file"
awk '{$1=$1;print}' "$transaction_ids_file" > clean_transaction_ids_file

counter=0
total_count=$(wc -l < clean_transaction_ids_file)

echo -e "${GREEN}Found $total_count txns from the $transaction_ids_file file.${NC}"
echo

# Search logs for transactions
for log_file in $log_files; do
    echo -e "${BLUE}Searching for transactions in $log_file${NC}"
    
    # Use process substitution to avoid subshell issues
    while read -r match; do
        echo -e "${GREEN}txn found with id: $match in $log_file${NC}"
        echo "$match" >> "$output_file"
        # Increment the counter for each match found
        ((counter++))
    done < <(zgrep -F -o -m 1 -f clean_transaction_ids_file "$log_file" | sort | uniq)
    
done

echo
echo -e "${GREEN}Found $counter matching txn out of $total_count txns from the log files...${NC}"
echo
consent=$(readConsent "Removing log files now...")

if [ "$consent" = "Y" ] || [ "$consent" = "y" ]; then
	rm -rf "$log_file_folder"
	# Clean up temp file
	rm -f clean_transaction_ids_file "${download_progress_file}"
else
	# Clean up temp file
	rm -f clean_transaction_ids_file "${download_progress_file}"
	echo
	echo -e "${GREEN}Exiting script, bye bye...${NC}" 
	echo
	exit 1
fi

echo
echo -e "${GREEN}Exiting script, bye bye...${NC}"
echo
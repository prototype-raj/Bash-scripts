### bucket_parallel_download_search_tool.sh
- This script grabs the transaction ids from a txt file and accepts a date as parameter and then downloads all the log files from the google cloud bucket for that specific date and then in those files searches if the transaction ids grabbed earlier is present or not. The ids present in the file are exported in a separate txt file. 
  Visual animations and error handling are done.

### rdp_file_upload.ps1
- An attempt to automate uploading to RDP server using powershell script.

### java_war_deploy_automate.sh
- This script automates the process of deploying a java WAR file in tomcat server by
  1. Killing existing java process
  2. Cleanup of previous war files
  3. Download new file to be deployed
  4. Restart the tomcat server


 * Process to run any of the above files:
     - First copy the file to required directory
     - run `chmod +x file_name` to make the script executable
     - run the script using `sh file_name.sh`

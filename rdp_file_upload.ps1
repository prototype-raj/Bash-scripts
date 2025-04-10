# Define the local file path and the remote file path
$localFilePath = "<REPLACE_WITH_LOCALPATH"
$remoteUser = "<REPLACE_WITH_USERNAME>"
$remoteServer = "<REPLACE_WITH_IP>"
$remoteFilePath = "<REPLACE_WITH_URL>"

# Use SCP to upload the file
scp $localFilePath "${remoteUser}@${remoteServer}:${remoteFilePath}"

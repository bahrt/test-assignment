#!/bin/bash
#
# getimgs.sh downloads PNG files from a given URL to the provided output path
#
# Requirements:
#       - Lynx
#
# Supports:
#       - Basic Auth
#       - Redirection
#       - SSL/TLS sites
#
# ToDo:
#       - Use a separate function for error handling and logging
#       - Look for options that do not require Lynx
#       - Improve input validations
#       - Improve credentials handling
#

usage()
{
        echo "Usage: $0 [-u USERNAME] [-p PASSWORD ] -i INPUT_URL -o OUTPUT_PATH"
        echo
        echo "Downloads all PNG files from the given URL to OUTPUT_PATH directory."
        echo "Username and password parameters are supported for Basic Authentication."
        echo
}

# Use hard coded paths for Lynx and wget for security reasons
LYNX=/usr/bin/lynx
WGET=/usr/bin/wget

# Initialize creds var
use_credentials=0

# Read input parameters
while getopts "i:o:u:p:" OPTION
do
  case $OPTION in
    u)
        USERNAME=$OPTARG
        ;;
    p)
        PASSWORD=$OPTARG
        ;;
    i)
        INPUT_URL=$OPTARG
        ;;
    o)
        OUTPUT_PATH=$OPTARG
        ;;
    ?|*)
        usage
        exit
        ;;
  esac
done


# Validate input variables
if [ -z "$INPUT_URL" ] || [ -z "$OUTPUT_PATH" ]; then
    usage
    exit 1
fi

if [ ! -d "$OUTPUT_PATH" ]; then
    echo "ERROR: Invalid or inexistent output directory $OUTPUT_PATH supplied."
    exit 2
fi


# Check that Lynx is installed
if [ ! -f "$LYNX" ]; then
        echo "ERROR: This script needs Lynx installed on your system. You might need to adjust its path if it's already installed."
        exit 3
fi


# Check if URL is valid and PNG files exists there
chkfiles=$($LYNX -dump -listonly -image_links -nonumbers -auth=$USERNAME:$PASSWORD "$INPUT_URL" |grep -Ei '\.(png)$' | wc -l)
if [ -z $chkfiles ]; then
    echo "ERROR: Provided input URL is invalid."
    exit 4
elif [ $chkfiles -eq 0 ]; then
    echo "WARNING: The provided URL does not contain any PNG files. Exiting gracefully..."
    exit 0
elif [ $checkfiles -gt 0 ]; then
        $LYNX -dump -listonly -image_links -nonumbers -auth=$USERNAME:$PASSWORD "$INPUT_URL" |
        grep -Ei '\.(png)$' |
        tr '\n' '\000' |
        xargs -0 -- $WGET --http-user=$USERNAME --http-password=$PASSWORD -q --directory-prefix=$OUTPUT_PATH -- && echo "Done."
else
    echo "ERROR: An unexpected error happened while trying to retrieve the images."    
    exit 10
fi

# Unset credentials for security reasons
unset $USERNAME $PASSWORD

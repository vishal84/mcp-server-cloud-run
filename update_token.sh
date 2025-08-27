#!/bin/bash

# A script to fetch a new JWT token and update a JSON configuration file.

# --- Configuration ---
# The JSON file to be updated.
CONFIG_FILE="$HOME/.gemini/settings.json"

# --- Main Script Logic ---

# 1. Check if jq is installed, as it's required for safe JSON parsing.
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it to continue."
    echo "On Debian/Ubuntu: sudo apt-get install jq"
    echo "On macOS (Homebrew): brew install jq"
    exit 1
fi

# 2. Check if the configuration file exists.
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at '$CONFIG_FILE'"
    exit 1
fi

echo "Fetching new JWT token..."

# 3. *** IMPORTANT: Replace this line with your actual command to get the token. ***
# For example, if you are getting a Google Cloud identity token, it might be:
# ID_TOKEN=$(gcloud auth print-identity-token)
#
# For this template, we'll use a placeholder command.
ID_TOKEN=$(gcloud auth print-identity-token)

if [ -z "$ID_TOKEN" ]; then
    echo "Error: Failed to fetch a new token. The command returned an empty string."
    exit 1
fi

echo "Successfully fetched token. Updating $CONFIG_FILE..."

# 4. Use jq to update the JSON file.
# --arg safely passes the token variable into the jq script.
# This creates a new JSON object with the updated value.
# We save it to a temporary file first for safety.
jq --arg token "$ID_TOKEN" \
   '.mcpServers."zoo-remote".headers.Authorization = "Bearer \($token)"' \
   "$CONFIG_FILE" > "$CONFIG_FILE.tmp"

# 5. Check if jq command was successful before replacing the original file.
if [ $? -eq 0 ]; then
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    echo "Successfully updated token in $CONFIG_FILE."
else
    echo "Error: Failed to update JSON file with jq."
    # Clean up the temporary file on failure
    rm -f "$CONFIG_FILE.tmp"
    exit 1
fi


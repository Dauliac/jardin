#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# NOTE: https://github.com/jellyfin/jellyfin/discussions/7460

readonly URL="http://localhost:8096"
readonly CONFIG_PATH="/etc/configure-jellyfin"
readonly MOVIE_JSON_PATH="$CONFIG_PATH/movies.json"
readonly TV_SHOW_JSON_PATH="$CONFIG_PATH/tv_show.json"

load_json() {
    local json_file="$1"
    local json_data

    if ! json_data=$(<"$json_file"); then
        printf "Error: Failed to read JSON data from %s\n" "$json_file" >&2
        return 1
    fi

    printf "%s" "$json_data"
}

send_curl_request() {
    local endpoint="$1"
    local data="$2"

    if ! curl -sS --fail "$URL/$endpoint" --data-raw "$data"; then
        printf "Error: Failed to send request to %s\n" "$URL/$endpoint" >&2
        return 1
    fi
}

main() {
    local movie_json
    local tv_show_json
    source

    movie_json=$(load_json "$MOVIE_JSON_PATH") || return 1
    tv_show_json=$(load_json "$TV_SHOW_JSON_PATH") || return 1

    send_curl_request "Startup/Configuration" 'UICulture=en-US&MetadataCountryCode=US&PreferredMetadataLanguage=en' || return 1
    send_curl_request "Startup/User" "" || return 1
    send_curl_request "Startup/User" "Name=$JELLYFIN_ADMIN_USER&Password=$JELLYFIN_ADMIN_PASSWORD" || return 1
    send_curl_request "Library/VirtualFolders?collectionType=movies&refreshLibrary=false&name=Movies" "$movie_json" || return 1
    send_curl_request "Library/VirtualFolders?collectionType=tvshows&refreshLibrary=false&name=TV%20Shows" "$tv_show_json" || return 1
    send_curl_request "Startup/Configuration" 'UICulture=en-US&MetadataCountryCode=US&PreferredMetadataLanguage=en' || return 1
    send_curl_request "Startup/RemoteAccess" 'EnableRemoteAccess=true&EnableAutomaticPortMapping=false' || return 1
    send_curl_request "Startup/Complete" "" || return 1
}

main "$@"

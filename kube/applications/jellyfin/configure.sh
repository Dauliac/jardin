#!/usr/bin/env bash

set -o errexit
# set -o pipefail
set -o nounset

# NOTE: https://github.com/jellyfin/jellyfin/discussions/7460

readonly URL="http://jellyfin.applications.svc.cluster.local:8096"
readonly CONFIG_PATH="/etc/configure-jellyfin"
readonly MOVIE_JSON_PATH="$CONFIG_PATH/movies.json"
# readonly TV_SHOW_JSON_PATH="$CONFIG_PATH/tv_show.json"

load_json() {
  local json_file="$1"
  local json_data

  if ! json_data=$(<"$json_file"); then
    printf "Error: Failed to read JSON data from %s\n" "$json_file" >&2
    return 1
  fi

  printf "%s" "$json_data"
}

send_curl_request_post() {
  local endpoint="$1"
  local data="$2"

  if ! curl -sS --fail "$URL$endpoint" --data-raw "$data" -H "Content-Type: application/json"; then
    printf "Error: Failed to send request to %s\n" "$URL$endpoint" >&2
    return 1
  fi
}

send_curl_request_get() {
  local endpoint="$1"

  if ! curl -sS --fail "$URL$endpoint" -H "Content-Type: application/json"; then
    printf "Error: Failed to send request to %s\n" "$URL$endpoint" >&2
    return 1
  fi
}

# Add retry until function
retry_until_up() {
  local -r -i max_attempts="100"
  local -r -i sleep_interval="1"
  local -i attempt_num=1
  until send_curl_request_get "/"; do
    if ((attempt_num == max_attempts)); then
      echo "Max attempts reached"
      return 1
    else
      echo "Retrying, attempt $((attempt_num++))"
      sleep $sleep_interval
    fi
  done
}

main() {
  local movie_json
  # TODO: implement it for tv show
  # local tv_show_json

  movie_json=$(load_json "$MOVIE_JSON_PATH") || return 1
  # tv_show_json=$(load_json "$TV_SHOW_JSON_PATH") || return 1

  retry_until_up

  send_curl_request_post "/Startup/Configuration" '{"UICulture":"en-US","MetadataCountryCode":"US","PreferredMetadataLanguage":"en"}' || return 1
  send_curl_request_get "/Startup/User"
  send_curl_request_post "/Startup/User" "{\"Name\":\"$JELLYFIN_ADMIN_USER\",\"Password\": \"$JELLYFIN_ADMIN_PASSWORD\"}" || return 1
  send_curl_request_post "/Library/VirtualFolders?collectionType=movies&refreshLibrary=false&name=Movies" "$movie_json" || return 1
  # TODO: implement TV Show configuration
  # send_curl_request "/Library/VirtualFolders?collectionType=tvshows&refreshLibrary=false&name=TV%20Shows" "$tv_show_json" || return 1
  send_curl_request_post "/Startup/RemoteAccess" '{"EnableRemoteAccess":true,"EnableAutomaticPortMapping":false}' || return 1
  send_curl_request_post "/Startup/Complete" "" || return 1
}

main "$@"

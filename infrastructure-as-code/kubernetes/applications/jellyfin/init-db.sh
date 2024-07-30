#!/bin/sh
set -e
set -x

WORKDIR="/tmp/auth"
DATABASE_PATH="$WORKDIR/authentication.db"

# TODO: build container with all packages in
apk update
apk add sqlite

CURRENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

rm -rf "$WORKDIR/*"

sqlite3 $DATABASE_PATH <<EOF
CREATE TABLE IF NOT EXISTS Devices (
    Id TEXT NOT NULL PRIMARY KEY,
    CustomName TEXT,
    Capabilities TEXT
);
CREATE INDEX IF NOT EXISTS Devices1 on Devices (Id);

CREATE TABLE IF NOT EXISTS Tokens (
    Id INTEGER PRIMARY KEY,
    AccessToken TEXT NOT NULL,
    DeviceId TEXT NOT NULL,
    AppName TEXT NOT NULL,
    AppVersion TEXT NOT NULL,
    DeviceName TEXT NOT NULL,
    UserId TEXT,
    UserName TEXT,
    IsActive BIT NOT NULL,
    DateCreated DATETIME NOT NULL,
    DateLastActivity DATETIME NOT NULL
);
CREATE INDEX IF NOT EXISTS Tokens3 on Tokens (AccessToken, DateLastActivity);
CREATE INDEX IF NOT EXISTS Tokens4 on Tokens (Id, DateLastActivity);

INSERT INTO Tokens (Id, AccessToken, DeviceId, AppName, AppVersion, DeviceName, UserId, UserName, IsActive, DateCreated, DateLastActivity)
VALUES
(1, '3990b1d68e1a4da294ebe0f144f1348a', 'TW96aWxsYS81LjAgKFgxMTsgTGludXggeDg2XzY0OyBydjoxMjguMCkgR2Vja28vMjAxMDAxMDEgRmlyZWZveC8xMjguMHwxNzIxNjg5MzcxMTkx', 'Admin', '10.7.6', 'Admin', '68f77ff3b5e64cef8293d2b3453ec920', 'admin', 1, '$CURRENT_TIMESTAMP', '$CURRENT_TIMESTAMP'),
(2, '$JELLYFIN_SERVICES_TOKEN', 'c4c864def4ac4a3fbe6b1348dfaa5357', 'services', '10.7.7', 'jellyfin-app', NULL, NULL, 1, '$CURRENT_TIMESTAMP', '0001-01-01 00:00:00Z');
EOF

echo "Database initialized successfully"

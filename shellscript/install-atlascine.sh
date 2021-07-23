#!/bin/bash
#
# This script will install Atlascine on a vanilla install of Ubuntu 18.04
# 
#
# REFERENCES:
#   - https://github.com/GCRC/nunaliit/wiki/Nunaliit-Documentation-for-Developers
#   - https://github.com/GCRC/nunaliit/wiki/Nunaliit-Documentation-for-Atlas-Builders
#   - https://github.com/GCRC/nunaliit_tutorial/wiki
#


#############################################################
##
## CONFIGURATION - IMPORT FROM SEPARATE CONFIG FILE
##
#############################################################

# Config file should be located in same directory as this script
SCRIPT_FOLDER="$(dirname $0)"
if [ ! -f "$SCRIPT_FOLDER/config.sh" ]; then
    echo "ERROR: need to create config.sh for your environment"
    exit 1
fi
. "$SCRIPT_FOLDER/config.sh"


#############################################################
##
## USEFUL DEFINITIONS
##
## Single place to define important commands, small helper
## functions, etc.
##
#############################################################

APT="apt-get -y -q"

## Quit with an err msg, like Perl in the good old days
function die()
{
    echo "ERROR1 - $*" >&2
    exit 1
}

## Quit if command returns non-zero exit
set -e

############################################################
#
# A. INSTALL PREREQUISITES
#
############################################################

## Setup couchdb apt repository
curl https://couchdb.apache.org/repo/keys.asc | gpg --dearmor > /usr/share/keyrings/couchdb-archive-keyring.gpg || die "couchdb apt key installation failed"
echo "deb [signed-by=/usr/share/keyrings/couchdb-archive-keyring.gpg] https://apache.jfrog.io/artifactory/couchdb-deb/ bionic main" > /etc/apt/sources.list.d/couchdb.list || die "couchdb apt repo setup failed"

## Update server packages
$APT update || die "apt update failed"
$APT full-upgrade || die "apt upgrade failed"

## Install misc. packages
echo "Configuring prerequisite packages"   # die() causes debconf-set-selections to hang
debconf-set-selections <<EOF
ttf-mscorefonts-installer       msttcorefonts/accepted-mscorefonts-eula boolean true
EOF
# Java must be installed first, or else other pkgs pull in openjdk-11
$APT install apt-transport-https curl openjdk-8-jdk-headless || die "could not install prerequisite packages (1/2)"
$APT install imagemagick ffmpeg ubuntu-restricted-extras maven ant || die "could not install prerequisite packages (2/2)"
sed -i 's/^assistive_technologies=/#assistive_technologies=/' /etc/java-8-openjdk/accessibility.properties || die "could not configure java 8"

## Expect is only used in this script to automate 'nunaliit config'
$APT install expect || die "could not install prerequisite packages"

## Install couchdb
echo "Configuring couchdb"   # die() causes debconf-set-selections to hang
debconf-set-selections <<EOF
couchdb couchdb/adminpass_again password $COUCHDB_PASS
couchdb couchdb/adminpass password $COUCHDB_PASS
couchdb couchdb/bindaddress string 0.0.0.0
couchdb couchdb/mode select standalone
EOF
$APT install couchdb=2.3.1~bionic || die "Could not install couchdb"
apt-mark hold couchdb || die "could not hold couchdb at specific version"


#############################################################
##
## B. DOWNLOAD AND BUILD NUNALIIT
##
#############################################################

## Get Nunaliit source code
mkdir -p "$BASE_FOLDER" || die "Could not create directory BASE_FOLDER='$BASE_FOLDER'"
git clone https://github.com/GCRC/nunaliit.git "$SOURCE_FOLDER" || die "could not download nunaliit"
cd "$SOURCE_FOLDER" || die "SOURCE_FOLDER='$SOURCE_FOLDER' not found"
git checkout $NUNALIIT_BRANCH || die "Could not find Nunaliit branch: NUNALIIT_BRANCH='$NUNALIIT_BRANCH'"

## Build Nunaliit source code
#
# BUG: Nunaliit build (maven's installatino of project dependencies)
# cannot run as root.  I believe it is due to this bug:
#      https://github.com/npm/cli/issues/624
# so switch to a non-root user for the Nunaliit build:
chown -R $USER_BUILD_NUNALIIT "$SOURCE_FOLDER" || die "Could not set source ownership to USER_BUILD_NUNALIIT=$USER_BUILD_NUNALIIT"
su $USER_BUILD_NUNALIIT -c "mvn clean install" || die "Failed to build Nunaliit from source code"

## Unpack Nunaliit binaries
cd "$BASE_FOLDER"
tar zxvf "$SOURCE_FOLDER"/nunaliit2-couch-sdk/target/nunaliit_*.tar.gz  || die "Could not open Nunaliit"

## Optionally install nunaliit command on the system PATH
NUNALIIT="$BASE_FOLDER"/nunaliit_*/bin/nunaliit
if [ "$USE_BINDIR" -ne 0 ]; then
    if [ ! -e "$BINDIR/nunaliit" ]; then
        ln -s $NUNALIIT "$BINDIR" || die "Could not setup shortcut to nunaliit command"
    fi
    NUNALIIT="$BINDIR/nunaliit"
fi


#############################################################
##
## C. INSTALL ATLAS TEMPLATE
##
#############################################################

## Get Atlas template
git clone https://$GCRC_GITLAB_USER:$GCRC_GITLAB_PASS@gitlab.gcrc.carleton.ca/Atlascine/atlas-template.git "$ATLAS_FOLDER" || die "could not download Atlas templates to ATLAS_FOLDER='$ATLAS_FOLDER'"
cd "$ATLAS_FOLDER"
git checkout $ATLAS_TEMPLATE_BRANCH || die "Could not find atlas branch ATLAS_TEMPLATE_BRANCH='$ATLAS_TEMPLATE_BRANCH'"

## Configure Nunaliit
#
# This java code is interactive only - no built-in option to script
# it.  So I use an expect 'macro' to hack in automation
cd "$ATLAS_FOLDER"
expect <<EOF
spawn $NUNALIIT config
expect "Enter the name of the atlas" { send "$ATLAS_NAME\n" }
expect "Enter the URL to CouchDB" { send "\n" }
expect "Enter the name of the main database" { send "$DB_NAME\n" }
expect "manually verify each document submission?" { send "Y\n" }
expect "name of the database where submissions will be uploaded" { send "$DB_SUBMISSION_NAME\n" }
expect "admin user for CouchDB" { send "\n" }
expect "password for the admin user" { send "$COUCHDB_PASS\n" }
expect "port where the atlas is served" { send "\n" }
expect "Google Map API key" { send "\n" }
interact
EOF

$NUNALIIT update || die "failed to update Nunaliit atlas"


############################################################
#
# D. Import Existing Data (optional)
#
############################################################

if [ "$RESTORE_EXISTING_DB" -ne 0 ]; then
    mkdir -p $DUMP_FOLDER || die "Could not create folder DUMP_FOLDER='$DUMP_FOLDER'"
    cd $DUMP_FOLDER
    tar zxf $DUMP_FILE || die "Could not unpack DUMP_FILE='$DUMP_FILE'"
    # I don't know whether this is helpful. Found it here:
    # https://github.com/GCRC/nunaliit/issues/862
    export JAVA_OPTS="-Xmx6g"
    cd $ATLAS_FOLDER
    "$NUNALIIT" restore --dump-dir "$DUMP_FOLDER/$UNPACKED_DUMP_NAME" || die "Failed to restore atlas from dump file"
fi


############################################################
#
# E. CONFIGURE SERVICE TO RUN AT BOOT
#
############################################################

# sudo cp extra/nunaliit-rwanda.service  /etc/systemd/system/
# ##nano /etc/systemd/system/nunaliit-rwanda.service
# # In future, run as a non-root user?
# systemctl enable nunaliit-home
# systemctl start nunaliit-home

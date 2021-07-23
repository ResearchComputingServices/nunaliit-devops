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


############################################################
#
# CONFIGURATION - IMPORT FROM SEPARATE CONFIG FILE
#
############################################################

# Config file should be located in same directory as this script
SCRIPT_FOLDER="$(dirname $0)"
if [ ! -f "$SCRIPT_FOLDER/config.sh" ]; then
    echo "ERROR: need to create config.sh for your environment"
    pwd
    exit 1
fi
. "$SCRIPT_FOLDER/config.sh"


############################################################
#
# USEFUL DEFINITIONS
#
# Single place to define important commands, small helper
# functions, etc.
#
############################################################

APT="apt-get -y"


############################################################
#
# A. INSTALL PREREQUISITES
#
############################################################

curl https://couchdb.apache.org/repo/keys.asc | gpg --dearmor > /usr/share/keyrings/couchdb-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/couchdb-archive-keyring.gpg] https://apache.jfrog.io/artifactory/couchdb-deb/ bionic main" > /etc/apt/sources.list.d/couchdb.list
$APT update
$APT full-upgrade
$APT install apt-transport-https curl
$APT install openjdk-8-jdk-headless
debconf-set-selections <<EOF
couchdb couchdb/adminpass_again password $COUCHDB_PASS
couchdb couchdb/adminpass password $COUCHDB_PASS
couchdb couchdb/bindaddress string 0.0.0.0
couchdb couchdb/mode select standalone
EOF
$APT install couchdb=2.3.1~bionic
apt-mark hold couchdb
debconf-set-selections <<EOF
ttf-mscorefonts-installer       msttcorefonts/accepted-mscorefonts-eula boolean true
EOF
$APT install imagemagick ffmpeg ubuntu-restricted-extras maven ant
sed -i 's/^assistive_technologies=/#assistive_technologies=/' /etc/java-8-openjdk/accessibility.properties


############################################################
#
# B. DOWNLOAD AND BUILD NUNALIIT
#
############################################################

mkdir -p "$BASE_FOLDER"
git clone https://github.com/GCRC/nunaliit.git "$SOURCE_FOLDER"
cd "$SOURCE_FOLDER"
git checkout $NUNALIIT_BRANCH

# BUG: Nunaliit build (maven's installatino of project dependencies)
# cannot run as root.  I believe it is due to this bug:
#      https://github.com/npm/cli/issues/624
# so switch to a non-root user for the Nunaliit build:
chown -R $USER_BUILD_NUNALIIT "$SOURCE_FOLDER"
su $USER_BUILD_NUNALIIT -c "mvn clean install"

cd "$BASE_FOLDER"
tar zxvf "$SOURCE_FOLDER"/nunaliit2-couch-sdk/target//nunaliit_*.tar.gz

NUNALIIT="$BASE_FOLDER"/nunaliit_*/bin/nunaliit
if [ $USE_BINDIR -ne 0 ]; then
    # Optionally install nunaliit command
    cp $NUNALIIT "$BINDIR"
    NUNALIIT="$BINDIR/nunaliit"
fi


# ############################################################
# #
# # C. INSTALL ATLAS TEMPLATE
# #
# ############################################################

# git clone https://gitlab.gcrc.carleton.ca/Atlascine/atlas-template.git "$ATLAS_FOLDER"
# cd "$ATLAS_FOLDER"
# git checkout $ATLAS_TEMPLATE_BRANCH

# # This java code is interactive only - no built-in option to script
# # it.  I will try using expect to automatic the configuration
# ## /atlascine/nunaliit_2.2.9-SNAPSHOT_2021-02-08_8f3c4c8/bin/nunaliit config

# ##$HOME/nunaliit_2.2.9-SNAPSHOT_2021-02-08_8f3c4c8/bin/nunaliit update


# ############################################################
# #
# # D. Import Existing Data
# #
# ############################################################

# cd $DUMP_FOLDER
# tar zxf $DUMP_FILE
# # I don't know whether this is helpful. Found it here:
# # https://github.com/GCRC/nunaliit/issues/862
# export JAVA_OPTS="-Xmx6g"
# cd $ATLAS_FOLDER
# "$NUNALIIT" restore --dump-dir "$DUMP_FOLDER/$UNPACKED_DUMP_NAME"


# ############################################################
# #
# # E. CONFIGURE SERVICE TO RUN AT BOOT
# #
# ############################################################

# # sudo cp extra/nunaliit-rwanda.service  /etc/systemd/system/
# # ##nano /etc/systemd/system/nunaliit-rwanda.service
# # # In future, run as a non-root user?
# # systemctl enable nunaliit-home
# # systemctl start nunaliit-home

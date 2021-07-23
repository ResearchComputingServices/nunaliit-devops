############################################################
#
# CONFIGURATION FOR INSTALL ATLASCINE
#
# config_EXAMPLE.sh shows what settings you can put in your own
# config.sh.  You may need to customize some settings for your
# environment.
#
############################################################

COUCHDB_PASS="your_password_here"
NUNALIIT_BRANCH="branch-for-atlascine"
ATLAS_TEMPLATE_BRANCH="rwanda"

BASE_FOLDER="/atlascine"
ATLAS_FOLDER="$BASE_FOLDER/rwanda"
SOURCE_FOLDER="$BASE_FOLDER/nunaliit_source"

RESTORE_EXISTING_DB=1
DUMP_FOLDER="$BASE_FOLDER/dumps"
# Restore this dump if RESTORE_EXISTING_DB=1
DUMP_FILE="/vagrant/rwanda-atlas_dump_2021-03-10.tar.gz"
UNPACKED_DUMP_NAME=dump_2021-03-10_16:37:24

# Optionally put nunaliit command in a convenient location (e.g on
# search PATH) to make it easy to run from the command-line
USE_BINDIR=1
BINDIR="/usr/local/bin"

# mvn install for the Nunaliit build cannot run as root.  I believe it
# is due to this bug:
#    https://github.com/npm/cli/issues/624
# so as a workaround, we switch to this user for building Nunaliit.
# Change to some appropriate account on your system:
USER_BUILD_NUNALIIT="ubuntu"

GCRC_GITLAB_USER=""
GCRC_GITLAB_PASS=""

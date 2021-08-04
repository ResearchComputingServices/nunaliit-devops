#############################################################
##
## CONFIGURATION FOR INSTALL ATLASCINE
##
## config_EXAMPLE.sh shows what settings you can put in your own
## config.sh.  You will need to customize some settings for your
## environment.
##
## You should pay particular attention to the
## following settings:
##   - USER_BUILD_NUNALIIT
##   - GCRC_GITLAB_USER/GCRC_GITLAB_PASS
##   - COUCHDB_PASS
##   - DB_NAME/DB_SUBMISSION_NAME
##   - ATLAS_NAME
##   - ATLAS_TEMPLATE_BRANCH
##   - ATLAS_FOLDER
#############################################################


##############################################
##
## UBUNTU USER ACCOUNT
##
##############################################
# mvn install for the Nunaliit build cannot run as root.  I believe it
# is due to this bug:
#    https://github.com/npm/cli/issues/624
# so as a workaround, we switch to this user for building Nunaliit.
# Change to some appropriate account on your system:
USER_BUILD_NUNALIIT="ubuntu"


##############################################
##
## NUNALIIT SOURCE CODE
##
##############################################
NUNALIIT_BRANCH="branch-for-atlascine"                              # Branch of Nunaliit to use for Atlascine install


##############################################
##
## COUCHDB DATABASE
##
##############################################
COUCHDB_PASS="your_password_here"                                   # Will set couchdb and your Atlas to use this db password
DB_NAME="rwanda"                                                    # Database name for your Atlas
DB_SUBMISSION_NAME="rwandasubmissions"                              # Submission database name


##############################################
##
## ATLAS SETTINGS
##
##############################################
GCRC_GITLAB_USER=""                                                 # User account at https://gitlab.gcrc.carleton.ca, to download Atlas
GCRC_GITLAB_PASS=""                                                 # Corresponding password at https://gitlab.gcrc.carleton.ca
ATLAS_NAME="rwanda"                                                 # Name to call this Atlas installation
ATLAS_TEMPLATE_BRANCH="rwanda"                                      # gitlab atlas template branch to use for this Atlas
URL_PORT="8080"                                                     # Network port for atlas


##############################################
##
## TARGET DIRECTORIES
##
##############################################
BASE_FOLDER="/atlascine"                                            # I put everything in here
ATLAS_FOLDER="$BASE_FOLDER/rwanda"                                  # Location to install atlas
SOURCE_FOLDER="$BASE_FOLDER/nunaliit_source"                        # location to download nunaliit source code
DUMP_FOLDER="$BASE_FOLDER/dumps"                                    # If you restor a dump, it will be unpacked in here
BINDIR="/usr/local/bin"                                             # Put a shortcut to nunaliit command here, so it is easier to run


##############################################
##
## RESTORE EXISTING ATLAS
##
##############################################
#
# If you have a dump file from an existing atlas, you can
# use the following settings to restore it
RESTORE_EXISTING_DB=0                                               # 0=skip atlas restore   1=do atlas restore
# Restore this dump if RESTORE_EXISTING_DB=1
DUMP_FILE="/home/ubuntu/rwanda-atlas_dump_2021-03-10.tar.gz"        # If restore enable, restore from this dump file
UNPACKED_DUMP_NAME="dump_2021-03-10_16:37:24"                       # Name of folder inside your dump file

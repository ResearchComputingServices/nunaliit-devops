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
#
# TODO:
#   1. Is there a better way to customize the install, rather than
#      modifying hard-coded variables values in the configuration
#      section?
#
#   2. Figure out a way to bail out gracefully (ideally with a
#      meaningful error message) if a command in the script fails.
#      Could do "set -e", or perhaps have code at the end of each
#      section checking the state of the environment before
#      proceeding?
#
#   3. Move these TODO items into Github, and give myself a warm
#      welcome into the 21st century!  You mean not everything
#      can be done in plain text?!?!  ;-)


############################################################
#
# CONFIGURATION - MODIFY THESE VARIABLES FOR YOUR INSTALL
#
# You shouldn't need to change anything past this
# configuration section
#
# TODO: is there a better way to customize the install,
#       rather than modifying this shell script directly?
#
############################################################




############################################################
#
# USEFUL DEFINITIONS
#
# Single point to define commands that might need to change,
# small helper functions, etc.
#
############################################################

APT="apt-get -y"



############################################################
#
# A. INSTALL PREREQUISITES
#
############################################################


# AHH! This bintray apt repo doesn't seem to work! Is that temporary,
# or is it gone?  If it is gone, is there another location to grab old
# deb packages for couchdb?
echo "deb https://apache.bintray.com/couchdb-deb bionic main" > /etc/apt/sources.list.d/couchdb.list
$APT update
$APT full-upgrade
$APT install openjdk-8-jdk-headless apt-transport-https curl
$APT install -y couchdb=2.3.1~bionic

############################################################
#
# B. DOWNLOAD AND BUILD NUNALIIT
#
############################################################


############################################################
#
# C. INSTALL ATLAS TEMPLATE
#
############################################################



############################################################
#
# D. INSTALL ATLAS TEMPLATE
#
############################################################


############################################################
#
# E. CONFIGURE SERVICE TO RUN AT BOOT
#
############################################################



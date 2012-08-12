#!/bin/sh

# Freeswitch Debian Installer
# Author: Brian Foster (with help from the FreeSWITCH wiki and mailing lists)
# Version 0.0.4
# This installer is known to work with Debian 6.0/Squeeze. It is not tested
# for any other Debian version or Debian-based distro, although it could work...

# Questions, Comments, Concerns? Email freeswitch-installer@endigotech.com

# ================================================================================
# Licensed under the Endigo Plain Language OS License v0.0.1 (EPLOS License)
# Below serves as your copy of the license (it's really simple).
# 	This software can be used by anyone for personal or commercial use.
#	Our only requests are as follows:
#	1) Please keep the lines naming the project, version, author, and contact
#	information.
#	2) If you decide to change this piece of software, it's strongly
#	recommended that you send the patch to the author, as it may be potentially
#	useful for others.
#	3) If you use this piece of software for another open source project or
#	commercial uses, we'd like to hear about it. Makes us feel all warm and
#	fuzzy inside, ya know?
# =================================================================================


# ==User Settings==================================================================

# Update/Upgrade System at install time (Default: true; Options: true, false)
UPDATE_SYS="true"

# Packages to install
PKGS="git-core build-essential autoconf automake libtool libncurses5 libncurses5-dev make libjpeg-dev \
        pkg-config unixodbc unixodbc-dev libcurl4-openssl-dev libexpat1-dev libgnutls-dev libtiff4-dev \
	libx11-dev unixodbc-dev libssl-dev python2.6-dev zlib1g-dev libzrtpcpp-dev libasound2-dev \
	libogg-dev libvorbis-dev libperl-dev libgdbm-dev libdb-dev python-dev uuid-dev bison"

# FreeSWITCH Git Repo (Default: git://git.freeswitch.org/freeswitch.git)
FS_GIT="git://git.freeswitch.org/freeswitch.git"

# FreeSWITCH Git Branch (Default: v1.2.stable)
FS_GIT_BRANCH="v1.2.stable"

# Source Folder (Default: /usr/local/src/)
SRC_FLDR="/usr/local/src/"

# Manually select modules (Default: false; Options: true, false)
MANUALLY_SELECT_MODULES="false"

# Sounds Install (Default: cd; Options: cd-sounds-install, uhd-sounds-install, hd-sounds-install, sounds-install, false)
SOUNDS="false"

# Music On Hold Install (MOH) (Default: cd; Options: cd-moh-install, uhd-moh-install, hd-moh-install, sounds-install, false)
MOH="false"

# FreeSWITCH User/Group (Default: freeswitch:daemon)
FS_USER="freeswitch"
FS_GROUP="daemon"

# FreeSWITCH Init Script Install (Default: true; Options; true, false)
INSTALL_FS_INIT="false"

# FreeSWICH Init Script Location (Default: http://files.endigovoip.com/freeswitch/resources/freeswitch_init.sh)
FS_INIT_LOC="http://files.endigovoip.com/freeswitch/resources/freeswitch_init.sh"

# Freeswitch Backup-to Location (Default: fs-conf-backup.tar.gz, can be any path but currently has to be tar.gz)
BACKUP_FS_CONFIGS_LOC="fs-conf-backup.tar.gz"

# ==Script Variables=================================================================
# Do not change these unless you know what you are doing!
FUNCTION="$1"
SKIP_FS_BOOTSTRAP="false"
SKIP_FS_CONFIGURE="false"
SKIP_FS_MAKE="false"

# Alright, let's get started!
clear|reset

# Making sure we are running this script as root
if [ "$USER" != "root" ]
  then
    echo "Please re-run this script as 'root'. Otherwise, we can't do a proper install of FreeSWITCH and it's dependencies."
    exit
  else
    echo "We are running as 'root'..."
  fi

# Update FreeSWITCH
if [ "$FUNCTION" = "update-fs" ]
  then
    echo "Updating FreeSWITCH, press CTRL-C to cancel..."
    sleep 5s
    service freeswitch stop
    cd $SRC_FLDR
    cd freeswitch/
    make current
    echo "FreeSWITCH update complete!"
    exit
  fi

# Rebootstrap/Reconfigure then update FreeSWITCH

if [ "$FUNCTION" = "update-fs-alt" ]
  then
    echo "Rebootstrap/Reconfigure, then Updating FreeSWITCH"
    echo "press CTRL-C to cancel..."
    sleep 5s
    service freeswitch stop
    cd $SRC_FLDR
    cd freeswitch/
    ./bootstrap.sh -j
    ./configure -C
    touch noreg
    make current
    exit
  fi



# Backup FreeSWITCH Configs
if [ "$FUNCTION" = "backup-fs-configs" ]
  then
    echo "Backing up everything under /.../conf/ to ${BACKUP_FS_CONFIGS_LOC}..."
    tar -pczf $BACKUP_FS_CONFIGS_LOC /usr/local/freeswitch/conf/
    echo "Backup Complete! Take a look at '${BACKUP_FS_CONFIGS_LOC}'."
    exit
  fi

# Remove FreeSWITCH Entirely
if [ "$FUNCTION" = "remove-fs" ]
  then
    echo "We are about to remove FreeSWITCH. Please make sure that you have completely"
    echo "backed up everything you need FreeSWITCH related. This command deletes"
    echo "EVERYTHING under /usr/local/freeswitch and ${SRC_FLDR}. You can backup"
    echo "your configuration files automatically by running:"
    echo
    echo "./fs-debian-installer backup-fs-configs"
    echo
    echo "IF YOU DON'T WANT TO REMOVE FREESWITCH, PRESS CTRL-C NOW!"
    echo "I'm giving you 15 seconds to do this..."
    sleep 15s
    echo "OK, commencing FreeSWITCH removal!"
    sleep 5s
    echo "Shutting Down FS (if using init script)"
    service freeswitch stop
    echo "Removing Source Folder..."
    rm -r $SRC_FLDR
    echo "Removing /usr/local/freeswitch..."
    rm -r /usr/local/freeswitch
    echo "FreeSWITCH has been removed."
    exit
  fi

# Update/Upgrade System

if [ "$UPDATE_SYS" = "true" ]
  then
    echo "Updating System..."
    apt-get update
    apt-get upgrade
    echo "System Update Complete!"
  fi

# Installing Prerequisite Packages
echo "Installing Required Packages via apt-get..."
apt-get install $PKGS

# Download FreeSWITCH from git
echo "Now Downloading FreeSWITCH Source..."
cd $SRC_FLDR
git clone $FS_GIT
cd freeswitch
echo "Switching to ${FS_GIT_BRANCH} branch of ${FS_GIT}"
git checkout $FS_GIT_BRANCH

# Change Directory and run bootstrap
if [ "$SKIP_FS_BOOTSTRAP" = "true" ]
  then
    echo "Skipping Bootstrap..."
  else
    echo "Running Bootstrap..."
    ./bootstrap.sh -j
  fi

# Select Modules

if [ "$MANUALLY_SELECT_MODULES" = "true" ]
  then
    echo "I'm going to pull up nano, a nice command line editor, so you can pick"
    echo "and choose the modules that will be installed. Please make sure you"
    echo "consult wiki.freeswitch.org if you don't know what to do here."
    echo "Recommended modules are already uncommented. Make sure that when you"
    echo "close nano that you save it as modules.conf."
    sleep 7s
    apt-get install nano
    nano modules.conf
    echo "Thanks, we're all set here."
  fi

# Run Configure
if [ "$SKIP_FS_CONFIGURE" = "true" ]
  then
    echo "Skipping Configure."
  else
    echo "Running Configure..."
    ./configure -C
  fi


# Start Build Process
if [ "$SKIP_FS_MAKE" = "true" ]
  then
    echo "Skipping FreeSWITCH Make Process."
  else
    echo "Now Compiling FreeSWITCH..."
    make
    make all install
  fi

if [ "$SOUNDS" = "false" ]
  then
    echo "Not installing standard sound files"
  else
    echo "Installing Stock Sounds..."
    make $SOUNDS
  fi

if [ "$MOH" = "false" ]
  then
    echo "Not Installing Standard Music on Hold (MOH) files..."
  else
    echo "Installing Standard Music on Hold (MOH) files..."
    make $MOH
  fi

# Create a user for FreeSWITCH to use
if id $FS_USER >/dev/null 2>&1
  then
    echo "User '${FS_USER}' already exists."
  else
    echo "Adding user '${FS_USER} to group '${FS_GROUP}'..."
    adduser --disabled-password  --quiet --system --home /usr/local/freeswitch --gecos "FreeSWITCH Voice Platform" --ingroup $FS_GROUP $FS_USER
  fi

# Set Permissions for /usr/local/freeswitch
chown -R $FS_USER:$FS_GROUP /usr/local/freeswitch/
chmod -R o-rwx /usr/local/freeswitch/

# Download the init script
if [ "$INSTALL_FS_INIT" = "true" ]
  then
    echo "Downloading Init Script from ${FS_INIT_LOC}..."
    wget $FS_INIT_LOC -O /etc/init.d/freeswitch
    echo "Installing Init Script to /etc/init.d/freeswitch..."
    chmod +x /etc/init.d/freeswitch
    update-rc.d freeswitch defaults
  else
    echo "Not installing the FreeSWITCH Init Script..."
  fi

# Make fs_cli a system command
echo "Linking fs_cli to /usr/bin/fs_cli"
ln -sf  /usr/local/freeswitch/bin/fs_cli /usr/bin/fs_cli


# User Quick Start guide
echo
echo
echo
echo "========================================================================="
echo "FreeSWITCH is now installed!"
echo
echo
echo "To start FS, type 'service freeswitch start'"
echo "Log into CLI, type 'fs_cli'"
echo "Base Directory: /usr/local/freeswitch"
echo "User Directory: /../conf/directory/default"
echo "Inbound Routes: /../conf/dialplan/public"
echo "Default Context Dialplans: /../conf/dialplan/default.xml"
echo "Set your gateways in /../conf/sip_profiles/external"
echo
echo "To learn more about how to handle FreeSWITCH, see wiki.freeswitch.org, AND"
echo "IRC help is always available at #freeswitch on the Freenode network, AND"
echo "Check out the mailing lists... lists.freeswitch.org."
echo "Don't forget to register for ClueCon this August, see cluecon.com"
echo
echo "Welcome to the FreeSWITCH Community!"
echo "========================================================================="
exit

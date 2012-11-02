#!/bin/sh
#
# cmask-install.sh
#
#    Sets up cmask on a mac system
#    Either compiles from source if you have g++ or downloads the appropriate 32bit or 64bit binary
#    Installs in /usr/local/bin and adds it to your PATH if it's not already included
#
# Written by Marshall Bessières
# Last updated 10-30-2012
#


echo "\nHi there. So you want to install cmask? Awesome! Well, let's get started!!\n"
echo "Determining how to proceed..."

CMVERSION="20121101"

GITHUB="http://cloud.github.com/downloads/utems/cmask"
PROFILE=".bash_profile"
DESTDIR="/usr/local/bin"
TARGET="cmask"

BIN=$1
BIT=$2

# Source or Binary?
# Requires g++ compiler
# If exists, compile from source:
if [ -f /usr/bin/g++ ] && [ "$BIN" == "" ]; then

    echo "You've got g++, so let's compile!"

    echo "Downloading the source..."
    cd ~/Downloads

    # Downloads the source from Anthony Kozar
    curl -#O "$GITHUB/cmasksource-$CMVERSION.tgz"

    # Unpacks the archive file
    tar -xzf cmasksource-$CMVERSION.tgz

    # Change Directories to the source dir
    cd cmasksource-$CMVERSION

    # Compile the source
    # 2>/dev/null hides all the scary compilation instructions
    # You still see which files are being compiled
    echo "Compiling the source..."
    make 2> /dev/null

# No compiler, so download binaries:
else
    
    echo "You don't have a compiler, so we're going to download pre-compiled binaries."
    BIN=1
    
    # Change to the downloads directory
    cd ~/Downloads

    echo "Downloading binaries..."
    curl -#O "$GITHUB/cmaskbin-$CMVERSION.tgz"

    tar -zxf cmaskbin-$CMVERSION.tgz
    cd cmaskbin-$CMVERSION

    # Determine whether kernel is running in 64bit or 32bit
    # Download the appropriate binary
    echo "Determining your system type..."
    MACHINE=`sysctl hw.machine`
    if [ "$MACHINE" != "hw.machine: x86_64" ] || [ "$BIT" == "32" ]; then
        echo "Using 32-bit version..."
        TARGET="cmask32"
    else
        echo "Using 64-bit version..."
        TARGET="cmask64"
    fi
fi

# Make sure the file is executable
echo "Setting the file permission so it's executable..."
chmod a+x cmask

# Check to see if /usr/local/bin exists
# If it doesn't, create it (and /usr/local if necessary)
if [ ! -d $DESTDIR ]; then
    echo "Creating $DESTDIR..."
    mkdir -p $DESTDIR
fi

# Copy the cmask file into /usr/local/bin
# We need to sudo to copy into /usr/local/bin because often it is already owned by root
echo "Installing the binary on your system..."
echo "
*** READ THIS!!!! *****
I'm about to ask you for your password so I can install in special places.
Just type it, but I won't show you what you're typing. Then press return.
"
sudo cp $TARGET $DESTDIR/.

# Create a symbolic link to the target if it's not already called "cmask"
if [ "$TARGET" != "cmask" ]; then
    echo "Linking $TARGET to cmask..."
    sudo ln -sf $DESTDIR/$TARGET $DESTDIR/cmask
fi

# Create a .PROFILE if it doesn't exist
if [ ! -f ~/$PROFILE ]; then
    echo "Creating a new $PROFILE..."
    touch ~/$PROFILE
fi 

# Check to see if /usr/local/bin is added to PATH in .PROFILE
# If not, let's add it
if [ ! `egrep "PATH.*$DESTDIR" ~/$PROFILE` ]; then
    echo "Settting up your PATH so you have access to cmask..."
    
    # Create a comment and update the PATH and append it to .PROFILE
    echo "
    
# Add DESTDIR to the PATH for cmask
PATH=\"$DESTDIR:\$PATH\"
" >> ~/$PROFILE

fi

echo "
===========================================
=============== DONE!!!!! =================
===========================================

From any directory you should be able to type:

    cmask inputname.cmask outputname.sco
    
HOWEVER, before it will work, you need to copy-paste this line and hit return:

    source ~/.bash_profile

Enjoy!
"

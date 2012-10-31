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

GITHUBDL="http://cloud.github.com/downloads/utems/cmask"
CMVERSION="20121030"
TARGET="cmask"
BASH_LOGIN=".bash_login"

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
    curl -#O "$GITHUBDL/cmasksource-$CMVERSION.tgz"

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
    curl -#O "$GITHUBDL/cmaskbin-$CMVERSION.tgz"

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
if [ ! -d /usr/local/bin ]; then
    echo "Creating /usr/local/bin..."
    mkdir -p /usr/local/bin
fi

# Copy the cmask file into /usr/local/bin
# We need to sudo to copy into /usr/local/bin because often it is already owned by root
echo "Installing the binary on your system..."
echo "
*** READ THIS!!!! *****
I'm about to ask you for your password so I can install in special places.
Just type it, but I won't show you what you're typing. Then press return.
"
sudo cp $TARGET /usr/local/bin/.

# Create a symbolic link to the target if it's not already called "cmask"
if [ "$TARGET" != "cmask" ]; then
    echo "Linking $TARGET to cmask..."
    sudo ln -sf /usr/local/bin/$TARGET /usr/local/bin/cmask
fi

# Create a .bash_login if it doesn't exist
if [ ! -f ~/$BASH_LOGIN ]; then
    echo "Creating a new .bash_login..."
    touch ~/$BASH_LOGIN
fi 

# Check to see if /usr/local/bin is added to PATH in .bash_login
# If not, let's add it
if [ ! `egrep "PATH.*/usr/local/bin" ~/$BASH_LOGIN` ]; then
    echo "Settting up your PATH so you have access to cmask..."
    
    # Create a comment and update the PATH and append it to .bash_login
    echo "
    
# Add /usr/local/bin to the PATH for cmask
PATH=\"/usr/local/bin:\$PATH\"
" >> ~/$BASH_LOGIN

    # Source the .bash_login so the updated PATH is available right now
    echo "Sourcing your .bash_login so the PATH is ready to go..."
    source ~/$BASH_LOGIN
fi

echo "
===========================================
=============== DONE!!!!! =================
===========================================

Now all you have to do in any directory to use cmask is type:

    cmask inputname.cmask outputname.sco
    
Enjoy!
"

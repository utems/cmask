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
BIN=$1
BIT=$2

# Source or Binary?
# Requires g++ compiler
# If exists, compile from source:
if [ -f /usr/bin/g++ ] && [ "$BIN" == "" ]; then

    echo "You've got g++, so let's compile!"

    echo "Downloading the source...\n"
    cd ~/Downloads

    # Downloads the source from Anthony Kozar
    curl -#O "$GITHUBDL/cmasksource-20121030.tgz"

    # Unpacks the archive file
    tar -xzf cmasksource-20121030.tgz

    # Change Directories to the source dir
    cd cmasksource-20121030

    # Compile the source
    # 2>/dev/null hides all the scary compilation instructions
    # You still see which files are being compiled
    echo "\nCompiling the source"
    make 2> /dev/null

# No compiler, so download binaries:
else
    
    echo "You don't have a compiler, so we're going to download pre-compiled binaries."

    # Change to the downloads directory
    cd ~/Downloads

    # Determine whether kernel is running in 64bit or 32bit
    # Download the appropriate binary
    echo "Determining your system type..."
    MACHINE=`sysctl hw.machine`
    if [ "$MACHINE" != "hw.machine: x86_64" ] || [ "$BIT" == "32" ]; then
        echo "Downloading 32-bit version..."
        curl -#o cmask "$GITHUBDL/cmask32"
    else
        echo "Downloading 64-bit version..."
        curl -#o cmask "$GITHUBDL/cmask64"
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
echo "\nInstalling the binary on your system..."
echo "\n*** READ THIS!!!! *****\nI'm about to ask you for your password so I can install in special places. Just type it, but I won't show you what you're typing. Then press return.\n"
sudo cp cmask /usr/local/bin/cmask

BASH_LOGIN=".bash_login"

# Create a .bash_login if it doesn't exist
if [ ! -f ~/$BASH_LOGIN ]; then
    echo "Creating a new .bash_login..."
    touch ~/$BASH_LOGIN
fi 

# Check to see if /usr/local/bin is added to PATH in .bash_login
# If not, let's add it
if [ ! `egrep "PATH.*/usr/local/bin" ~/$BASH_LOGIN` ]; then
    echo "\nSettting up your PATH so you have access to cmask..."
    
    # Create a comment and update the PATH and append it to .bash_login
    echo "\n\n# Add /usr/local/bin to the PATH for cmask\nPATH=\"/usr/local/bin:\$PATH\"" >> ~/$BASH_LOGIN

    # Source the .bash_login so the updated PATH is available right now
    echo "Sourcing your .bash_login so the PATH is ready to go..."
    source ~/$BASH_LOGIN
fi

echo "\nDONE!!!!!\n\n======================================================================\n\nNow all you have to do in any directory to use cmask is type:\n\n\tcmask inputname.cmask outputname.sco\n\nEnjoy!\n--Marshall\n"

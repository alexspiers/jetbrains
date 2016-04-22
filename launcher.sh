#!/bin/bash

# Setup the variables and initialise the program to what ever the user passed in
CURRENT_DIRECTORY=`dirname $0`
TARGET_DIRECTORY="/tmp/$(whoami)"
PROGRAM="$1"

# If no program name was provided then default to idea (intellij)
if [ -z "$PROGRAM" ]; then
	echo "Setting PROGRAM to idea"
    PROGRAM="idea"
fi

# If the bash launcher for the program already exists then execute it
if [ -f $TARGET_DIRECTORY/$PROGRAM/bin/$PROGRAM.sh ];  then
  echo "$PROGRAM has already been copied so can just be launched"
  screen -dmS $PROGRAM sh $TARGET_DIRECTORY/$PROGRAM/bin/$PROGRAM.sh && exit
  exit 0
fi

# If the temporary folder doesn't exist, then create it
if [ ! -d "$TARGET_DIRECTORY" ]; then
  echo "Creating the directory in /tmp"
  mkdir -p $TARGET_DIRECTORY
fi

# Check if the folder containing this script also contains the program source folder
if [ -d "$CURRENT_DIRECTORY/$PROGRAM" ]; then
  # If the source program folder already exists then just copy it to the temp folder location
  echo "Copying your $PROGRAM to the tmp directory"
  cp -r $CURRENT_DIRECTORY/$PROGRAM $TARGET_DIRECTORY
fi

# If the program source folder doesn't exist then we are going to have to grab a copy of the program
if [ ! -d "$CURRENT_DIRECTORY/$PROGRAM" ]; then
  # Which program to grab is dependant on the program value
  case "$PROGRAM" in
      idea)
          $DOWNLOAD_URL="https://download.jetbrains.com/idea/ideaIC-2016.1.1.tar.gz"
          ;;
      webstorm)
          $DOWNLOAD_URL="https://download.jetbrains.com/webstorm/WebStorm-2016.1.1.tar.gz"
          ;;
      phpstorm)
          $DOWNLOAD_URL="https://download.jetbrains.com/webide/PhpStorm-2016.1.tar.gz" 
          ;;
      *)
          echo "The program can be idea, webstorm or phpstorm"
          exit 1
  esac

  # Download the program, uncompress it and move it to the correct directory
  wget $DOWNLOAD_URL -O $TARGET_DIRECTORY/$PROGRAM.tar.gz
  tar -xvzf $TARGET_DIRECTORY/$PROGRAM.tar.gz -C $TARGET_DIRECTORY
  mv $TARGET_DIRECTORY/$PROGRAM-* $TARGET_DIRECTORY/$PROGRAM

  # Change the properties to make it portable
  sed -i '8 s/# //' $TARGET_DIRECTORY/$PROGRAM/bin/idea.properties
  sed -i '13 s/# //' $TARGET_DIRECTORY/$PROGRAM/bin/idea.properties
  sed -i '18 s/# //' $TARGET_DIRECTORY/$PROGRAM/bin/idea.properties
  sed -i '23 s/# //' $TARGET_DIRECTORY/$PROGRAM/bin/idea.properties
fi

# Make the shell scripts and programs executable
chmod +x $TARGET_DIRECTORY/$PROGRAM/bin/*

# Start the program in a screen using the program name, and set it to destroy itself when the program has closed
screen -dmS $PROGRAM sh $TARGET_DIRECTORY/$PROGRAM/bin/$PROGRAM.sh && exit

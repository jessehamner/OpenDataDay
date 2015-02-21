#!/bin/bash

# Simple bash script to acquire the easiest-to-download
# data for Open Data Day in Denton County, TX.

USERNAME=$1

# COMMAND LINE ARGUMENT REQUIRED.

# where's the logfile stored?
LOGFILE="/tmp/odd_output_files.log"

# open the log file:
echo "  Opening logfile on `date`" > ${LOGFILE}
echo "" >> ${LOGFILE}
echo "Checking for a valid email address." >> ${LOGFILE}
echo"" >> ${LOGFILE}



if  [ "${USERNAME}" == "" ]
then
    echo""
    echo "OOPS:"
    echo "no email address...this script will not run if you don't"
    echo "provide a proper email address in the command line argument."
    echo""
    exit
fi

echo "${USERNAME} is my email address..."
echo "${USERNAME} is my email address..." >> ${LOGFILE}

# make a basic attempt to validate the email address:
EMAIL=`echo "${USERNAME}" | grep "@" | grep "\." `

echo""
echo "My email address is ${EMAIL}"
echo""

if [ "${EMAIL}" == "" ]
then
    echo""
    echo "This email does not appear to be properly formatted. Try again."
    echo""
    exit
fi


# Assumes Mac OS X: FIXME
MYDIR="/Users/`whoami`/Downloads"
cd "${MYDIR}"
echo""
echo "Using ${MYDIR} for downloads."
echo "Using ${MYDIR} for downloads." >> ${LOGFILE}
#echo "Double check: `pwd`"
echo""


# Now go get the files: 
DCDOWN="http://dentoncounty.com/giszipfiles"

FILES="CntyLine SurfaceWells VoteDIst Roads " # VoteDIst, [sic]

#curl http://dentoncounty.com/giszipfiles/CntyLine.zip -o CntyLine.zip

for FILE in ${FILES}
do
    echo "curl ${DCDOWN}/${FILE}.zip -o ${MYDIR}/${FILE}.zip "
    echo "curl ${DCDOWN}/${FILE}.zip -o ${MYDIR}/${FILE}.zip " >> ${LOGFILE}
    curl "${DCDOWN}/${FILE}.zip" -o "${MYDIR}/${FILE}.zip"
done


#curl http://dentoncounty.com/giszipfiles/CntyLine.zip -o CntyLine.zip

DCDOWN="http://www.cityofdenton.com/home/showdocument?id="

echo "Getting three files from cityofdenton.com. " >> ${LOGFILE}
curl ${DCDOWN}14387 -o CityLimits.zip
curl ${DCDOWN}14391 -o CityVotingDistricts.zip
curl ${DCDOWN}14383 -o CityStreets.zip


#curl http://www.cityofdenton.com/home/showdocument?id=14387 -o CityLimits.zip
#curl http://www.cityofdenton.com/home/showdocument?id=14391 -o CityVotingDistricts.zip
#curl http://www.cityofdenton.com/home/showdocument?id=14383 -o CityStreets.zip


echo "Getting data direct from census.gov, via FTP." >> ${LOGFILE}
# FTP, possibly the oldest network protocol still in use.
# Since 1971, folks. It existed before TCP/IP. 
#
USER="anonymous"
PASSWD="${EMAIL}" # 
HOST="ftp2.census.gov"
ftp -n ${HOST} <<SCRIPT
user $USER $PASSWD
binary

cd /geo/tiger/TIGER2014/STATE
get tl_2014_us_state.zip

cd /geo/tiger/TIGER2014/BG
get tl_2014_48_bg.zip

cd /geo/tiger/TIGER2014/PLACEEC
get tl_2012_48_placeec.zip

cd /geo/tiger/TIGER2014/FACESEC 
get tl_2012_48121_facesec.zip

cd /geo/tiger/TIGER2014/TRACT
get tl_2014_48_tract.zip

cd /geo/tiger/TIGER2014/FACES
get tl_2014_48121_faces.zip

quit
SCRIPT

echo"" >> ${LOGFILE}
echo "Done." >> ${LOGFILE}


#EOF

#!/bin/bash
##################################################################################
# certjoin  

# Automate certificate request generation
# Usage: certreq.sh domain.name
#
# Version history:
#
# 0.1 - Initial release
###################################################################################

VERSION="0.1 - initial release"

###################################################################################
# Prettyfication functions
###################################################################################

RCol='\e[0m'    # Text Reset

# Regular           Bold                Underline           High Intensity      BoldHigh Intens     Background          High Intensity Backgrounds
Bla='\e[0;30m';     BBla='\e[1;30m';    UBla='\e[4;30m';    IBla='\e[0;90m';    BIBla='\e[1;90m';   On_Bla='\e[40m';    On_IBla='\e[0;100m';
Red='\e[0;31m';     BRed='\e[1;31m';    URed='\e[4;31m';    IRed='\e[0;91m';    BIRed='\e[1;91m';   On_Red='\e[41m';    On_IRed='\e[0;101m';
Gre='\e[0;32m';     BGre='\e[1;32m';    UGre='\e[4;32m';    IGre='\e[0;92m';    BIGre='\e[1;92m';   On_Gre='\e[42m';    On_IGre='\e[0;102m';
Yel='\e[0;33m';     BYel='\e[1;33m';    UYel='\e[4;33m';    IYel='\e[0;93m';    BIYel='\e[1;93m';   On_Yel='\e[43m';    On_IYel='\e[0;103m';
Blu='\e[0;34m';     BBlu='\e[1;34m';    UBlu='\e[4;34m';    IBlu='\e[0;94m';    BIBlu='\e[1;94m';   On_Blu='\e[44m';    On_IBlu='\e[0;104m';
Pur='\e[0;35m';     BPur='\e[1;35m';    UPur='\e[4;35m';    IPur='\e[0;95m';    BIPur='\e[1;95m';   On_Pur='\e[45m';    On_IPur='\e[0;105m';
Cya='\e[0;36m';     BCya='\e[1;36m';    UCya='\e[4;36m';    ICya='\e[0;96m';    BICya='\e[1;96m';   On_Cya='\e[46m';    On_ICya='\e[0;106m';
Whi='\e[0;37m';     BWhi='\e[1;37m';    UWhi='\e[4;37m';    IWhi='\e[0;97m';    BIWhi='\e[1;97m';   On_Whi='\e[47m';    On_IWhi='\e[0;107m';

center_text() {
    local text="$1"
    local color="$2"
    local width=70
    local len=${#text}
    local filler=($width-$len)/2
    local padding=""
    for (( c=0; c<=$filler; c++ )); do padding+="." ; done;
    printf "$padding$color$1${RCol}$padding\n"
}

###################################################################################
# Get .key and .cer files
###################################################################################

echo

KEY=$(find . -maxdepth 1 -type f -name "*.key" -print -quit 2>/dev/null)
if [ -n "$KEY" ]; then
    KEY_C=$(echo "$KEY" | wc -l)
else
    KEY_C=0
fi

CER=$(find . -maxdepth 1 -type f -name "*.cer" -print -quit 2>/dev/null)
if [ -n "$CER" ]; then
    CER_C=$(echo "$CER" | wc -l)
else
    CER_C=0
fi

if [ $KEY_C -ne 1 ]; then
    center_text "Error" ${BRed}
    echo -e "There is more or less than ${BYel}1${IWhi} .key ${RCol}file!"
    echo
    echo -e "To use this script there has to be only ${IWhi}ONE${RCol} .key file in the directory."
    echo -e "To use this script there has to be only ${IWhi}ONE${RCol} .cer file in the directory."
    echo -e "${IYel}Remediate problem and run script again${RCol}"
    echo
    center_text "Aborting operations" $IRed
    exit 1
fi

if [ $CER_C -ne 1 ]; then
    center_text "Error" ${BRed}
    echo -e "There is more or less than ${BYel}1${IWhi} .cer ${RCol}file!"
    echo
    echo -e "To use this script there has to be only ${IWhi}ONE${RCol} .key file in the directory."
    echo -e "To use this script there has to be only ${IWhi}ONE${RCol} .cer file in the directory."
    echo -e "${IYel}Remediate problem and run script again${RCol}"
    echo
    center_text "Aborting operations" $IRed
    exit 1
fi


###################################################################################
# Files are there
# Extract domain name from .key filename and generate random password for .pfx
###################################################################################
DOMAIN=$(basename $KEY | cut -d "." -f 1,2)
Random=$(openssl rand -hex 8)


PFX=$(find . -maxdepth 1 -type f -name "*.pfx" -print -quit 2>/dev/null)
if [ -n "$PFX" ]; then
    PFX_C=$(echo "$PFX" | wc -l)
else
    PFX_C=0
fi


if [ "$PFX_C" -gt 0 ]; then

    ARCHIVE="${DOMAIN}-pfx-$(date +"%Y-%m-%d_%H-%M-%S")"
    center_text "Found old PFX files ... archiving" $IWhi
    tar -czvf "$ARCHIVE.tar.gz" *.pfx
    rm *.pfx
    center_text "Archived and deleted" $IYel

fi

center_text "KEY and CER found generating PFX" $IWhi
echo ""

###################################################################################
# Join .key and .cer into .pfx with and without password
###################################################################################
openssl pkcs12 -export -out "$DOMAIN-$Random.pfx" -inkey $KEY -in $CER -password pass:$Random

openssl pkcs12 -export -out "$DOMAIN.pfx" -inkey $KEY -in $CER -password pass:""

echo ""
echo -e "I have generated ${BYel}$DOMAIN-$Random.pfx${RCol} and ${BYel}$DOMAIN.pfx${RCol}"
echo ""
center_text "All done. Have a nice day" $IWhi
echo

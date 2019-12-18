#!/bin/bash

#banner
echo '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
echo '$$$$ Text2Speech.org WRAPPER $$$$$$$$$$$$'
echo '$$$$ BY M1GNUS -- -- PGIATASTI $$$$$$$$$$'
echo '$$$$ www.pgiatasti.it $$$$$$$$$$$$$$$$$$$'
echo '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'

#usage informations
echo; echo '[USAGE] ./t2sw.sh [text] [filename] [maxtries] [voice speed] [remote outfilename (almost useless)]'; echo

#old school... but yet swaggy
TEXT="${1:-"test"}"
NAME="${2:-"speech"}"
MAXTRIES="${3:-"11"}"
SPEED="${4:-"1"}"
OUTFILENAME="${5:-"speech"}"

#define errors
EWRONGSPEED=100
ETOOMANYTRIES=101
EBANNED=102

#check for .wav in filename
if [[ ! NAME =~ ".wav" ]]; then
	NAME=$NAME".wav"
fi

#check for correctness of SPEED
if [[ $SPEED -lt 0 ]] | [[ $SPEED -gt 2 ]]; then
	echo "WRONG SPEED VALUE"
	exit $EWRONGSPEED
fi

#recap
echo "VALUES:"
echo "text: $TEXT"
echo "filename: $NAME"
echo "speed: $SPEED"
echo "max-tries: $MAXTRIES"; echo

#press the start button and taking the result
echo "[POST]: https://www.text2speech.org"; echo
url1=`curl -sX POST https://www.text2speech.org -F "text=$TEXT" -F "speed=$SPEED" -F "user_screen_width=980" -F "outname=$OUTFILENAME" -F "voice=rms" | grep '/FW/' | awk -F "var url = '" '{print $2}' | tr -d "';"`

#check if you're banned from the site
if [[ url1 =~ "Your IP Address did exhaust the maximum numbers of allowed submits. Please try again later." ]]; then
	echo "BANNED FROM THE SITE... :( CHANGE YOUR IP"
	exit $EBANNED
fi

echo "[GET]: https://www.text2speech.org$url1"; echo

#wait while the site work...
cnt=1
while [[ -z $url2 ]]; do
	echo -n "[$cnt] Processing the file"
	for i in {1..5}
	do
		sleep 1
		echo -n "."
	done

#try taking the url of the resulting file
echo; url2=`curl https://www.text2speech.org$url1 | grep "a href" | grep "wav" | awk -F 'href="' '{print $2}' | awk -F '">' '{print $1}'`; echo
(( cnt++ ))

if [[ $cnt -ge $MAXTRIES ]]; then
	echo "TOO MANY TRIES"
	exit $ETOOMANYTRIES
fi
done

echo "[+] SUCCESS ;)"; echo
echo "[GET]: https://www.text2speech.org$url2"; echo


#spawn the file
curl "https://www.text2speech.org$url2" --output $NAME

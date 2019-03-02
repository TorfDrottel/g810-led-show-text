showHelp() {
echo " Usage: $0 TEXT DEALY LAYOUT PROFILE"
echo " Text: the text to be shown"
echo " DELAY: delay in seconds per character, default $defaultDelay"
echo " LAYOUT: \"us\" or \"de\", if missing the layout will be guessed"
echo " PROFILE: the profile to show at end, default /etc/g810-led/profile"
echo "samples:"
echo "$0 \"does this work?\""
echo "$0 \"I read so slow\" 2.4"
echo "$0 \"Streichholzschächtelchen\" 0.2 de"
echo "$0 \"try again\" 0.5 us /etc/g810-led/reboot"
}

getAttention() {
  g810-led -fx cycle keys 3
  sleep "$delay"
  sleep "$delay"
  sleep "$delay"
}


backToProfile() {
  g810-led -p "$profile"
}

asUpper() {
  g810-led -k shiftl "$on"
}

mapKeyUS() {
  case $k in
  # row 1
    \!)
      asUpper
	  k="1"
	  ;;
    \?)
      asUpper
	  k="2"
	  ;;
  esac
}

mapKeyDE() {
  case $k in
  # row 1
    \^)
	  k="~"
	  ;;
    \!)
      asUpper
	  k="1"
	  ;;
    \?)
      asUpper
	  k="-"
	  ;;
    \ß)
	  k="-"
	  ;;
    \')
	  k="="
	  ;;
  # row 2
    \z)
	  k="y"
	  ;;
    \Z)
	  k="Y"
	  ;;
    \Ü)
      asUpper
	  k="["
	  ;;
    \ü)
	  k="["
	  ;;
    \+)
	  k="]"
	  ;;
  # row 3
    \y)
	  k="z"
	  ;;
    \Y)
	  k="Z"
	  ;;
    \Ö)
      asUpper
	  k=";"
	  ;;
    \ö)
	  k=";"
	  ;;
    \Ä)
      asUpper
	  k="\""
	  ;;
    \ä)
	  k="\""
	  ;;
    \#)
	  k="$"
	  ;;
  # row 4
    \-)
	  k="/"
	  ;;
  # Space
    \ )
	  k="space"
	  ;;
  esac
}

showkey() {
  #echo "showing $k"
  g810-led -a "$off"
  if [[ $layout == "de" ]]
  then mapKeyDE
  else mapKeyUS
  fi
  if [[ $k =~ [A-Z] ]]
  then asUpper
  fi
  g810-led -k "$k" "$on"
}

showText() { 
  for (( i=0; i<${#text}; i++ )); do
    k=${text:$i:1}
    showkey
    sleep "$delay"
  done
}


defaultDelay=0.2
off=000000
on=ffffff
text="$1"
if [ ! "$text" ] 
then
  text="--help"
fi
if [ $text == '--help' ]
then
  showHelp
else
  delay="$2"
  if [ ! "$delay" ]; then delay=$defaultDelay; fi
  layout="$3"
  if [ ! "$layout" ];
  then 
    echo guessing layout
    layout=$(setxkbmap -print | awk -F"+" '/xkb_symbols/ {print $2}')
    echo "$layout"
  fi
  profile="$4"
  if [ ! "$profile" ] 
  then profile=/etc/g810-led/profile
  fi
  echo "showing $text for $delay seconds each using $layout layout"
  #getAttention
  showText
  backToProfile
fi

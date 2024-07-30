#!/bin/bash
#
#

trap "rm -vf *.wget-dl" EXIT

ME=$(basename $0)
MYPROC="$ME $(sed -r 's#\\\.#\\\\\\\.#g' <<< "$@")"

USAGE="MultiGET
Download multiple large files with specific extensions in parallel from a site
offering files for download via http(s). For example archive.org.
USAGE: $ME [-c|-t] <EXT> <URL(s)>
-w <num> ... number of concurrent wget processes
      -c ... clear screen before each status update.
      -t ... show what would be downloaded, but don't do anything.
     EXT ... extension(s) to download (case insensitive).
             Examples: single: '\\.iso' multiple: '\\.bin|\\.cue'
  URL(s) ... URL (folder) where the files reside."

#--- HANDLE INPUT ---#
while [ ! -z $1 ]
do case $1 in
         -w) shift
             egrep '^[0-9]+$' <<< "$1" || { echo -e "-w must be followed by a number!\n$USAGE" ; exit 1 ; }
             TRD=$1
             shift ;;
         -c) CLEAR=clear
             shift ;;
         -t) TESTING=1
             shift ;;
      http*) URL="$URL $1"
             shift ;;
\(\\.*|\\.*) EXT=$1
             shift ;;
         -h) echo "$USAGE"
             exit 0 ;;
          *) echo -e "Cannot parse [$1]\n$USAGE"
             exit 1 ;;
   esac
done
if [ "x$TRD" = "x" ]
then TRD=10
fi
if [ "x$URL" = "x" ]
then echo -e "URL not set.\n$USAGE"
     exit 1
fi
if [ "x$EXT" = "x" ]
then echo -e "EXT not set.\n$USAGE"
     exit 1
fi

#echo "$MYPROC"
#pgrep -a -f "$MYPROC"
#read -p ''
#exit 1

#--- READ FILE LIST ---#
for u in $URL
do echo "Reading from [$u]"
ITM="$ITM
$(curl -Lks $u | egrep -o -i "href.*($EXT)" | sed -r 's#^.*"##g;s#.*"##g;s#>##g' | sed -r "s#^#$u/#g")"
done
if [ "$TESTING" = "1" ]
then echo "$ITM"
     echo "$CLEAR"
     exit 0
fi

#--- DEFINE FUNCTIONS ---#
rundl(){
   log="$(sed -r 's#.*/##g' <<< "$i").wget-dl"
   wget --show-progress --progress=bar:force:noscroll -q -t0 -c "$i" &> "$log"
   rm -f "$log"
}
showprogress(){
   if [ -f '*.wget-dl' ]
   then rm '*.wget-dl'
   fi
   $CLEAR
   tail -n1 *.wget-dl
   echo -e "\n#-----------------------------------#"
   for f in *.wget-dl
   do echo > "$f" 
   done
}
waitfor(){ # $1 number of $ME to wait for
   while [ "$(pgrep -c -f "$MYPROC")" -gt $1 ]
   do sleep 1
      showprogress
   done
}

#--- RUN DOWNLOADERS ---#
IFS="
"
for i in $ITM
do waitfor $TRD
   rundl &
   showprogress
done
unset IFS
waitfor 1



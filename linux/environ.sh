USER='master'

_start_log() {
 _check_ssh $TARGET
 if [ "$TARGET" != '' ]; then
   rm $log &> /dev/null
   date > $log
 else
  echo "Usage: $0 target"
  exit 1
 fi
}

_check_ssh() {
 ping -c 1 -w 1 "$TARGET" &> /dev/null
 if [ "$?" -ne 0 ]; then
   echo "$TARGET is unavailable"
   exit 1
 else
   echo "$TARGET is up"
 fi
}

_run_cmd() {
 echo "================= $1" >> $log
 ssh $TARGET $2 &>> $log
 if [ "$?" -ne 0 ]; then
    echo "Fail $2 with $?"
    echo "See log in " $log
    exit 1
 else
    echo "[$NAME] $1"
 fi
}

_run_fore() {
 echo "================= $1" >> $log
 ssh $TARGET $2
 if [ "$?" -ne 0 ]; then
    echo "Fail $2 with $?"
    exit 1
 else
    echo "[$NAME] $1"
 fi
}

_run_copy() {
 echo "================= $1" >> $log
 scp -r $2 $TARGET:$3 &>> $log
 if [ "$?" -ne 0 ]; then
    echo "Fail copy $2 to $3 with $?"
    echo "See log in " $log
    exit 1
 else
    echo "[$NAME] $1"
 fi
}
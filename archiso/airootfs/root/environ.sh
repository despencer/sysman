_start_log() {
 rm $log &> /dev/null
 date > $log
 hwclock -r >> $log
 timedatectl status >> $log
}

_run_cmd() {
 echo "================= $1" >> $log
 eval "$2" &>> $log
 if [ "$?" -ne 0 ]; then
    echo "Fail $2 with $?"
    echo "See log in " $log
    exit 1
 else
    echo "[+] $1"
 fi
}

_run_fore() {
 echo "================= $1" >> $log
 eval "$2"
 if [ "$?" -ne 0 ]; then
    echo "Fail $2 with $?"
    exit 1
 else
    echo "[+] $1"
 fi
}

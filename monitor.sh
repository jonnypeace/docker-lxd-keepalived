#!/bin/bash

# Monitor script for KeepAliveD. I have chose to host my docker containers in LXD containers, and I use
# this script to make sure i have high availability for portainer/freshrss/vaultwarden as an example.

# This variable is for the KeepaliveD virtual IP for portainer and portainers port number, which is used to test if the link is up.
ka_host_ip='10.10.200.69 9443' # EDIT to suit subnet

# This file will be used by keepalived to determine if the link is successful.
mon_file='/etc/keepalived/monitor'

# root docker directory where containers located, following a pattern like so...
# /docker/portainer, /docker/freshrss etc adjust as necessary.
dock_dir='/docker'

# docker container names, i.e. the name given with the --name flag in docker. To add more, just increment the array number for each container.
declare -a cont_arr
cont_arr[1]='portainer' # This will also be used as my keepalived monitor container
cont_arr[2]='freshrss'
cont_arr[3]='vaultwarden'
cont_arr[4]='watchtower'
#cont_arr[5]=''
#cont_arr[6]=''
#cont_arr[7]=''

testKA=$(awk '/Entering MASTER STATE|Entering BACKUP STATE|Stopped Keepalive/{l[lines++]=$0}; END{split(l[lines-1],a," "); print a[8], a[9] }' /var/log/syslog)
testDOC=$(docker inspect "${cont_arr[1]}" | awk -F '"' '/Status/{print $4}')

# shellcheck disable=SC2086
if nc -zw1 $ka_host_ip; then
        echo 'KeepaliveD and Docker have no issues'
        exit
fi

# shellcheck disable=SC2086
if ! nc -zw1 $ka_host_ip ; then
        if [[ $testDOC =~ (running|restarting) && $testKA =~ (BACKUP STATE|Daemon \(LVS) ]] ; then
                for cont in "${cont_arr[@]}"
                do
                        cd "$dock_dir"/"$cont" || { echo 'no directory found or no permissions' && exit 1; }
                        docker-compose stop "$cont"
                done
                echo 1 > "$mon_file"
        elif [[ $testDOC == 'exited' && $testKA == 'MASTER STATE' ]]; then
                for cont in "${cont_arr[@]}"
                do
                        cd "$dock_dir"/"$cont" || { echo 'no directory found or no permissions' && exit 1; }
                        docker-compose pull  && docker-compose up -d
                        wait
                done
                sleep 10
                # Retest to ensure status is running.
                testDOC=$(docker inspect "${cont_arr[1]}" | awk -F '"' '/Status/{print $4}')
                if nc -zw1 $ka_host_ip && [[ $testDOC == 'running' ]]; then
                        echo 0 > "$mon_file"
                else
                        echo 1 > "$mon_file"
                fi
        fi
fi

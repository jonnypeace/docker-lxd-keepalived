# docker-lxd-keepalived

This is just a short summary of how this works...

## monitor.sh

This is used by keepalived to keep track of a service on your network... in my example, i've used portainer as an example

You'll want to modify this for your own subnet...

```bash
ka_host_ip='10.10.200.69 9443' # EDIT to suit subnet
```

This ip will be the same (virtual) IP that is set in your keepalived config files

You'll also want to edit this array for container names - as per docker-compose files.

```bash
cont_arr[1]='portainer' # This will also be used as my keepalived monitor container
cont_arr[2]='freshrss'
cont_arr[3]='vaultwarden'
cont_arr[4]='watchtower'
#cont_arr[5]=''
#cont_arr[6]=''
#cont_arr[7]=''
```

Lastly for this script, the directory of /docker(/container) is assumed for all your docker-compose files.
So you'll want to modify as necessary. If you have docker-compose files scattered everywhere, this script won't work.

```bash
# root docker directory where containers located, following a pattern like so...
# /docker/portainer, /docker/freshrss etc adjust as necessary.
dock_dir='/docker'
```

## Master & Slave keepalived config (obviously this is for a pair of servers).

In your master server, copy etc.keepalived.master.conf file into /etc/keepalived/keepalived.conf

For your slave server, copy etc.keepalived.slave.conf file into /etc/keepalived/keepalived.conf

All that really needs modified here is this line, and ensure same virtual ip as in your monitor script.

```bash
  10.10.200.69 # EDIT to suit subnet
```

Lastly, you'll want to enable and start keepalived

```bash
systemctl enable --now keepalived
```

If you run 

```bash
systemctl status keepalived
```
The master will show...

```
Entering MASTER STATE
```
The slave will show...

```
Entering BACKUP STATE
(VI_2) Changing effective priority from 80 to 81
```

Or something along those lones, depending probably whether the slave was a master to begin with. The main takeaway is that one will be in master state, and the other in backup state.

## docker-update.sh

I will probably update this to make it more fancy, but for now, it's a simple brace expansion, test directory, change to directory, and pull new image and start container.

Again, this is assuming a root directory of /docker/containers....

So modify as necessary.

## cron jobs

Again, this should be mostly self explanatory. I've shown how often i would run the monitor script, this means there should only really be around 1minute of downtime, give or take, depending if theres a docker image update.

So edit this for the location of the keepalived monitor script.

```bash
Monitors every minute for keepalived
*/1 * * * * /home/user/monitor.sh
```

I've also shown a short rsync command to keep containers in sync over a mounted share, so you'll want both servers to have the same mount if you use the same command as I. 

Hope this helps, feel free to let me know if there are any issues.

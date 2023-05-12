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
So you'll want to modify as necessary. If you have docker-compose files scattered everywhere, this script probably won't work.

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

## docker-update.sh

I will probably update this to make it more fancy, but for now, it's a simple brace expansion, test directory, change to directory, and pull new image and start container.

Again, this is assuming a root directory of /docker/containers....

So modify as necessary.

Hope this helps, feel free to let me know if there are any issues.

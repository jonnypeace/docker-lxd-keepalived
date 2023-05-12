#!/bin/bash

# Manual update for docker instances
# Fairly small script and self explanatory

# If you run a lot of services, perhaps building an array to loop over would be better.

for i in /docker/{freshrss,portainer,vaultwarden,watchtower}; do
	cd "$i" || { echo 'no directory found or no permissions' && exit 1; }
	docker-compose pull  && docker-compose up -d
done

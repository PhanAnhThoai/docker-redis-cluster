#!/usr/bin/env bash
set -ex


IP_SLAVE=$(ip addr show eth0 | grep 'inet ' | sed -E 's/\s+inet ([0-9.]+)\/[0-9]+ .*/\1/g' | head -n 1)
IP_MASTER=${IP_MASTER:-}
REDIS_ROOT_PASS=${REDIS_ROOT_PASS:-password}

# Input IP master change "dig +short master"

if [ -z $IP_MASTER ]; then
  IP_MASTER=${IP_MASTER:-192.168.12.162}
fi

# If use docker run mysql no need use service redis-server start
#sudo service redis-server start

while :; 
do
  if nc -z localhost 6379
  then
    break
  else
    sleep 3
  fi
done


while :; 
do
  if nc -z ${IP_MASTER} 6379
  then
    break
  else
    sleep 1
  fi
done

sudo sed -i -E 's/^protected-mode no$/protected-mode yes/g' /etc/redis/redis.conf

#echo 'bind 0.0.0.0' >> /etc/redis/redis.conf
echo "masterauth \"$REDIS_ROOT_PASS\"" | sudo tee -a /etc/redis/redis.conf
echo "slaveof  \"$IP_MASTER\" 6379" | sudo tee -a /etc/redis/redis.conf
echo "requirepass \"$REDIS_ROOT_PASS\"" | sudo tee -a /etc/redis/redis.conf


sudo service redis-server restart

echo "sentinel monitor redis-master \"$IP_MASTER\" 6379 2" | sudo tee -a /etc/redis/sentinel.conf
echo 'sentinel down-after-milliseconds redis-master 1500' | sudo tee -a /etc/redis/sentinel.conf
echo 'sentinel failover-timeout redis-master 3000' | sudo tee -a /etc/redis/sentinel.conf
echo 'protected-mode no' | sudo tee -a /etc/redis/sentinel.conf

sudo service redis-sentinel restart

echo 'info replication' | sudo redis-cli -a password
echo 'info sentinel' | sudo redis-cli -p 26379

sudo clab deploy --reconfigure
sudo docker exec -it clab-srsfc-router1 /usr/local/bin/init.sh
sudo docker exec -it clab-srsfc-router2 /usr/local/bin/init.sh
sudo docker exec -it clab-srsfc-router3 /usr/local/bin/init.sh
sudo docker exec -it clab-srsfc-router4 /usr/local/bin/init.sh
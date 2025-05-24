chmod +x router1/init.sh
chmod +x router2/init.sh
chmod +x router3/init.sh
chmod +x router4/init.sh
chmod +x pc1/init.sh
chmod +x pc2/init.sh
chmod +x sflow-rt/init.sh
sudo clab deploy --reconfigure
sudo docker exec -it clab-srsfc-router1 /usr/local/bin/init.sh
sudo docker exec -it clab-srsfc-router2 /usr/local/bin/init.sh
sudo docker exec -it clab-srsfc-router3 /usr/local/bin/init.sh
sudo docker exec -it clab-srsfc-router4 /usr/local/bin/init.sh
sudo docker exec -it clab-srsfc-pc1 /usr/local/bin/init.sh
sudo docker exec -it clab-srsfc-pc2 /usr/local/bin/init.sh
sudo docker exec -it clab-srsfc-sflow-rt /usr/local/bin/init.sh
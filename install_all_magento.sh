CONTAINER=$(docker-compose ps web | awk 'FNR == 3 {print $1}')
docker exec -it $CONTAINER install-venia
docker exec -it $CONTAINER install-magento

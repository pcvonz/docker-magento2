CONTAINER=$(docker-compose ps web | awk 'FNR == 3 {print $1}')
docker exec -it $CONTAINER bash

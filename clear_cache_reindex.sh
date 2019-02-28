docker-compose exec web "su www-data && bin/magento indexer:reindex && bin/magento cache:flush && bin/magento cache:clear"

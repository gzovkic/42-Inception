docker exec mariadb mysql -u root -prootpizza123 -e "SHOW DATABASES;"

docker exec mariadb mysql -u root -prootpizza123 wordpress -e "SHOW TABLES;"

docker exec mariadb mysql -u root -prootpizza123 wordpress -e "SELECT COUNT(*) as 'Total Posts' FROM wp_posts;"

docker exec mariadb mysql -u root -prootpizza123 wordpress -e "SELECT user_login, user_email FROM wp_users;"

docker exec mariadb mysql -u root -prootpizza123 wordpress -e "SELECT ID, post_title, post_status FROM wp_posts;"

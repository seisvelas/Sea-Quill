#!/bin/bash

cd "Source Code"

# Our port will need a high power level
# to defeat Vegeta
port=9001
apache_config=/etc/apache2/sites-enabled/000-default.conf

echo "
<VirtualHost *:80>
    ProxyPreserveHost On
" > $apache_config

# ls -1 gives each file a seperate line so we can loop through the SQL filenames
for sql_program in `ls -1 ../SQL/`
do
    nohup racket $sql_program $port &> racket.log & 

    # Most of my backend web experience is in Node. Despite the hate it gets,
    # I have to note that in Node, all of this reverse-proxying-for-multiple-scripts
    # BS would have been handled automatically by webpack. 

    echo "
    ProxyPass /$sql_program http://127.0.0.1:$port/$sql_program
    ProxyPassReverse /$sql_program http://127.0.0.1:$port/$sql_program
    " >> $apache_config

    port=$((port+1))
done

echo "
</VirtualHost>" >> $apache_config

# By default, Postgres on Debian uses 'ident' authentication,
# which means you log in as whatever system user you are. We will create
# a user called 'sea', password 'quill' for db 'db'. This isn't as 
# dramatic a security snafu as it seems, since Postgres isn't exposed
# via Docker and therefore can only be accessed via Apache (which is exposed)
service postgresql start
su - postgres -c "createdb sea"
su - postgres -c "psql -c \"create user sea with encrypted password 'quill';\""
su - postgres -c "psql -c \"grant all privileges on database sea to sea;\"" 
echo "local    all         all       trust" > /etc/postgresql/11/main/pg_hba.conf
echo "host     all         all       0.0.0.0/0 trust" >> /etc/postgresql/11/main/pg_hba.conf
service postgresql restart

# How CMD works in Docker is it needs to leave something running in the
# foreground that stays alive. If you just start background services, they will
# die off. I use the common workaround of a wrapper script that hangs the last command,
# but the better approach would be to have all of the Racket servlets be a seperate
# service and interact via ports and stuff.
# I'm doing it this way because I haven't learned how to use docker-compose yet.
apachectl -DFOREGROUND
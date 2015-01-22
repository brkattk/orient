#!/usr/bin/env bash
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales

echo "************************************************************"
echo "Updating packages..."
echo "************************************************************"
sudo apt-get update

echo "************************************************************"
echo "Installing apt-add-repository"
echo "************************************************************"
sudo apt-get install -y python-software-properties
sudo apt-get install -y build-essential git-core ack-grep ant

echo "************************************************************"
echo "Adding ppa:pitti/postgresql ppa:rwky/redis ppa:nginx/stable ppa:chris-lea/node.js"
echo "************************************************************"
sudo apt-add-repository -y ppa:rwky/redis
sudo apt-add-repository -y ppa:nginx/stable
sudo apt-add-repository -y ppa:chris-lea/node.js
sudo apt-add-repository -y ppa:brightbox/ruby-ng
sudo add-apt-repository -y ppa:webupd8team/java

echo "************************************************************"
echo "Adding postgresql precise apt repo from http://wiki.postgresql.org/wiki/Apt"
echo "************************************************************"

echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

echo "************************************************************"
echo "Updating"
echo "************************************************************"
sudo apt-get update

echo "************************************************************"
echo "Installing java7"
echo "************************************************************"
echo debconf shared/accepted-oracle-license-v1-1 select true | \
sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | \
sudo debconf-set-selections
sudo apt-get install -y oracle-java7-installer

echo "************************************************************"
echo "Installing postgresql-9.2 postgresql-client-9.2 postgresql-contrib-9.2"
echo "************************************************************"
sudo apt-get install -y postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 postgresql-common postgresql-server-dev-9.3

echo "************************************************************"
echo "Installing postgresql-server-dev-9.2 libpq-dev"
echo "************************************************************"
sudo apt-get install -y libpq-dev

echo "************************************************************"
echo "Updating password for user 'postgres'"
echo "************************************************************"
su postgres -c "psql -c \"alter user postgres with password 'postgres';\""

echo "************************************************************"
echo "Creating postgres roles via /vagrant/vagrant/create_role.sql"
echo "************************************************************"
su postgres -c "psql -f /vagrant/vagrant/create_role.sql"
echo "Postgres username: vagrant password: rootdev"
echo "************************************************************"

echo "************************************************************"
echo "Changing postgres authentication to md5 instead of peer"
echo "************************************************************"
echo "local   all             postgres                                md5
local   all             all                                     md5
host    all             all             0.0.0.0/0               md5
host    all             all             ::1/128                 md5" \
 | sudo tee /etc/postgresql/9.3/main/pg_hba.conf

echo "************************************************************"
echo "Allowing external connections to postgres"
echo "************************************************************"
echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/9.3/main/postgresql.conf

echo "************************************************************"
echo "Restarting postgres"
echo "************************************************************"
sudo /etc/init.d/postgresql restart

echo "************************************************************"
echo "Installing redis-server"
echo "************************************************************"
sudo apt-get install -y redis-server

echo "************************************************************"
echo "Installing nodejs with grunt-cli and bower"
echo "************************************************************"
sudo apt-get install -y nodejs
sudo npm install -g grunt-cli bower

# echo "************************************************************"
# echo "Installing nginx"
# echo "************************************************************"
# sudo apt-get install -y nginx

echo "************************************************************"
echo "Installing prereqs for ruby, postgis, phantom, etc."
echo "************************************************************"
sudo apt-get install -y chrpath libssl-dev libfontconfig1-dev vim libxml2 libxml2-dev libxslt1-dev libxrender-dev libyaml-dev libsqlite3-dev sqlite3 libproj-dev libjson0-dev xsltproc docbook-xsl docbook-mathml

# echo "************************************************************"
# echo "Installing ruby"
# echo "************************************************************"
# sudo apt-get install -y ruby rubygems ruby-switch
# sudo apt-get install -y ruby2.1 ruby2.1-dev
#
# echo "************************************************************"
# echo "Setting default ruby:"
# sudo ruby-switch --set ruby2.1
# ruby -v
# echo "Installing bundler"
# sudo gem install bundler
# echo "************************************************************"

echo "************************************************************"
echo "Installing OrientDB"
echo "************************************************************"
cd /home/vagrant
git clone https://github.com/orientechnologies/orientdb.git
cd /home/vagrant/orientdb
git checkout tags/2.0
ant clean install

echo "************************************************************"
echo "************************************************************"
echo "************************************************************"
echo "OrientDB installed to /home/vagrant/releases/orientdb-community-2.0"
echo "************************************************************"
echo "************************************************************"
echo "************************************************************"


# echo "************************************************************"
# echo "Installing imagemagick"
# echo "************************************************************"
# sudo apt-get install -y imagemagick

# echo "************************************************************"
# echo "Installing elasticsearch"
# echo "************************************************************"
# dpkg -l | grep -E '^ii' | grep elasticsearch
# if [ $? -eq 0 ]; then
#   sudo service elasticsearch start
# else
#   wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.1.deb
#   sudo dpkg -i elasticsearch-1.1.1.deb
#   sudo update-rc.d elasticsearch defaults 95 10
#   sudo service elasticsearch start
# fi

sudo apt-get autoremove

echo "************************************************************"
echo "Copying /vagrant/vagrant/.bash_profile"
echo "************************************************************"
cp /vagrant/vagrant/.bash_profile /home/vagrant/.bash_profile
chown vagrant:vagrant /home/vagrant/.bash_profile

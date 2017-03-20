#!/usr/bin/env bash
#
# This script installs puppet 3.x or 4.x and deploy the manifest using puppet apply -e "include profile_influxdb"
#
# Usage:
# Ubuntu / Debian: wget https://raw.githubusercontent.com/relybv/rely-profile_influxdb/master/files/bootme.sh; bash bootme.sh
#
# Red Hat / CentOS: curl https://raw.githubusercontent.com/relybv/rely-profile_influxdb/master/files/bootme.sh -o bootme.sh; bash bootme.sh
# Options: add 3 as parameter to install 4.x release

# default major version, comment to install puppet 3.x
PUPPETMAJORVERSION=4
export DEBIAN_FRONTEND=noninteractive
### Code start ###
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

if [ "$#" -gt 0 ]; then
   if [ "$1" = 3 ]; then
     PUPPETMAJOR=3
   else
     PUPPETMAJOR=4
  fi
else
  PUPPETMAJOR=$PUPPETMAJORVERSION
fi

if [ "$PUPPETMAJOR" = 3 ]; then
    MODULEDIR="/etc/puppet/modules/"
  else
    MODULEDIR="/etc/puppetlabs/code/modules/"
fi

# install dependencies
if which apt-get > /dev/null 2>&1; then
    apt-get update
  else
    echo "Using yum"
fi

apt-get install git bundler zlib1g-dev libaugeas-ruby -y -q || yum install -y git bundler zlib-devel

# get or update repo
if [ -d /root/profile_influxdb ]; then
  echo "Update repo"
  cd /root/profile_influxdb
  git pull
else
  echo "Cloning repo"
  git clone https://github.com/relybv/rely-profile_influxdb.git /root/profile_influxdb
  cd /root/profile_influxdb
fi

# install puppet
bash /root/profile_influxdb/files/bootstrap.sh $PUPPETMAJOR

# prepare bundle
echo "Installing gems"
/opt/puppetlabs/puppet/bin/gem install puppetlabs_spec_helper --no-rdoc --no-ri -q

# install dependencies from .fixtures
echo "Preparing modules"
/opt/puppetlabs/puppet/bin/rake spec_prep

# copy to puppet module location
cp -a /root/profile_influxdb/spec/fixtures/modules/* $MODULEDIR

echo "Run puppet apply"
/usr/local/bin/puppet apply -e "include profile_influxdb"

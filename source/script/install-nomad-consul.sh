#!/usr/bin/env bash
set -e

# install missing binaries #
############################
sudo apt-get install unzip

# ENVIRONMENT VARIABLES #
#########################
export NOMAD_VERSION="1.1.6"
export CONSUL_VERSION="1.10.3"
export ARCH="amd64"

# Nomad download#
#################
curl --silent --remote-name https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_${ARCH}.zip
unzip nomad_${NOMAD_VERSION}_linux_${ARCH}.zip

# Nomad prepare binary #
########################
sudo mv nomad /usr/bin/
nomad --autocomplete-install
sudo mkdir --parents /opt/nomad
sudo mkdir --parents /etc/nomad.d
sudo useradd --system --home /etc/nomad.d --shell /bin/false nomad
sudo touch /etc/systemd/system/nomad.service
# sudo chmod 700 /etc/nomad.d
sudo systemctl enable nomad
# sudo systemctl start nomad
# sudo systemctl status nomad

# Consul download #
###################
export CONSUL_URL="https://releases.hashicorp.com/consul"
curl --silent --remote-name ${CONSUL_URL}/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_${ARCH}.zip
unzip consul_${CONSUL_VERSION}_linux_${ARCH}.zip


# Consul prepare binary #
#########################
sudo chown root:root consul
sudo mv consul /usr/bin/
consul -autocomplete-install
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul/
sudo chown --recursive consul:consul /opt/consul
# Configure Consul agents #
###########################
sudo mkdir --parents /etc/consul.d/
sudo chown --recursive consul:consul /etc/consul.d

# sudo systemctl enable consul
# sudo systemctl start consul
# sudo systemctl status consul
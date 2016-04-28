#!/bin/bash


# For debugging, set NOOP to echo
NOOP=""

# Stack user name, although this script supports modifying the username
# The devstack create-stack-user script does not support it
STACK_USER="stack"

DEVSTACK_REPO="https://git.openstack.org/openstack-dev/devstack"


# Install Git
$NOOP sudo apt-get -y install git


# Add stack user
# Add check for user
$NOOP sudo useradd -m $STACK_USER

# clone devstack
# Add check if report already exist
if [ ! -e "/home/$STACK_USER/devstack" ];  then
    FIRST_DEPLOY="True"
    $NOOP sudo -u $STACK_USER git clone $DEVSTACK_REPO /home/$STACK_USER/devstack
fi

# Setup the configuration file
# Add check if local.conf already exist
TARGET_FILE="/home/$STACK_USER/devstack/local.conf"
$NOOP sudo -u $STACK_USER cp /vagrant/devstack/conf/local.conf $TARGET_FILE
HOST_IP=`ifconfig eth0 | grep ' inet addr:' | awk '{ print $2 }' | cut -d':' -f 2`
if [ -n "$NOOP" ]; then 
    $NOOP "echo \"echo 'HOST_IP=$HOST_IP' >> $TARGET_FILE\" | sudo -u $STACK_USER bash"
else
    echo "echo 'HOST_IP=$HOST_IP' >> $TARGET_FILE" | sudo -u $STACK_USER bash
fi



# Give sudo privileges to stack user
$NOOP sudo /home/$STACK_USER/devstack/tools/create-stack-user.sh


# Change to devstack directory
$NOOP cd /home/$STACK_USER/devstack

# Start stack deployment
# Don't run it devstack was already there
if [ "$FIRST_DEPLOY" == "True" ]; then
    $NOOP sudo -H -u $STACK_USER ./stack.sh | tee /home/$STACK_USER/stack_first_deployment.log
fi

# TODO: print the admin and demo user information also
echo "##############################################################"
echo "#                           IMPORTANT                        #"
echo "##############################################################"
echo "#                                                            "
echo "# Installation log file location:                            " 
echo "#             /home/$STACK_USER/stack_first_deployment.log   "
echo "#                                                            "
echo "# Above horizon URL will only work on VM deployed by Vagrant "
echo "#                                                            "
echo "# Port forwarding has been setup and you can access          "
echo "#    Horizon on your host machine using the following URL    "
echo "#                                                            "
echo "# Access Horizon at: http://127.0.0.1:8080/dashboard         "
echo "##############################################################"

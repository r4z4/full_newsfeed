#!/bin/sh

# container post_create_script

su - 
apt-get install git build-essential
cd /tmp
git clone https://github.com/pgvector/pgvector.git
cd pgvector
make
make install 
#!/bin/bash

./autogen.sh
./configure --prefix=/usr
make
sudo make install

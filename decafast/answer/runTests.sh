#!/bin/sh
make
cd ..
python3 zipout.py
python3 check.py

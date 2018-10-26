#!/bin/bash
set -evx

mkdir ~/.aywacore

# safety check
if [ ! -f ~/.aywacore/.aywa.conf ]; then
  cp share/aywa.conf.example ~/.aywacore/aywa.conf
fi

#!/bin/bash
set -e

make
/home/fac/wrc/bin/rsim  square.out 

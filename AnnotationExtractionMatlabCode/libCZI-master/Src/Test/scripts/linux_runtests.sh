#!/bin/sh

#EXECUTABLE=~/github/libCZI/Src/CZIcmd/CZIcmd
EXECUTABLE=/home/azamhamidinekoo/Documents/dataset/AnnotationExtractionMatlabCode/libCZI-master/Src/CZICmd/CZIcmd
SRCIMAGES=/home/jbohl/atom2/hdd/2/tmp/TestData/

if [ -z "$1"] 
then
  python runtests.py -s $SRCIMAGES -d /home/jbohl/atom2/hdd/2/tmp/TestOut/ -e $EXECUTABLE -t ./testdata_linux.txt 
else
  python runtests.py -s $SRCIMAGES -d /home/jbohl/atom2/hdd/2/tmp/TestOut/ -e $EXECUTABLE -t ./testdata_linux.txt --skip $1
fi


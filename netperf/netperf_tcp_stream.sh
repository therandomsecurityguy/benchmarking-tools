#!/bin/sh
#
# This is an example script for using netperf. Feel free to modify it 
# as necessary, but I would suggest that you copy this one first.
# 
# This version has been modified to take advantage of the confidence
# interval support in revision 2.0 of netperf. it has also been altered
# to make submitting its resutls to the netperf database easier
#
# usage: ./netperf_tcp_stream.sh [machine A's IP] [CPU] [-Tx,x] > filename.txt
#

if [ $# -gt 4 ]; then
  echo "try again, correctly -> tcp_stream_script hostname [CPU] [-Tx,x] [I]"
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "try again, correctly -> tcp_stream_script hostname [CPU]"
  exit 1
fi

# where the programs are
NETHOME=/usr/local/bin
#NETHOME="/opt/netperf"
#NETHOME=.

# at what port will netserver be waiting? If you decide to run
# netserver at a different port than the default of 12865, then set
# the value of PORT apropriately
#PORT="-p some_other_portnum"
PORT=""

# The test length in seconds
TEST_TIME=5

# How accurate we want the estimate of performance: 
#      maximum and minimum test iterations (-i)
#      confidence level (99 or 95) and interval (percent)
STATS_STUFF="-i 10,2 -I 99,5"

# The socket sizes that we will be testing
SOCKET_SIZES="128K 57344 32768 8192 4M"

# The send sizes that we will be using
SEND_SIZES="4096 8192 32768"

# if there are two parms, parm one it the hostname and parm two will
# be a CPU indicator. actually, anything as a second parm will cause
# the CPU to be measured, but we will "advertise" it should be "CPU"

if [ $# -eq 4 ]; then
  REM_HOST=$1
  LOC_CPU=""
  REM_CPU=""
  AFFINITY=""
  STREAM="TCP_STREAM"

case $2 in
\CPU) LOC_CPU="-c";REM_CPU="-C";;
\I) STREAM="TCP_MAERTS";;
*) AFFINITY=$2
esac

case $3 in
\CPU) LOC_CPU="-c";REM_CPU="-C";;
\I) STREAM="TCP_MAERTS";;
*) AFFINITY=$3
esac

case $4 in
\CPU) LOC_CPU="-c";REM_CPU="-C";;
\I) STREAM="TCP_MAERTS";;
*) AFFINITY=$4
esac
fi

if [ $# -eq 3 ]; then
  REM_HOST=$1
  LOC_CPU=""
  REM_CPU=""
  AFFINITY=""
  STREAM="TCP_STREAM"

case $2 in
\CPU) LOC_CPU="-c";REM_CPU="-C";;
\I) STREAM="TCP_MAERTS";;
*) AFFINITY=$2
esac

case $3 in
\CPU) LOC_CPU="-c";REM_CPU="-C";;
\I) STREAM="TCP_MAERTS";;
*) AFFINITY=$3
esac
fi

if [ $# -eq 2 ]; then
  REM_HOST=$1
  LOC_CPU=""
  REM_CPU=""
  AFFINITY=""
  STREAM="TCP_STREAM"

case $2 in
\CPU) LOC_CPU="-c";REM_CPU="-C";;
\I) STREAM="TCP_MAERTS";;
*) AFFINITY=$2
esac
fi

if [ $# -eq 1 ]; then
  REM_HOST=$1
  LOC_CPU=""
  REM_CPU=""
  AFFINITY=""
  STREAM="TCP_STREAM"
fi

# If we are measuring CPU utilization, then we can save beaucoup
# time by saving the results of the CPU calibration and passing
# them in during the real tests. So, we execute the new CPU "tests"
# of netperf and put the values into shell vars.
case $LOC_CPU in
\-c) LOC_RATE=`$NETHOME/netperf $PORT -t LOC_CPU`;;
*) LOC_RATE=""
esac

case $REM_CPU in
\-C) REM_RATE=`$NETHOME/netperf $PORT -t REM_CPU -H $REM_HOST`;;
*) REM_RATE=""
esac

# this will disable headers
NO_HDR="-P 0"
for SOCKET_SIZE in $SOCKET_SIZES
  do
  for SEND_SIZE in $SEND_SIZES
    do
    echo
    echo ------------------------------------
    echo
    # we echo the command line for cut and paste 
    echo $NETHOME/netperf $PORT -l $TEST_TIME -H $REM_HOST -t $STREAM\
         $LOC_CPU $LOC_RATE $REM_CPU $REM_RATE $STATS_STUFF --\
         -m $SEND_SIZE -s $SOCKET_SIZE -S $SOCKET_SIZE $AFFINITY

    echo
    # since we have the confidence interval stuff, we do not
    # need to repeat a test multiple times from the shell
    $NETHOME/netperf $PORT -l $TEST_TIME -H $REM_HOST -t $STREAM\
    $LOC_CPU $LOC_RATE $REM_CPU $REM_RATE $STATS_STUFF --\
    -m $SEND_SIZE -s $SOCKET_SIZE -S $SOCKET_SIZE $AFFINITY

   done
  done

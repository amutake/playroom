#!/bin/sh

runghc remote-process.hs slave localhost 12000 & \
    runghc remote-process.hs slave localhost 12001 & \
    runghc remote-process.hs slave localhost 12002 & \
    runghc remote-process.hs master localhost 12003

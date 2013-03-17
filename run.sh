#!/bin/bash

R --file=${1} --slave --args ${*:2}


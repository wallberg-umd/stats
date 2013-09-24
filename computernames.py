#!/usr/bin/env python

import fileinput
import re
from collections import defaultdict
import csv

# generate report matching and non-matching computer names based on regex
# map to workstation locations, in preparation for adding Workstation
# Availability to https://github.com/umd-lib/wstrack

# List of [pattern, description, count]
pList = []
isHeader = True
with open('computernames.csv', 'rb') as f:
    for row in csv.reader(f):
        if isHeader:
            isHeader = False
        else:
            row.append(0)
            pList.append(row)

# track computer names that didn't match anything
nomatch = defaultdict(int)

for line in fileinput.input():
    # normalize
    line = line.rstrip()

    # try to match on each pattern
    for p in pList:
        m = re.match(p[0], line, re.IGNORECASE)
        if (m is not None):
            p[2] += 1
            break
    else:
        nomatch[line] += 1

# print the results
print 'Matches'
print '======='
print 'Total: ', sum([p[2] for p in pList])

print ''
print "%-35s  %-25s  %-6s" % ("Description", "Regex", "Count")
print "%-35s  %-25s  %-6s" % ("-"*35, "-"*20, "-"*6)
for p in pList:
    print "%-35s  %-25s  %6d" % (p[1], p[0], p[2])

print ''
print 'Non Matches'
print '==========='
print 'Total: ', len(nomatch)

print ''
print "%-20s  %-5s" % ("Computer Name", "Count")
print "%-20s  %-5s" % ("-"*20, "-"*5)
for line in sorted(nomatch.keys(), key=str.lower):
    print "%-20s  %5d" % (line, nomatch[line])

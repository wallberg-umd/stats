#!/usr/bin/env python

import fileinput
import re

# generate report matching and non-matching computer names based on regex
# map to workstation locations, in preparation for adding Workstation
# Availability to https://github.com/umd-lib/wstrack

# List of [pattern, description, count]
pList = [ 
    ['^libwkmck1f\d+.*$', 'McKeldin Library 1st floor', 0],
    ['^libwkma2f\d+.*$', 'McKeldin Library 2nd floor', 0],
    ['^libwkmb2f\d+.*$', 'McKeldin Library 2nd floor', 0],
    ['^libwkmc2f\d+.*$', 'McKeldin Library 2nd floor', 0],
    ['^libwkmd2f\d+.*$', 'McKeldin Library 2nd floor', 0],
    ['^libwkmck3f\d+.*$', 'McKeldin Library 3rd floor', 0],
    ['^libwkmck4f\d+.*$', 'McKeldin Library 4th floor', 0],
    ['^libwkmck5f\d+.*$', 'McKeldin Library 5th floor', 0],
    ['^libwkmck6f\d+.*$', 'McKeldin Library 6th floor', 0],
    ['^libwkmck7f\d+.*$', 'McKeldin Library 7th floor', 0],

    ['^libwkepsl\d+.*$', 'Engineering Library 1st floor', 0],
    ['^libwkepsl3f\d+.*$', 'Engineering Library 3rd floor', 0],

    ['^libwkchem\d+.*$', 'Chemistry Library 1st floor', 0],
    ['^libwkchem1f\d+.*$', 'Chemistry Library 1st floor', 0],
    ['^libwkchem2f\d+.*$', 'Chemistry Library 2nd floor', 0],
    ['^libwkchem3f\d+.*$', 'Chemistry Library 3rd floor', 0],

    ['^libwknp\d+.*$', 'Nonprint Library 1st floor', 0],

    ['^libwkmd\d+$', 'MARYLANDIA', 0],
    
    ['^libwkpal1f\d+.*$', 'PAL 1st floor', 0],
    ['^libwkpal2f\d+.*$', 'PAL 2nd floor', 0],
    
    ['^libwkart.*$', 'Art Library 1st floor', 0],

    ['^libwkarc.*$', 'Arch Library', 0],
    ]

# track computer names that didn't match anything
nomatch = []

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
        nomatch.append(line)

# print the results
print 'Matches'
print '======='
print 'Total: ', sum([p[2] for p in pList])

print ''
print "%-35s  %-20s  %5s" % ("Description", "Regex", "Count")
print "%-35s  %-20s  %5s" % ("-"*35, "-"*20, "-"*5)
for p in pList:
    print "%-35s  %-20s  %d" % (p[1], p[0], p[2])

print ''
print 'Non Matches'
print '==========='
print 'Total: ', len(nomatch)

for line in nomatch:
    print line

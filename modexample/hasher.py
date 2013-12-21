#!/usr/bin/python

import sys
import os
import hashlib
import json

path = ""
towrite = {}
hash = hashlib.md5()

def PrintHelp():
    print """\nHasher v0.1 is an utility that produces a .txt of MD5 checksums in a folder.
Simply run in a terminal and specify the folder's path as an argument. The .txt will be created
or updated if already existent in the above-mentioned folder."""

def hashfile(afile, hasher, blocksize=65536):
    buf = afile.read(blocksize)
    while len(buf) > 0:
        hasher.update(buf)
        buf = afile.read(blocksize)
    print "    ->" + hasher.hexdigest()
    print ""
    return str(hasher.hexdigest())

def Hash(p):
    print ""
    
    for root, dirs, files in os.walk(p):
        for file in files:
            if file != "hashes.txt":
                print file
                filex = open(os.path.join(p, file))
                # file.read()
                towrite[file] = str(hashfile(filex, hash))

    json.dump(towrite, open(os.path.join(p, 'hashes.txt'), 'w'))

if len(sys.argv) <= 1:
    print "\nTry -h/help arguments for help."

else:
    if sys.argv[1] == "-h" or sys.argv[1] == "help":
        PrintHelp()
    else:
        path = sys.argv[1]
        Hash(path)
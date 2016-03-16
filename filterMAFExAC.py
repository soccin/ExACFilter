#!/usr/bin/env python2.7

import sys
import csv

from portalMAFColumns import PORTAL_MAF_COLS

if len(sys.argv) != 4:
    print >>sys.stderr, "usage: filterMAFExAC.py TITLEFILE IN_MAF OUT_MAF"
    sys.exit(1)

TITLEFILE=sys.argv[1]
IN_MAF=sys.argv[2]
OUT_MAF=sys.argv[3]

def skipComments(fp,commentChar="#"):
    for line in fp:
        if not line.startswith(commentChar):
            yield line

def matchedNormal(r):
    normalClass=sampleClassDb[r["Matched_Norm_Sample_Barcode"]]
    if normalClass=="PoolNormal":
        return False
    elif normalClass=="Normal":
        return True
    else:
        print >>sys.stderr, "ERROR: Invalid Normal Class Value =",normalClass
        print >>sys.stderr, "    Sample =", r["Matched_Norm_Sample_Barcode"]
        print >>sys.stderr, "    MAF rec =", r
        print >>sys.stderr
        raise ValueError("Invalid Normal Class Value")

sampleClassDb=dict()
with open(TITLEFILE) as fp:
    tin=csv.DictReader(fp,delimiter="\t")
    for r in tin:
        sampleClassDb[r["Sample_ID"]]=r["Class"]

infp=skipComments(open(IN_MAF))

with open(OUT_MAF,"wb") as outfp:

    cin=csv.DictReader(infp,delimiter="\t")
    cout=csv.DictWriter(outfp,fieldnames=PORTAL_MAF_COLS,
                        delimiter="\t",lineterminator='\n')
    cout.writeheader()

    for r in cin:
        if r["FILTER"] == "common_variant" and not matchedNormal(r):
            print "FILTERED", r["FILTER"], r["Tumor_Sample_Barcode"], r["Matched_Norm_Sample_Barcode"]
            continue

        rOut={k: r[k] for k in PORTAL_MAF_COLS}
        cout.writerow(rOut)


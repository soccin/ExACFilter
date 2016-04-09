#!/usr/bin/env python2.7

import sys
import csv

if len(sys.argv) != 4:
    print >>sys.stderr, "usage: filterMAFExAC.py ORIG_MAF IN_MAF OUT_MAF"
    sys.exit(1)

#
# Use ORIG_MAF to get the columns to use for output MAF
#

ORIG_MAF=sys.argv[1]
IN_MAF=sys.argv[2]
OUT_MAF=sys.argv[3]

def skipComments(fp,commentChar="#"):
    for line in fp:
        if not line.startswith(commentChar):
            yield line

def matchedNormal(r):
    return r["Mutation_Status"]=="SOMATIC"

origCols=skipComments(open(ORIG_MAF)).next().strip().split("\t")

infp=skipComments(open(IN_MAF))
with open(OUT_MAF,"wb") as outfp:

    cin=csv.DictReader(infp,delimiter="\t")
    outCols=origCols+["Redaction_Source", "exac_filter"]
    if "Redaction_Source" not in origCols:
        outCols=origCols+["Redaction_Source", "exac_filter"]
    else:
        outCols=origCols+["exac_filter"]
    cout=csv.DictWriter(outfp,fieldnames=outCols,delimiter="\t",lineterminator='\n')
    cout.writeheader()

    for r in cin:
        if r["FILTER"] == "common_variant":
            r["exac_filter"]="TRUE"

            if not matchedNormal(r):
                r["Validation_Status"]="REDACTED"
                if "Redaction_Source" in origCols:
                    r["Redaction_Source"]=r["Redaction_Source"]+","+"exact_filter_v1"
                else:
                    r["Redaction_Source"]="exact_filter_v1"

            else:
                if "Redaction_Source" not in origCols:
                    r["Redaction_Source"]=""

        else:
            r["exac_filter"]="FALSE"
            if "Redaction_Source" not in origCols:
                r["Redaction_Source"]=""

        rOut={k: r[k] for k in outCols}
        cout.writerow(rOut)

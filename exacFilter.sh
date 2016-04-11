#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

function usage {
	echo
	echo "exacFilter.sh [-d] GENOME INPUT.MAF OUTPUT.MAF"
	echo "    -d turn on debug mode"
	echo
	echo "Filter for ExAC common variants"
	exit
}

DEBUG="No"
DEBUGOPT=""
while getopts "dh" opt; do
	case $opt in
		d)
			DEBUG="Yes"
			DEBUGOPT="-d"
			;;
		h)
			usage
			;;
		\?)
			usage
			;;
	esac
done

shift $((OPTIND - 1))
if [ "$#" != "3" ]; then
	usage
	exit 1
fi

GENOME=$1
INPUT_MAF=$2
OUTPUT_MAF=$3

case $GENOME in
	b37)

		;;
	*)
		echo "Invalid Genome" $GENOME
		exit 1
		;;
esac


#
# Get a uniq temp directory for scratch
#

TDIR=_scratch_exactFilter_$(uuidgen -t)
mkdir -p $TDIR

$SDIR/annotateMAF.sh $DEBUGOPT $GENOME $INPUT_MAF $TDIR/annotate.maf
$SDIR/filterMAFExAC.py $INPUT_MAF $TDIR/annotate.maf $OUTPUT_MAF

#
# If DEBUG off then cleanup
# 

if [ "$DEBUG" == "No" ]; then
	rm -rf $TDIR
fi


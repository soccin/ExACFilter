#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

function usage {
	echo
	echo "annotateMAF.sh [-d] GENOME INPUT.MAF OUTPUT.MAF"
	echo "    -d turn on debug mode"
	echo
	echo "Take a MAF and annoate it using maf2maf"
	exit
}

#
# Need this version to get the FILTER column
#

VCF2MAF=/opt/common/CentOS_6/vcf2maf/v1.6.6
PERL=/opt/common/CentOS_6/perl/perl-5.22.0/bin/perl
VEPPATH=/opt/common/CentOS_6/vep/v83
MSK_ISOFORMS=$VCF2MAF/data/isoform_overrides_at_mskcc

TABIX_PATH=$(which tabix 2>/dev/null)
if [ "$TABIX_PATH" == "" ]; then
	export PATH=/opt/common/CentOS_6/samtools/samtools-1.2/htslib-1.2.1:$PATH
fi

DEBUG="No"
while getopts "dh" opt; do
	case $opt in
		d)
			DEBUG="Yes"
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
		GENOME=/ifs/depot/assemblies/H.sapiens/b37/b37.fasta
		GENOMEFAI=/ifs/depot/assemblies/H.sapiens/b37/b37.fasta.fai
		;;
	*)
		echo "Invalid Genome" $GENOME
		exit 1
		;;
esac


#
# Get a uniq temp directory for scratch
#

TDIR=_scratch_annotateMAF_$(uuidgen -t)
mkdir -p $TDIR

#
# Make a temp symlink of genome to deal with BIOPERL's
# directory permissions problems.
#

ln -s $GENOME $TDIR/$(basename $GENOME)
ln -s ${GENOME}.fai $TDIR/$(basename $GENOME).fai

echo "Running MAF2MAF ..."
$PERL $VCF2MAF/maf2maf.pl \
    --vep-forks 12 \
    --tmp-dir $TDIR/SOM \
    --vep-path $VEPPATH \
	--vep-data $VEPPATH \
	--ref-fasta $TDIR/$(basename $GENOME) \
	--retain-cols Center,Verification_Status,Validation_Status,Mutation_Status,Sequencing_Phase,Sequence_Source,Validation_Method,Score,BAM_file,Sequencer,Tumor_Sample_UUID,Matched_Norm_Sample_UUID,Caller \
    --custom-enst $MSK_ISOFORMS \
	--input-maf $INPUT_MAF \
	--output-maf $OUTPUT_MAF \
	2> $TDIR/STDERR_VCF2MAF \

ERROR_FLAG=$(egrep "ERROR" $TDIR/STDERR_VCF2MAF)
if [ "$ERROR_FLAG" != "" ]; then
	echo
	echo "FATAL ERROR: annoateMAF.sh::MAF2MAF"
	echo
	echo $ERROR_FLAG
	echo
	echo "SCRATCH DIR = "$TDIR
	echo
	exit 1
fi

echo "done"
if [ "$DEBUG" == "No" ]; then
	rm -rf $TDIR
fi


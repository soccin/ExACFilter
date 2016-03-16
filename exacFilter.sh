#!/bin/bash

MAF=$1

PERL=/opt/common/CentOS_6-dev/perl/perl-5.22.0/bin/perl
VCF2MAF=/opt/common/CentOS_6-dev/vcf2maf/v1.6.5
VEPPATH=/opt/common/CentOS_6/vep/v83
MSK_ISOFORMS=$VCF2MAF/data/isoform_overrides_at_mskcc

GENOME=/ifs/depot/assemblies/H.sapiens/b37/b37.fasta
GENOMEFAI=/ifs/depot/assemblies/H.sapiens/b37/b37.fasta.fai
EXACDB=/ifs/work/socci/Depot/Pipelines/Variant/PostProcess/db/ExAC.r0.3.sites.pass.minus_somatic.vcf.gz


TDIR=_scratch
mkdir -p $TDIR
ln -s $GENOME $TDIR/$(basename $GENOME)
ln -s ${GENOME}.fai $TDIR/$(basename $GENOME).fai

$PERL $VCF2MAF/maf2maf.pl \
    --vep-forks 12 \
    --tmp-dir $TDIR/SOM \
    --vep-path $VEPPATH \
	--vep-data $VEPPATH \
	--ref-fasta $TDIR/$(basename $GENOME) \
	--retain-cols Center,Verification_Status,Validation_Status,Mutation_Status,Sequencing_Phase,Sequence_Source,Validation_Method,Score,BAM_file,Sequencer,Tumor_Sample_UUID,Matched_Norm_Sample_UUID,Caller \
    --custom-enst $MSK_ISOFORMS \
	--input-maf $MAF \
	--output-maf $(basename $MAF | sed 's/.maf//').vep.maf


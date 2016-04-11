# exacFilter.sh

## Summary

Filter (flag) common variants using the currated ExAC database. This script takes in a MAF and will add two columns additional columns:

* `exact_filter`: set to TRUE or FALSE depending on whether this event has been marked as a common variant by the ExAC filter in vcf2maf

* `Redaction_Source`: set to `exact_filter_v1` if the event is to be redacted. 

If an event is a common variant and the sample is not paired against a matched normal (SOMATIC_VS_POOL) then the event is marked for redaction by setting:

```r
Validation_Status <- REDACTED
```

If the sample is paired to a matched normal then the event is not marked for redaction but the exac_filter is still set to TRUE


Here is a list of all possible states of the various affected columns.

Validation_Status | Mutation_Status | Redaction_Source | exac_filter
------------------|-----------------|------------------|------------
 | SOMATIC |  | FALSE
 | SOMATIC |  | TRUE
 | SOMATIC_VS_POOL |  | FALSE
REDACTED | SOMATIC_VS_POOL | exact_filter_v1 | TRUE

## Usage:

```
exacFilter.sh [-d] GENOME INPUT.MAF OUTPUT.MAF
    -d turn on debug mode
```

Currently the only supported genome is b37. Turning on debug mode keeps temporary files from being deleted. 

# plasmidEC
Ensemble of binary plasmid classification tools

## Running the ensemble classifier

For first time use, edit the main script (ensemble_classifier.sh) to include the path to your conda installation.
This is required for installing and activating the conda environments used.

As input, the ensemble classifier takes assembly files with a .fasta extension. Currently only SPAdes type headers are supported.

Arguments:

-i      Path to input directory

-t      Names of the tools to be used, in lowercase, separated by a comma and in any order. Choose three from: mlplasmids, plascope, platon, rfplasmid.

Example:
```
bash ensemble_classifier.sh -i testdata -t mlplasmids,plascope,platon
```

## Output

The combined predictions can be found in the final_output.csv file. For each contig, it contains the individual prediction per tool, the total number of plasmid predictions, and the final result.

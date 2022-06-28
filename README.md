<p align="center">
<img src="plasmidEC_logo.svg" alt="logo_package" width="600">
</p>

PlasmidEC is an ensemble of plasmid classification tools.

PlasmidEC runs multiple binary classification tools that predict the origin of contigs (plasmid or chromosome). For each contig, it outputs the prediction given by the majority of the tools. PlasmidEC outcompetes individual classifiers, especially for contigs that contain antibiotic resistance genes. 

PlasmidEC is currently available for _E. coli_, _K. pneumoniae_, _A. baumannii_, _S. enterica_, _P. aeruginosa_, _E. faecium_, _E. faecalis_ and _S. aureus_

# Table of contents
* [Requirements](#requirements)
* [Supported tools](#Supported tools)
* [Installation](#installation)


# Requirements
Clone plasmidEC from github:
```
git clone https://github.com/lisavader/plasmidEC.git
```
# Supported tools
- [mlplasmids](https://gitlab.com/sirarredondo/mlplasmids)
- [PlaScope](https://github.com/labgem/PlaScope)
- [Platon](https://github.com/oschwengers/platon)
- [RFPlasmid](https://github.com/aldertzomer/RFPlasmid)

# Installation
Clone plasmidEC from github:
```
git clone https://github.com/lisavader/plasmidEC.git
```
Upon first time usage, plasmidEC will automatically install its dependencies via conda and download the databases used by the tools. The only prerequisite is a conda installation.

## Usage
```
$ bash plasmidEC.sh -h
usage: bash plasmidEC.sh [-i INPUT] [-o OUTPUT] [options]

Mandatory arguments:
  -i INPUT              input .fasta file
  -o OUTPUT             output directory

Optional arguments:
  -h                    display this help message and exit
  -c CLASSIFIERS        classifiers to be used, in lowercase and separated by a comma (default = plascope,platon,rfplasmid)
  -t THREADS            nr. of threads used by PlaScope, Platon and RFPlasmid (default = 8)
  -g                    write gplas formatted output
  -f                    force overwriting of output dir
  -v                    display version nr. and exit
```

Example:
```
bash plasmidEC.sh -i testdata/SRR6985737.fasta -o SRR6985737
```
The combination of PlaScope, Platon and RFPlasmid gives the best results for _E. coli_. It is therefore recommended to stick to this default!

## Output

- ensemble_output.csv: Main table containing the predictions made by each individual classifier, the total nr. of plasmid votes and the majority predictions.
- plasmid_contigs.fasta: Sequences of all contigs predicted to originate from plasmids.
- all_predictions.csv: Concatenated predictions of the individual classifiers (intermediate file, can be ignored)

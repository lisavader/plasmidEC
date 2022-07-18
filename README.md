<p align="center">
<img src="plasmidEC_logo.svg" alt="logo_package" width="600">
</p>

PlasmidEC is an ensemble of plasmid classification tools.

PlasmidEC runs multiple binary classification tools that predict the origin of contigs (plasmid or chromosome). For each contig, it outputs the prediction given by the majority of the tools. PlasmidEC outcompetes individual classifiers, especially for contigs that contain antibiotic resistance genes. 

## Table of contents
* [Requirements](#requirements)
* [Supported tools](#supported-tools)
* [Installation](#installation)
* [Usage](#usage)  
* [Output files](#output-files)
* [Compatibility with gplas](#compatibility-with-gplas)
* [Acknowledgements](#acknowledgements)

## Requirements
The only requirement to run plasmidEC is a conda installation (V > 4.10.3).

## Supported tools
- [mlplasmids](https://gitlab.com/sirarredondo/mlplasmids)
- [PlaScope](https://github.com/labgem/PlaScope)
- [Platon](https://github.com/oschwengers/platon)
- [RFPlasmid](https://github.com/aldertzomer/RFPlasmid)

## Installation
Clone plasmidEC from github:
```
git clone https://github.com/lisavader/plasmidEC.git
```
Upon first time usage, plasmidEC will automatically install its dependencies via conda and download the databases used by the tools. The only prerequisite is a conda installation.

## Usage

#### Quick usage
Out of the box, plasmidEC can be used to predict plasmid contigs of _E. coli_, _K. pneumoniae_, _A. baumannii_, _S. enterica_, _P. aeruginosa_, _E. faecium_, _E. faecalis_ and _S. aureus_. You must specify the species using the **-s** flag.

```
bash plasmidEC.sh -i testdata/SRR6985737.fasta -o SRR6985737 -s "Escherichia coli"
```
#### Other species
It is possible to use plasmidEC for other species. However, the following steps will need to be completed:
- 1. A Plascope model for the desired species will have to be constructed. The location and name of this model is specified by using the **-p** and **-d** flags. Instructions on how to do this can be found [here](https://github.com/labgem/PlaScope).
- 2. An appropiate model for RFPlasmid will need to be selected with the **-r** flag. RFPlasmid can make plasmid predictions for different [genera](https://github.com/aldertzomer/RFPlasmid/blob/master/specieslist.txt). If you genera is not listed, we recommend using the 'General' model.

#### All options
```
$ bash plasmidEC.sh -h
usage: bash plasmidEC.sh [-i INPUT] [-o OUTPUT] [options]

Mandatory arguments:
  -i INPUT              input .fasta file
  -o OUTPUT             output directory

Optional arguments:
  -h                    Display this help message and exit.
  -c CLASSIFIERS        Classifiers to be used, in lowercase and separated by a comma.
  -s SPECIES            Select one of the pre-loaded species ("Escherichia coli", "Klebsiella pneumoniae", "Acinetobacter baumannii", "Salmonella enterica", "Pseudomonas aeruginosa", "Entrococcus faecium", "Enterococcus faecalis", "Staphylococcus aureus").
  -t THREADS            nr. of threads used by PlaScope, Platon and RFPlasmid (default = 8).
  -p plascope DB path   Full path for a custom plascope DB. Needed for using plasmidEC with species other than pre-loaded species. Not compatible with -s.
  -d plascope DB name   Name of the custom plascope DB. Not compatible with -s.
  -r rfplasmid model    Name of the rfplasmid model selected. Needed for using plasmidEC with species other than pre-loaded species. Not compatible with -s.
  -g                    Write gplas formatted output.
  -m                    Use minority vote to classify contigs as plasmid-derived.
  -f                    Force overwriting of output dir.
  -v                    Display version nr. and exit.
```

## Output Files

- ensemble_output.csv: Main table containing the predictions made by each individual classifier, the total nr. of plasmid votes and the final classification for each contig.
- plasmid_contigs.fasta: Sequences of all contigs predicted to originate from plasmids.
- all_predictions.csv: Concatenated predictions of the individual classifiers (intermediate file, can be ignored)

## Compatibility with gplas

[gplas](https://gitlab.com/mmb-umcu/gplas) is a tool to bin plasmid-predicted contigs based on sequence
composition, coverage and assembly graph information. Gplas accurately bins predicted plasmid contigs into individual plasmid predictions.

By using the **-g** flag, plasmidEC provides it's output in a format that is compatible with gplas. This output will be located in:

${output}/**gplas_format**/${file_name}_plasmid_prediction.tab. 

## Acknowledgements

Lisa Vader: Original design, implementation and testing for _Escherichia coli_.

Julian Paganini: Gplas compatibility, implementation and testing for multiple species.

Jesse Kerkvliet: Construction of custom Plascope databases, testing for multiple species.

Anita Schürch: Design, testing and project supervision.

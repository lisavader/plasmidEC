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
    * [Input](#input)
    * [Quick usage](#quick-usage)
    * [Compatibility with gplas](#compatibility-with-gplas)
    * [Other species](#other-species)
    * [All options](#all-options)   
* [Output files](#output-files)
* [Acknowledgements](#acknowledgements)

## Requirements
The only requirement to run plasmidEC is a conda installation (V >= 4.10.3).

## Supported tools
- [mlplasmids](https://gitlab.com/sirarredondo/mlplasmids)
- [PlaScope](https://github.com/labgem/PlaScope)
- [Platon](https://github.com/oschwengers/platon)
- [RFPlasmid](https://github.com/aldertzomer/RFPlasmid)

## Installation
Clone plasmidEC from github:
```
git clone https://github.com/jpaganini/plasmidEC-1.git
```
Move to the new directory:
```
cd plasmidEC-1
```
Run plasmidEC:
```
bash plasmidEC.sh -i testdata/E_coli_test.fasta -o E_coli_test -s "Escherichia coli"
```
Upon first time usage, plasmidEC will automatically install its dependencies via conda and download the databases used by the tools. 

## Usage

### Input

As input, plasmidEC takes assembled contigs in **.fasta** format **or** an assembly graph in **.gfa** format. Such files can be obtained
with [SPAdes genome assembler](https://github.com/ablab/spades) or with [Unicycler](https://github.com/rrwick/Unicycler).

### Quick usage
Out of the box, plasmidEC can be used to predict plasmid contigs of _E. coli_, _K. pneumoniae_, _A. baumannii_, _S. enterica_, _P. aeruginosa_, _E. faecium_, _E. faecalis_ and _S. aureus_. You must specify the species using the **-s** flag. For example:

```
bash plasmidEC.sh -i testdata/K_pneumoniae_test.fasta -o K_pneumoniae_test -s "Klebsiella pneumoniae"
```
### Compatibility with gplas

-[gplas](https://gitlab.com/mmb-umcu/gplas) is a tool that accurately bins predicted plasmid contigs into individual plasmids.

-By using the **-g** flag, plasmidEC provides an extra output file that can be directly used as an input for gplas. 

-For optimal performance of this feature, we advise to use an assembly graph (in **.gfa** format) as an input for plasmidEC. See an example command below:

```
bash plasmidEC.sh -i testdata/E_coli_graph.gfa -o E_coli_gplas -s "Escherichia coli" -g
```
The gplas-compatible output is a **tab separated** file, located at: ${output}/**gplas_format**/${file_name}_plasmid_prediction.tab. See an example below:

```
head -n 10 E_coli_gplas/gplas_format/E_coli_graph_plasmid_prediction.tab
```

| Prob\_Chromosome | Prob\_Plasmid | Prediction | Contig\_name                              | Contig\_length |
| ---------------- | ------------- | ---------- | ----------------------------------------- | -------------- |
| 1                | 0             | Chromosome | S1\_LN:i:346767\_dp:f:0.9966562474408179  | 346767         |
| 1                | 0             | Chromosome | S10\_LN:i:175297\_dp:f:0.9360667247742771 | 175297         |
| 0.33             | 0.67          | Plasmid    | S100\_LN:i:1076\_dp:f:2.530236029051145   | 1076           |
| 1                | 0             | Chromosome | S101\_LN:i:1066\_dp:f:1.9988380278126159  | 1066           |
| 1                | 0             | Chromosome | S102\_LN:i:1030\_dp:f:2.0266855175827887  | 1030           |
| 1                | 0             | Chromosome | S11\_LN:i:173576\_dp:f:1.0807318234217165 | 173576         |
| 1                | 0             | Chromosome | S12\_LN:i:165545\_dp:f:1.0925719220847394 | 165545         |
| 1                | 0             | Chromosome | S13\_LN:i:158764\_dp:f:1.074893837075452  | 158764         |
| 1                | 0             | Chromosome | S14\_LN:i:154045\_dp:f:1.0326640429970195 | 154045         |


### Other species
It is possible to use plasmidEC for other species. However, the following steps will need to be completed:
- 1. A Plascope model for the desired species will have to be constructed. The location and name of this model is specified by using the **-p** and **-d** flags. Instructions on how to do this can be found [here](https://github.com/labgem/PlaScope).
- 2. An appropiate model for RFPlasmid will need to be selected with the **-r** flag. RFPlasmid can make plasmid predictions for different [genera](https://github.com/aldertzomer/RFPlasmid/blob/master/specieslist.txt). If you genera is not listed, we recommend using the 'General' model.

### All options
```
$ bash plasmidEC.sh -h
usage: bash plasmidEC.sh [-i INPUT] [-o OUTPUT] [options]

Mandatory arguments:
  -i INPUT              input .fasta or .gfa file
  -o OUTPUT             output directory

Optional arguments:
  -h                    Display this help message and exit.
  -c CLASSIFIERS        Classifiers to be used, in lowercase and separated by a comma.
  -s SPECIES            Select one of the pre-loaded species ("Escherichia coli", "Klebsiella pneumoniae", "Acinetobacter baumannii", "Salmonella enterica", "Pseudomonas aeruginosa", "Enterococcus faecium", "Enterococcus faecalis", "Staphylococcus aureus").
  -l LENGTH             Minimum length of contigs to be classified (default = 1000).
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

#### ensemble_output.csv
Main table containing the predictions made by each individual classifier, the total nr. of plasmid votes and the final classification for each contig.

```
head -n 5 E_coli_test/ensemble_output.csv
```

| Contig\_name                              | Genome\_id  | RFPlasmid  | PlaScope   | Platon     | Plasmid\_count | Combined\_prediction |
| ----------------------------------------- | ----------- | ---------- | ---------- | ---------- | -------------- | -------------------- |
| S1\_LN:i:346767\_dp:f:0.9966562474408179  | test\_ecoli | chromosome | chromosome | chromosome | 0              | chromosome           |
| S10\_LN:i:175297\_dp:f:0.9360667247742771 | test\_ecoli | chromosome | chromosome | chromosome | 0              | chromosome           |
| S100\_LN:i:1076\_dp:f:2.530236029051145   | test\_ecoli | chromosome | plasmid    | plasmid    | 2              | plasmid              |
| S101\_LN:i:1066\_dp:f:1.9988380278126159  | test\_ecoli | chromosome | chromosome | chromosome | 0              | chromosome           |

#### plasmid_contigs.fasta
Sequences of all contigs predicted to originate from plasmids in FASTA format.

```
grep '>' E_coli_test/plasmid_contigs.fasta
```
```
>S100_LN:i:1076_dp:f:2.530236029051145
>S37_LN:i:27545_dp:f:2.647645845987835
>S48_LN:i:11456_dp:f:1.4507819940318725
>S49_LN:i:10551_dp:f:1.3637191943487739
>S50_LN:i:9676_dp:f:1.5011735328773061
>S51_LN:i:9084_dp:f:2.6932550771872323
>S52_LN:i:9015_dp:f:2.60828989990341
>S54_LN:i:7604_dp:f:1.4886167382316031
>S57_LN:i:5200_dp:f:1.3890819886029557
>S66_LN:i:3439_dp:f:4.183650771596276
>S68_LN:i:3023_dp:f:2.589395047594386
>S71_LN:i:2870_dp:f:2.5799908536557314
>S72_LN:i:2817_dp:f:1.0382821435571183
>S74_LN:i:2600_dp:f:0.9782899464745628
>S76_LN:i:2354_dp:f:7.237618987589864
>S79_LN:i:2186_dp:f:1.0429091447800045
>S82_LN:i:1893_dp:f:1.3296811087334817
>S83_LN:i:1690_dp:f:3.7257036197991673
>S84_LN:i:1663_dp:f:1.3388510964667213
>S90_LN:i:1457_dp:f:2.515760144942872
>S94_LN:i:1316_dp:f:4.11423204293813
>S96_LN:i:1240_dp:f:1.415327303861984
>S98_LN:i:1164_dp:f:2.8587537599848356
>S99_LN:i:1076_dp:f:1.4379818048479307
```
### all_predictions.csv
Concatenated predictions of the individual classifiers (intermediate file).

```
head -n 5 E_coli_test/all_predictions.csv
```
|                                           |            |          |               |
| ----------------------------------------- | ---------- | -------- | ------------- |
| S7\_LN:i:209197\_dp:f:1.060027589194678   | chromosome | plascope | E\_coli\_test |
| S1\_LN:i:346767\_dp:f:0.9966562474408179  | chromosome | plascope | E\_coli\_test |
| S10\_LN:i:175297\_dp:f:0.9360667247742771 | chromosome | plascope | E\_coli\_test |
| S9\_LN:i:197587\_dp:f:1.094028026559923   | chromosome | plascope | E\_coli\_test |
| S2\_LN:i:341820\_dp:f:1.0689129784313414  | chromosome | plascope | E\_coli\_test |

## Acknowledgements

Lisa Vader: Original design, implementation and testing for _Escherichia coli_.

Julian Paganini: Gplas compatibility, implementation and testing for multiple species.

Jesse Kerkvliet: Construction of custom Plascope databases, testing for multiple species.

Anita Schürch: Design, testing and project supervision.


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
- [mlplasmids](https://gitlab.com/mmb-umcu/gplas)
- [PlaScope](https://github.com/labgem/PlaScope)
- [Platon](https://github.com/oschwengers/platon)
- [RFPlasmid](https://github.com/aldertzomer/RFPlasmid)

# DEBRIS
**DEBRIS** is a deep learning-based model that can classify local features and identify steady events and dynamically emerging events within two-color single-molecule traces of varying lengths based on user-defined criteria. 

**_MATLAB_** source codes for fragment simulation, deep learning network training, and single-molecule fluorescence event identification for four different scenarios presented in our study are offered. 

Paper can be found at: (lastest link of the paper)

The user manual of DEBRIS can be found in **'DEBRIS_MATLAB_code_V1.1'** branch or the supplementary information at the (lastest link of the paper)

The example data for testing of DEBRIS can be found in **'Example_data_V1.1'** branch.

## System requirements

We conducted training, validation, and testing using MATLAB (version: 9.13.0, R2022b) on a PC with an Intel Xeon W2223 CPU and an NVIDIA GeForce RTX 3090 GPU.

Compatibility: Windows 10/11 with MATLAB (R2022b) or later version. 
Additional toolboxes required for MATLAB to run DEBRIS:
1. Signal Processing Toolbox
2. Deep Learning Toolbox
3. Parallel Computing Toolbox (TM)
## DEBRIS usage
Please download the ‘DEBRIS_code’ folder of latest version from https://github.com/CHENChunlai-CN/DEBRIS.git.

We have integrated DERBIS pattern prediction and criterion-based classification into the main 'DEBRIS.m' file. This allows user-friendly automatic prediction and classification by simply adjusting the parameters and calling the corresponding functions directly.

## Code version
DEBRIS_code_V1.1 was released on October 16<sup>th</sup>, 2024.

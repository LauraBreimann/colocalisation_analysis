# colocalisation_analysis
Scripts to analyse co-localisation

## How to install:

1. Clone or download the repository.

2. Install the environment by opening a terminal/command prompt in the same folder as environment.yml and running:
```
conda env create -f environment.yml
```
3. Activate the environment:

```
conda activate spot-compare-env
```
4. Confirm installation by running:
```
conda list
```
You should see numpy, pandas, scipy, jupyterlab, ipykernel, etc.


## Step 1: Extract single tif files from Picoquant images

Use the Fiji script ```resave_single_tif.ijm``` to resave images that have a second empty frame. The script keeps the first frame of the images and saves them as 16-bit single-slice images in a new folder. 


## Step 2: Save single files as a multi-channel tif

Use the Fiji script ```resave_as_multichannel.ijm``` to save the single tif files from step 1 as a multichannel image. The script searches for the same name stem to group images together. 


## Step 3: Register multichannel images 

Use the Python script 


## Step 4: Detect sturcutres using RS-FISH

Use [RS-FISH](https://github.com/PreibischLab/RS-FISH) manually to determine the parameters for good detection. Use the script ```RS-FISH_macro.ijm``` to batch detect spots/structures in similar images. 


## Step 5: Compare localization distances

Use the script ```analyse_two_lists.ipynb``` to analyze the localization lists from two structures. 

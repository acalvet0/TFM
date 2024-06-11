**Master's Thesis Code Repository**

**Title:** A Classification Model Approach to Brain Imaging: Understanding Fear Conditioning 

---

This repository contains the following codes used for the development of the master's thesis:

- `apply_brain_signatures.m`: Script to apply the different brain signatures selected to our data (entire sample and test set for subsequent validation with our signature).

- `SVM_create_sig.m`: Script to develop the multivariate model with SVM using our signature.

- `barplot_columns_angels.m`: CANlab script modified to customize the plotting of violin plots according to our preferences.

- `neursynth.py`: Script to convert the weight map to z-scores for passing through Neurosynth. Script for generating word clouds of correlations with terms provided by Neurosynth.

- `brainmask_canlab_bin_resampled.nii`: Mask used in all analyses to consider only voxels within the brain.

- `gray_matter_mask_canlab_bin_resampled_lineal_bin.nii`: Gray matter mask used to identify the most significant voxels in the bootstrapping process.

- `MVPA_dataset.xlsx`: List of participants with their clinical variables.

- `brainsignatures`: folder with the maps of the brain signatures selected.

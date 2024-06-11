#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 10 15:46:27 2024

@author: acalvet
"""

import nibabel as nib
import scipy
import seaborn as sns
in_file = "/Users/acalvet/Documents/MVPA_FISAX/TFM_git/results/final_brainmask/2_SVM_results_stai/svm_results_unthresholded.nii"
msk_file = "/Users/acalvet/Documents/MVPA_FISAX/TFM_git/brainmask_canlab_bin_resampled.nii"
data = nib.load(in_file)
mat = data.get_fdata()
msk = nib.load(msk_file)
msk_img = msk.get_fdata()
mat[msk_img == 1] = scipy.stats.zscore(mat[msk_img == 1])


# zmat = scipy.stats.zscore(mat)


nib.save(nib.Nifti1Image(mat, data.affine), "/Users/acalvet/Documents/MVPA_FISAX/TFM_git/results/final_brainmask/2_SVM_results_stai/svm_results_unthresholded_zscore.nii")




from wordcloud import WordCloud, STOPWORDS, ImageColorGenerator
# Create WordCloud object
wc = WordCloud(
    background_color='white',
    width=700,
    height=150,
    margin=2,
    prefer_horizontal=1,
    relative_scaling=0.6,
    colormap='viridis'
)
# Define text based on Neurosynth functional terms from the decoding
text = {
    'emotional': 0.092, 'facial': 0.082, 'expressions': 0.079, 'neutral faces': 0.071,
    'fearful': 0.07,'fear': 0.068, 'verbs': 0.064, 'happy': 0.064, 'PTSD': 0.062,
    'emotions': 0.061, 'angry': 0.06, 'intentions': 0.058, 'ratings': 0.057,
    'threatening': 0.055, 'emotional stimulu': 0.055, 'syntactic': 0.054, 'aversive': 0.053
}
# Generate the word cloud from the text data
wc.fit_words(text)
# Save the word cloud to an image file
wc.to_file('/Users/acalvet/Documents/MVPA_FISAX/TFM_git/results/final_brainmask/2_SVM_results_stai/Terms.png')




text = {
    'periqueductal': 0.109, 'PSTS': 0.108, 'posterior superior': 0.108, 'temporal sulcus': 0.099,
    'amygdala': 0.078, 'thalamus': 0.077, 'STS': 0.07, 'inferior frontal': 0.07, 'superior temporal': 0.06,
    'hypothalamus': 0.06, 'anterior insula': 0.056
}
# Generate the word cloud from the text data
wc.fit_words(text)
# Save the word cloud to an image file
wc.to_file('/Users/acalvet/Documents/MVPA_FISAX/TFM_git/results/final_brainmask/2_SVM_results_stai/Terms_anat.png')
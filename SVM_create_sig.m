clear; clc;
basedir = '/Users/acalvet/Documents/MVPA_FISAX';
contdirs = dir(fullfile(basedir, 'contrasts'));
list_subj = {contdirs([contdirs.isdir]).name};
list_subj = list_subj(~ismember(list_subj, {'.', '..'}));
CSp_paths = fullfile(basedir, 'contrasts', list_subj, 'REVERSAL', 'FIRST_LEVEL_REVERSAL_Half_ALL', 'con_0011.nii');
CSm_paths = fullfile(basedir, 'contrasts', list_subj, 'REVERSAL', 'FIRST_LEVEL_REVERSAL_Half_ALL', 'con_0012.nii');

maskdir = fullfile(basedir, 'brainmask_bin0.nii');

%% 1. Training (80%) and test (20%) sets
pat_exp_conditioning = readtable(fullfile(basedir, 'plots', 'plots_signatures_brainmask_bin0', 'all_cond_pat_exp.xlsx'),'VariableNamingRule','preserve');
edges = quantile(pat_exp_conditioning.("Threat_CS+"), 25);
val_stratify = discretize(pat_exp_conditioning.("Threat_CS+"), [-inf, edges, inf]);
C = cvpartition(val_stratify, 'HoldOut', 0.2, 'Stratify', true);

training_data = fmri_data([CSp_paths(training(C)); CSm_paths(training(C))], maskdir); 
training_data.Y = [ones(sum(training(C)),1); -ones(sum(training(C)),1)];

test_data = fmri_data([CSp_paths(test(C)); CSm_paths(test(C))], maskdir); 
test_data.Y = [ones(sum(test(C)),1); -ones(sum(test(C)),1)];

%% 2. Developing classifiers of CS+ and CS-
cvind = 10;
[~, stats_10fold] = predict(training_data, 'algorithm_name', 'cv_svm', 'nfolds', cvind, 'error_type', 'mcr', 'dist_from_hyperplane_xval'); 
% mcr: misclassification rate 'dist_from_hyperplane_xval 

% Visualizing results (pattern expression)
orthviews(stats_10fold.weight_obj);
sig = stats_10fold.weight_obj;
sig.fullpath = fullfile(basedir,'svm_results_unthresholded.nii');
write(sig);
ROC_10fold = roc_plot(stats_10fold.dist_from_hyperplane_xval, training_data.Y == 1, 'threshold', 'pairedobservations');

%% 3. Feature-level assessment - Stability (Bootstrap)
[~, stats_boot] = predict(training_data, 'algorithm_name', 'cv_svm', 'nfolds', 1, 'error_type', 'mcr', 'bootweights', 'bootsamples', 5000, 'useparallel', 1);
boots_threshold = threshold(stats_boot.weight_obj, .05, 'fdr');

% Visualizing bootstrap test results
orthviews(boots_threshold);
boots_threshold.fullpath = fullfile(basedir, 'svm_bootstrap_fdr05.nii');
write(boots_threshold, 'thresh');
% brain_activations_display(region(boots_threshold, 'contiguous_regions'), 'surface_only', 'colorbar');

clear; clc;
basedir = '.';
savedir = fullfile(basedir, 'results', '2_SVM_results_stai');
contdirs = dir(fullfile(basedir, 'contrasts'));
list_subj = {contdirs([contdirs.isdir]).name};
list_subj = list_subj(~ismember(list_subj, {'.', '..'}));
CSp_paths = fullfile(basedir, 'contrasts', list_subj, 'REVERSAL', 'FIRST_LEVEL_REVERSAL_Half_ALL', 'con_0011_mask.nii');
CSm_paths = fullfile(basedir, 'contrasts', list_subj, 'REVERSAL', 'FIRST_LEVEL_REVERSAL_Half_ALL', 'con_0012_mask.nii');

maskdir = fullfile(basedir, 'brainmask_canlab_bin_resampled.nii');
graydir = fullfile(basedir, 'gray_matter_mask_canlab_bin_resampled_lineal_bin.nii');

%% 1. Training (80%) and test (20%) sets
data_excel = readtable(fullfile(basedir, 'MVPA_dataset_new.xlsx'),'VariableNamingRule','preserve');
data_excel(174,:) = [];
data_excel(173,:) = [];
subj_names = cellfun(@(str) ['sub-' str], data_excel.ID, 'UniformOutput', false);
data_excel.Properties.RowNames = subj_names;
validSubjects_var = ismember(subj_names, list_subj);

edges = quantile(data_excel.STAI_T_A, 5);
val_stratify = discretize(data_excel.STAI_T_A, [-inf, edges, inf]);
nan_val = find(isnan(val_stratify));
s = 3;
for n = 1:length(nan_val)
    val_stratify(nan_val(n)) = s;
    if s < 6
        s = s + 1;
    else
        s = 1;
    end
end
C = cvpartition(val_stratify, 'HoldOut', 0.2, 'Stratify', true);
tr_set = training(C);
ts_set = test(C);
save(fullfile(savedir, 'training_data.mat'), 'tr_set')
save(fullfile(savedir, 'test_data.mat'), 'ts_set')

training_data = fmri_data([CSp_paths(tr_set), CSm_paths(tr_set)], maskdir); 
training_data.Y = [ones(sum(tr_set),1); -ones(sum(tr_set),1)];

test_data = fmri_data([CSp_paths(ts_set), CSm_paths(ts_set)], maskdir); 
test_data.Y = [ones(sum(ts_set),1); -ones(sum(ts_set),1)];

%% 2. Developing classifiers of CS+ and CS-
% Leave-one-subject-out cross-validation
subject_id = [1:138, 1:138];

[~, stats_CV] = predict(training_data, 'algorithm_name', 'cv_svm', 'nfolds', subject_id, 'error_type', 'mcr', 'dist_from_hyperplane_xval'); 
% mcr: misclassification rate 'dist_from_hyperplane_xval

% Visualizing results (pattern expression)
orthviews(stats_CV.weight_obj);
sig = stats_CV.weight_obj;
sig.fullpath = fullfile(savedir, 'svm_results_unthresholded.nii');
write(sig);
ROC_CV = roc_plot(stats_CV.dist_from_hyperplane_xval, training_data.Y == 1, 'threshold', 'pairedobservations');

%% 3. Feature-level assessment - Stability (Bootstrap)
[~, stats_boot] = predict(training_data, 'algorithm_name', 'cv_svm', 'nfolds', 1, 'error_type', 'mcr', 'bootweights', 'bootsamples', 5000, 'useparallel', 1);
boots_threshold_graymask = threshold(stats_boot.weight_obj, .05, 'fdr', 'mask', graydir);

% Visualizing bootstrap test results
orthviews(boots_threshold_graymask);
boots_threshold_graymask.fullpath = fullfile(savedir, 'svm_bootstrap_fdr05_GM.nii');
write(boots_threshold_graymask, 'thresh');

% Some other lines to make the plots
cl = region(boots_threshold_graymask); % Number of clusters of each region
res = array2table(zeros(0, 3), 'VariableNames', {'Nvox', 'mm3', 'mStatEff'});
for c = 1:length(cl)
    res{num2str(c), 'Nvox'} = cl(c).numVox;
    res{num2str(c), 'mm3'} = 27*cl(c).numVox; % 3x3x3 = 27mm3/voxel
    res{num2str(c), 'mStatEff'} = mean(cl(c).val);
end
writetable(res, fullfile(savedir, 'clusters_boot.xlsx'), 'WriteRowNames', true);

table(cl, load_atlas('canlab2023_fmriprep20_2mm'))
o2 = montage(select_atlas_subset(atl, {'Ctx_3b_L', 'Ctx_7m_R', 'Ctx_PHT_L', 'Ctx_PF_L'}));
% print regions where we have significative results

o2 = montage(boots_threshold_graymask);
o2 = multi_threshold(boots_threshold_graymask, 'thresh', [.001 .005 .01]);

%% Plot Train - Test set
training_subj = load(fullfile(savedir, 'training_data.mat')).tr_set;
test_subj = load(fullfile(savedir, 'test_data.mat')).ts_set;

data_excel = readtable(fullfile(basedir, 'MVPA_dataset_new.xlsx'),'VariableNamingRule','preserve');
data_excel(174,:) = [];
data_excel(173,:) = [];

train_data = data_excel.STAI_T_A(training_subj);
train_data(isnan(train_data)) = -3;
test_data = data_excel.STAI_T_A(test_subj);
test_data(isnan(test_data)) = -3;

figure;
subplot(1,2,1);
histogram(train_data);
title('Training set distribution (N = 138)');
xlabel('STAI - T score');
ylabel('Frequency');
axis([-4 45 0 27.25])
set(gca, 'FontSize', 18)
subplot(1,2,2);
histogram(test_data);
title('Test set distribution (N = 34)');
xlabel('STAI - T score');
ylabel('Frequency');
axis([-4 45 0 7.25])
set(gca, 'FontSize', 18)
x0=500; y0=500; width=1500; height=400;
set(gcf,'position', [x0, y0, width, height])

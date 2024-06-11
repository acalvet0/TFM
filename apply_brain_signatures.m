clear; clc;
basedir = fullfile('.');
save_results = fullfile(basedir, 'results', '1_sig_evaluation'); % 3_sig_evaluation_test
maskdir = fullfile('.', 'brainmask_canlab_bin_resampled.nii');

contdirs = dir(fullfile('.', 'contrasts'));
subj_names = {contdirs([contdirs.isdir]).name};
subj_names = subj_names(~ismember(subj_names, {'.', '..'}))';

contrast_files = {{'con_0011_mask'; 'con_0012_mask'}, {'con_0013_mask'; 'con_0014_mask'; 'con_0015_mask'; 'con_0016_mask'}, ...
    {'con_0017_mask'; 'con_0018_mask'}};
contrast_names = {{'CS+', 'CS-'}, {'CS+early', 'CS+late', 'CS-early', 'CS-late'}, ...
    {'CS+rev', 'CS-rev'}};

metric = 'dot_product';
evaluation = 0; 
% 0 = evaluation of selected signatures (all data)
% 1 = evaluation of selected signatures + our in the test set
%% Load brain signatures
[threat, ] = load_image_set({fullfile('.', 'brainsignatures', 'IE_ImEx_Acq_Threat_SVM_nothresh.nii')});
[suitas, ] = load_image_set({fullfile('.', 'brainsignatures', 'Induced20_z.nii')});
[pines, ] = load_image_set({fullfile('.', 'brainsignatures', 'Rating_Weights_LOSO_2.nii')});
[vifs, ] = load_image_set({fullfile('.', 'brainsignatures', 'VIFS.nii')});

if evaluation == 1
    own_sig = fmri_data(fullfile(basedir, '2_SVM_results_stai', 'svm_results_unthresholded.nii'), maskdir);
    signatures = {own_sig, threat, suitas, pines, vifs};
    sig_names = {'Our_sig', 'Threat', 'SUITAS', 'PINES', 'VIFS'};

    test_subj = load(fullfile(basedir, '2_SVM_results_stai', 'test_data.mat')).ts_set;
    subj_names = subj_names(test_subj);
else
    signatures = {threat, suitas, pines, vifs};
    sig_names = {'Threat', 'SUITAS', 'PINES', 'VIFS'};
end

%% Calculate pattern expression and save results
for C = 1:length(contrast_files)
    clear data_obj_orig pat_exp res_pat_exp res_ttest res_2AFC contrast_file contrast_name col row_names;
    contrast_file = contrast_files{C};
    contrast_name = contrast_names{C};
    if contains(contrast_name{1}, 'rev'); rev = 'rev'; else; rev = ''; end
    if contains(contrast_name{1}, 'early'); ea = 'earlylate'; else; ea = ''; end
    % Calculate pattern expression
    for i = 1:length(contrast_file)
        path_img = fullfile('.', 'contrasts_brainmask', subj_names, 'REVERSAL', 'FIRST_LEVEL_REVERSAL_Half_ALL', [contrast_file{i} '.nii']);
        data_obj_orig = fmri_data(path_img, maskdir);
    
        for s = 1:length(signatures)
            data_obj = resample_space(data_obj_orig, signatures{s});
            pe(:, s) = canlab_pattern_similarity(data_obj.dat, signatures{s}.dat, metric);
        end
        pat_exp{i} = pe;
    end
    % Table for pattern expression values
    i = 1;
    j = 1;
    for sig = sig_names
        for name = contrast_name
            col{i} = [sig{1} '_' name{1}];
            i = i + 1;
        end
        if length(contrast_name) > 2 % early/late = {'CS+early', 'CS+late', 'CS-early', 'CS-late'}
            col{i} = [sig{1} '_' contrast_name{1} '_' contrast_name{2} '_diff'];
            i = i + 1;
            row_names{j} = [sig{1} '_' contrast_name{1} '_' contrast_name{2}];
            j = j + 1;
            col{i} = [sig{1} '_' contrast_name{3} '_' contrast_name{4} '_diff'];
            i = i + 1;
            row_names{j} = [sig{1} '_' contrast_name{3} '_' contrast_name{4}];
            j = j + 1;
        else
            col{i} = [sig{1} '_diff'];
            i = i + 1;
        end
    end
    res_pat_exp = array2table(zeros(length(subj_names), length(col)), 'VariableNames', col);
    res_pat_exp.Properties.RowNames = subj_names;
    
    % Table for t-test and 2-alternative forced-choice results
    if length(contrast_name) == 2
        row_names = sig_names;
        colors = {[.4 .6 1], [1 1 0]};
    else  % early/late
        colors = {[.4 .6 1], [0 0 .7], [1 1 0], [1 .7 0]};
    end
    
    res_ttest = array2table(zeros(length(row_names), 7), 'VariableNames', {'p', 'ci_l', 'ci_h', 'tstat', 'df', 'sd', 'cohend'});
    res_ttest.Properties.RowNames = row_names;
    res_2AFC = array2table(zeros(length(row_names), 3), 'VariableNames', {'TP', 'N', 'acc'});
    res_2AFC.Properties.RowNames = row_names;
    
    for s = 1:length(sig_names)
        pat_exp_s = cellfun(@(x) x(:, s), pat_exp, 'UniformOutput', false); 
        figure;
        barplot_columns_angels(pat_exp_s, 'nofigure', 'colors', colors, 'names', contrast_name, 'dolines');
        set(gca, 'FontSize', 20)
        ylabel(strrep(metric, '_', ' '));
        title(strrep([metric ' ' sig_names{s} ', CS+ CS-' ea ' ' rev], '_', ' '))
        x0=10; y0=10; width=1200; height=1000;
        set(gcf,'position', [x0, y0, width, height])
        saveas(gcf, fullfile(save_results, ['CS+CS-' rev ea '_' sig_names{s} '.png']))
    
        % Pattern expression
        if length(contrast_name) == 2
            res_pat_exp{:, [sig_names{s} '_' contrast_name{1}]} = pat_exp_s{1};
            res_pat_exp{:, [sig_names{s} '_' contrast_name{2}]} = pat_exp_s{2};
        else
            res_pat_exp{:, [sig_names{s} '_' contrast_name{1}]} = pat_exp_s{1};
            res_pat_exp{:, [sig_names{s} '_' contrast_name{2}]} = pat_exp_s{2};
            res_pat_exp{:, [sig_names{s} '_' contrast_name{3}]} = pat_exp_s{3};
            res_pat_exp{:, [sig_names{s} '_' contrast_name{4}]} = pat_exp_s{4};
        end
    end
    for r = 1:length(row_names)
        if length(contrast_name) == 2
            pat_exp_s = cellfun(@(x) x(:, r), pat_exp, 'UniformOutput', false);
        elseif r == 1 || r == 2
            pat_exp_s = cellfun(@(x) x(:, 1), pat_exp, 'UniformOutput', false);
        elseif r == 3 || r == 4
            pat_exp_s = cellfun(@(x) x(:, 2), pat_exp, 'UniformOutput', false);
        elseif r == 5 || r == 6
            pat_exp_s = cellfun(@(x) x(:, 3), pat_exp, 'UniformOutput', false);
        elseif r == 7 || r == 8
            pat_exp_s = cellfun(@(x) x(:, 4), pat_exp, 'UniformOutput', false);
        end
        % Paired-sample t-test (within-subjects t-test)
        if contains(row_names{r}, ['-' rev 'early']) && contains(row_names{r}, ['-' rev 'late'])
            [h, res_ttest{row_names{r}, 'p'}, ci, stats] = ttest(pat_exp_s{3}, pat_exp_s{4});
            diff_val = pat_exp_s{3} - pat_exp_s{4};
        else
            [h, res_ttest{row_names{r}, 'p'}, ci, stats] = ttest(pat_exp_s{1}, pat_exp_s{2});
            diff_val = pat_exp_s{1} - pat_exp_s{2};
        end
        res_ttest{row_names{r}, 'ci_l'} = ci(1);
        res_ttest{row_names{r}, 'ci_h'} = ci(2);
        res_ttest{row_names{r}, 'tstat'} = stats.tstat;
        res_ttest{row_names{r}, 'df'} = stats.df;
        res_ttest{row_names{r}, 'sd'} = stats.sd;
        % + Cohen's d
        res_ttest{row_names{r}, 'cohend'} = mean(diff_val) / std(diff_val);
    
        % 2-alternative forced choice (2AFC)
        if strcmp(ea, 'earlylate')
            res_2AFC(row_names{r}, :) = [];
        else
            res_2AFC{row_names{r}, 'TP'} = sum(diff_val>0); % CS+ - CS- > 0
            res_2AFC{row_names{r}, 'N'} = length(diff_val);
            res_2AFC{row_names{r}, 'acc'} = res_2AFC{row_names{r}, 'TP'}/res_2AFC{row_names{r}, 'N'};
        end
    
        % Pattern expression difference
        res_pat_exp{:, [row_names{r} '_diff']} = diff_val;
    end
    
    writetable(res_pat_exp, fullfile(save_results, ['CS+CS-' rev ea '_pat_exp.xlsx']), 'WriteRowNames', true);
    writetable(res_ttest, fullfile(save_results, ['CS+CS-' rev ea '_ttest.xlsx']), 'WriteRowNames', true);
    if strcmp(ea, '')
        writetable(res_2AFC, fullfile(save_results, ['CS+CS-' rev ea '_2AFC.xlsx']), 'WriteRowNames', true);
    end
end
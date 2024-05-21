clear; clc;
basedir = '.';
save_results = fullfile(basedir, 'results', 'brainmask_bin0'); %

contdirs = dir(fullfile(basedir, 'contrasts'));
subj_names = {contdirs([contdirs.isdir]).name};
subj_names = subj_names(~ismember(subj_names, {'.', '..'}))';

contrasts_file = {{'con_0011'; 'con_0012'}, {'con_0013'; 'con_0014'; 'con_0015'; 'con_0016'}, ...
    {'con_0017'; 'con_0018'}, {'con_0019'; 'con_0020'; 'con_0021'; 'con_0022'}};
contrasts_name = {{'CS+', 'CS-'}, {'CS+early', 'CS+late', 'CS-early', 'CS-late'}, ...
    {'CS+rev', 'CS-rev'}, {'CS+revearly', 'CS+revlate', 'CS-revearly', 'CS-revlate'}};

metric = 'dot_product';
%% Load brain signatures
[threat, ] = load_image_set({fullfile(basedir, 'brainsignatures', 'IE_ImEx_Acq_Threat_SVM_nothresh.nii')});
[suitas, ] = load_image_set({fullfile(basedir, 'brainsignatures', 'Induced20_z.nii')});
[pines, ] = load_image_set({fullfile(basedir, 'brainsignatures', 'Rating_Weights_LOSO_2.nii')});
[vifs, ] = load_image_set({fullfile(basedir, 'brainsignatures', 'VIFS.nii')});
signatures = {threat, suitas, pines, vifs};
sig_names = {'Threat', 'SUITAS', 'PINES', 'VIFS'};

%% Calculate pattern expression and save results
for C = 1:length(contrasts_file)
    clear pat_exp res_pat_exp res_ttest res_2AFC contrast_file contrast_name;
    contrast_file = contrasts_file{C};
    contrast_name = contrasts_name{C};
    if contains(contrast_name{1}, 'rev'); rev = 'rev'; else; rev = ''; end
    if contains(contrast_name{1}, 'early'); ea = 'earlylate'; else; ea = ''; end
    % Calculate pattern expression
    clear pat_exp res_pat_exp res_ttest res_2AFC;
    for i = 1:length(contrast_file)
        path_img = fullfile(basedir, 'contrasts', subj_names, 'REVERSAL', 'FIRST_LEVEL_REVERSAL_Half_ALL', [contrast_file{i} '.nii']);
        data_obj_orig = fmri_data(path_img, fullfile(basedir, 'brainmask_bin0.nii'));
    
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
        if length(contrast_name) > 2 % early/late
            col{i} = [sig{1} '_' contrast_name{1} '_' contrast_name{2} '_diff'];
            i = i + 1;
            row_names{j} = [sig{1} '_' contrast_name{1} '_' contrast_name{2}];
            j = j + 1;
            col{i} = [sig{1} '_' contrast_name{3} '_' contrast_name{4} '_diff'];
            i = i + 1;
            row_names{j} = [sig{1} '_' contrast_name{3} '_' contrast_name{4}];
            j = j + 1;
            col{i} = [sig{1} '_' contrast_name{1} '_' contrast_name{3} '_diff'];
            i = i + 1;
            row_names{j} = [sig{1} '_' contrast_name{1} '_' contrast_name{3}];
            j = j + 1;
            col{i} = [sig{1} '_' contrast_name{2} '_' contrast_name{4} '_diff'];
            i = i + 1;
            row_names{j} = [sig{1} '_' contrast_name{2} '_' contrast_name{4}];
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
        colors = {[1 0 0], [0 1 0]};
    else  % early/late
        colors = {[1 0 0], [0 1 0], [0 0 1], [1 1 0]};
    end
    
    res_ttest = array2table(zeros(length(row_names), 7), 'VariableNames', {'p', 'ci_l', 'ci_h', 'tstat', 'df', 'sd', 'cohend'});
    res_ttest.Properties.RowNames = row_names;
    res_2AFC = array2table(zeros(length(row_names), 3), 'VariableNames', {'TP', 'N', 'acc'});
    res_2AFC.Properties.RowNames = row_names;
    
    for s = 1:length(sig_names)
        pat_exp_s = cellfun(@(x) x(:, s), pat_exp, 'UniformOutput', false);
        figure;
        barplot_columns(pat_exp_s, 'nofigure', 'colors', colors, 'names', contrast_name, 'dolines');
        set(gca, 'FontSize', 14)
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
        elseif r == 1 || r == 2 || r == 3 || r == 4
            pat_exp_s = cellfun(@(x) x(:, 1), pat_exp, 'UniformOutput', false);
        elseif r == 5 || r == 6 || r == 7 || r == 8
            pat_exp_s = cellfun(@(x) x(:, 2), pat_exp, 'UniformOutput', false);
        elseif r == 9 || r == 10 || r == 11 || r == 12
            pat_exp_s = cellfun(@(x) x(:, 3), pat_exp, 'UniformOutput', false);
        elseif r == 13 || r == 14 || r == 15 || r == 16
            pat_exp_s = cellfun(@(x) x(:, 4), pat_exp, 'UniformOutput', false);
        end
        % Paired-sample t-test (within-subjects t-test)
        if contains(row_names{r}, '-early') && contains(row_names{r}, '-late')
            [h, res_ttest{row_names{r}, 'p'}, ci, stats] = ttest(pat_exp_s{3}, pat_exp_s{4}, 'Tail', 'right');
            diff_val = pat_exp_s{3} - pat_exp_s{4};
        elseif contains(row_names{r}, '+early') && contains(row_names{r}, '-early')
            [h, res_ttest{row_names{r}, 'p'}, ci, stats] = ttest(pat_exp_s{1}, pat_exp_s{3}, 'Tail', 'right');
            diff_val = pat_exp_s{1} - pat_exp_s{3};
        elseif contains(row_names{r}, '+late') && contains(row_names{r}, '-late')
            [h, res_ttest{row_names{r}, 'p'}, ci, stats] = ttest(pat_exp_s{2}, pat_exp_s{4}, 'Tail', 'right');
            diff_val = pat_exp_s{2} - pat_exp_s{4};
        else
            [h, res_ttest{row_names{r}, 'p'}, ci, stats] = ttest(pat_exp_s{1}, pat_exp_s{2}, 'Tail', 'right');
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
        res_2AFC{row_names{r}, 'TP'} = sum(diff_val>0); % CS+ - CS- > 0
        res_2AFC{row_names{r}, 'N'} = length(diff_val);
        res_2AFC{row_names{r}, 'acc'} = res_2AFC{row_names{r}, 'TP'}/res_2AFC{row_names{r}, 'N'};
    
        % Pattern expression difference
        res_pat_exp{:, [row_names{r} '_diff']} = diff_val;
    end
    
    writetable(res_pat_exp, fullfile(save_results, ['CS+CS-' rev ea '_pat_exp.xlsx']), 'WriteRowNames', true);
    writetable(res_ttest, fullfile(save_results, ['CS+CS-' rev ea '_ttest.xlsx']), 'WriteRowNames', true);
    writetable(res_2AFC, fullfile(save_results, ['CS+CS-' rev ea '_2AFC.xlsx']), 'WriteRowNames', true);
end
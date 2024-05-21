% Script to correlate brain pattern expressions with clinical variables
% Mapes: 4 signatures x CS+, CS-, CS+ early, CS+ late, CS- early, CS- late,
% CS+ rev, CS- rev, CS+ rev early, CS+ rev late, CS- rev early, CS- rev late 
% (12) = 48 files! x 16 variables cliniques
% ALL DATA
% WOMEN / MEN
clear; clc;
basedir = '.';
save_results = fullfile(basedir, 'results', 'brainmask_bin0'); %
sig_names = {'Threat', 'SUITAS', 'PINES', 'VIFS'};

data_var = readtable(fullfile(basedir, 'Clinical_data_variables.xlsx'));
contdirs = dir(fullfile(basedir, 'contrasts'));
subj_names = {contdirs([contdirs.isdir]).name};
subj_names = subj_names(~ismember(subj_names, {'.', '..'}))';

for data_ana = {'all', 'Woman', 'Man'}
    if strcmp(data_ana{1}, 'all')
        cli_var = data_var;
    else
        cli_var = data_var(strcmp(data_var.Sex, data_ana{1}), :);
    end
    % Check subjects that have both fMRI and clinical data
    list_subj = cellfun(@(str) ['sub-' str], cli_var.ID, 'UniformOutput', false);
    cli_var.Properties.RowNames = list_subj;
    validSubjects_var = ismember(list_subj, subj_names);
    cli_var = cli_var(validSubjects_var, :);
    
    % Upload pattern expression values extracted previously
    pat_exp_cond = readtable(fullfile(save_results, 'all_cond_pat_exp.xlsx'),'VariableNamingRule','preserve');
    pat_exp_rev = readtable(fullfile(save_results, 'all_rev_pat_exp.xlsx'),'VariableNamingRule','preserve');
    validSubjects_pat = ismember(subj_names, list_subj);
    pat_exp_cond = pat_exp_cond(validSubjects_pat, :);
    pat_exp_rev = pat_exp_rev(validSubjects_pat, :);
    
    corr_R = table();
    corr_P = table();
    for sig = sig_names
        for typ = {'condidioning', 'reversal'}
            if strcmp(typ{1}, 'conditioning'); pat_exp = pat_exp_cond; rev = ''; else; pat_exp = pat_exp_rev; rev = 'rev'; end
            for cont = {['CS+' rev], ['CS-' rev], ['CS+' rev 'early'], ['CS+' rev 'late'], ['CS-' rev 'early'], ['CS-' rev 'late']}
                for var = cli_var.Properties.VariableNames(4:19)
                    if iscell(cli_var{:, var{1}})
                        in_data = [pat_exp{:, [sig{1} '_' cont{1}]}, str2double(cli_var{:, var{1}})];
                        [R, P] = corrcoef(rmmissing(in_data));
                    else
                        in_data = [pat_exp{:, [sig{1} '_' cont{1}]}, cli_var{:, var{1}}];
                        [R, P] = corrcoef(rmmissing(in_data));
                    end
                    corr_R{[sig{1} '_' cont{1}], var{1}} = R(1,2);
                    corr_P{[sig{1} '_' cont{1}], var{1}} = P(1,2);
                end
            end
        end
    end
    writetable(corr_R, fullfile(save_results, ['correlations_R_' data_ana{1} '.xlsx']), 'WriteRowNames', true);
    writetable(corr_P, fullfile(save_results, ['correlations_P_' data_ana{1} '.xlsx']), 'WriteRowNames', true);
    
    % Visualize with heatmap
    % Correlation coefficient
    h = heatmap(table2array(corr_R));
    colormap('jet'); % parula
    h.XDisplayLabels = cellfun(@(x) strrep(x, '_', ' '), corr_R.Properties.VariableNames, 'UniformOutput', false);
    h.YDisplayLabels = cellfun(@(x) strrep(x, '_', ' '), corr_R.Properties.RowNames, 'UniformOutput', false);
    h.XLabel = 'Clinical variable';
    h.YLabel = 'Signature - contrast';
    h.Title = 'CORRELATIONS coefficient';
    % clim([-1, 1]);
    clim([-max(max(abs(table2array(corr_R)))), max(max(abs(table2array(corr_R))))]);
    
    % Correlations p-val
    h = heatmap(table2array(corr_P));
    cmap = flipud(hot);
    colormap(cmap);
    h.XDisplayLabels = cellfun(@(x) strrep(x, '_', ' '), corr_P.Properties.VariableNames, 'UniformOutput', false);
    h.YDisplayLabels = cellfun(@(x) strrep(x, '_', ' '), corr_P.Properties.RowNames, 'UniformOutput', false);
    h.XLabel = 'Clinical variable';
    h.YLabel = 'Signature - contrast';
    h.Title = 'CORRELATIONS pval';
    clim([min(min(table2array(corr_P))), 0.06]);
end
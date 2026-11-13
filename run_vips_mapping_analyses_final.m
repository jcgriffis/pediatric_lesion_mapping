function run_vips_mapping_analyses_final(beh_col, min_stroke_age, min_test_age, min_test_interval, confounds)

% Add paths to relevant functions
cfg.model_dir = '/Shared/boeslab/Users/jcgriffis/ibb_modeling_toolkit/model_code'; 
addpath(genpath(fullfile(cfg.model_dir, 'common'))); 

% Get brain mask
cfg.mask_path = fullfile('/Shared/boeslab/Atlas/volumetric/MNI152/2mm/masks/wholecb_maskSmooth.nii.gz');

% Get VIPS dataset
project_dir = '/Shared/boeslab/Users/jcgriffis/vips_psom_mapping';
beh_csv = readtable(fullfile(project_dir, 'behavior', 'vips_combined_31226.csv'), 'Format', 'auto');
beh_csv = beh_csv(beh_csv.stroke_age >= min_stroke_age,:);
beh_csv = beh_csv(beh_csv.test_age >= min_test_age,:);
beh_csv = beh_csv(beh_csv.yrs2test >= min_test_interval, :);
beh_csv = beh_csv(beh_csv.has_lesion == 1,:);

% Get default model cfg for analysis type
cfg.model_spec = 'municorr';
cfg.cor_type = 'Spearman';
cfg.modality = 'lesion';
cfg.permutation = 1;
cfg.fit_explanatory_model = 1;
cfg = get_default_model_cfg(cfg);
cfg.min_obs = 1;
cfg.freq_thresh = 5;

% Get imaging data
id_col = 'orig_id';
if strcmp(beh_col, 'contra_motor') 
    lesion_dir = '/Shared/boeslab/Data/Lesion/SickKids/lesionMasksNativePlusFlipped/MNI152/2mm';
else
    lesion_dir = '/Shared/boeslab/Data/Lesion/SickKids/lesionMasks/MNI152/2mm';
end
cfg = get_and_format_lesion_data(beh_csv, id_col, beh_col, 0, lesion_dir, cfg);

% Subset rows
beh_csv = beh_csv(cfg.include_inds,:);

% Get LH and RH lesion volumes
cfg.lh_vol = beh_csv.lh_vol;
cfg.rh_vol = beh_csv.rh_vol;

% Restrict analyses if indicated
if confounds == 1
    cfg.confounds = [zscore(cfg.lh_vol), zscore(cfg.rh_vol), zscore(beh_csv.stroke_age), zscore(beh_csv.yrs2test)];    
end

% Set permutation iterations
cfg.perm.n_perm = 5000;

% Set output directory
if confounds == 1
    suffix = '_partial';
else
    suffix = '_full';
end
modality = 'lesion';
suffix = [suffix '_minfreq' num2str(cfg.freq_thresh)];
cfg.out_dir = fullfile(project_dir, 'results_mapping_71626', ['min_stroke_' num2str(min_stroke_age) '_min_test_' num2str(min_test_age) '_min_interval_' num2str(min_test_interval)], beh_col, [cfg.model_spec '_' modality suffix]);

% Run analysis
model_results = fit_and_evaluate_model(cfg);

% Get maps
write_model_weight_maps(model_results);  

end
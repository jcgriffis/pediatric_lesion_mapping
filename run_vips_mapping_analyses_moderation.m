function run_vips_mapping_analyses_moderation(beh_col, min_stroke_age, min_test_age, min_test_interval)

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
cfg.model_spec = 'munimnr';
cfg.modality = 'lesion';
cfg.permutation = 1;
cfg.fit_explanatory_model = 1;
cfg = get_default_model_cfg(cfg);
cfg.min_obs = 1;
cfg.freq_thresh = 10;

% Get imaging data
id_col = 'orig_id';
if strcmp(beh_col, 'contra_motor') || strcmp(beh_col, 'worst_motor') || strcmp(beh_col, 'total_motor')
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

% Confounds
cfg.confounds = [zscore(cfg.lh_vol), zscore(cfg.rh_vol), zscore(beh_csv.stroke_age), zscore(beh_csv.yrs2test)];

% Interaction test options
cfg.test_interaction = 1; % test ineraction
cfg.int_term = 3; % compute interaction of lesion status with age

% Recode outcome, flip to make reference group unimpaired
Y = zeros(size(cfg.Y,1),1);
Y(cfg.Y==0)=4;
Y(cfg.Y==0.5)=3;
Y(cfg.Y==1)=2;
Y(cfg.Y==2)=1;
cfg.Y = Y; 

% Set permutation iterations
cfg.perm.n_perm = 1000;

% Set output directory
modality = 'lesion';
cfg.out_dir = fullfile(project_dir, 'results_moderation_71626', ['minstrokeage' num2str(min_stroke_age) '_mintest' num2str(min_test_age)], beh_col, [cfg.model_spec '_' modality]);

% Run analysis
model_results = fit_and_evaluate_model(cfg);

% Get maps
write_model_weight_maps(model_results);
cd(cfg.out_dir);
   
end


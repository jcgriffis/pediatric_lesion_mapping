function mdl_ind = fit_mnr_models(beh_csv, outcome)

    % Fit candidate models
    mdl4 = fitmnr(beh_csv, [outcome ' ~ stroke_age + yrs2test + lh_vol + rh_vol + lh_vol*stroke_age + rh_vol*stroke_age'], 'ModelType','ordinal');
    mdl3= fitmnr(beh_csv, [outcome ' ~ stroke_age + yrs2test + lh_vol + rh_vol + lh_vol*stroke_age'], 'ModelType','ordinal');    
    mdl2 = fitmnr(beh_csv, [outcome ' ~ stroke_age + yrs2test + lh_vol + rh_vol + rh_vol*stroke_age'], 'ModelType','ordinal');    
    mdl1 = fitmnr(beh_csv, [outcome ' ~ stroke_age + yrs2test + lh_vol + rh_vol'], 'ModelType','ordinal');    
    
    % Get and compare BICs
    BIC = [mdl1.ModelCriterion.BIC mdl2.ModelCriterion.BIC mdl3.ModelCriterion.BIC mdl4.ModelCriterion.BIC];    
    [~, mdl_ind] = min(BIC);

end
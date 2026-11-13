function run_cfx_analysis(mdl, me_ind, int_ind, z_vals, xlabels, my_color)

% Conditional effects analyses

% Get simple slopes
b_me = mdl.Coefficients.Value(me_ind);
b_int = mdl.Coefficients.Value(int_ind);
s_slps = b_me+(b_int*z_vals);

% Get effect indices
idx_X = me_ind; 
idx_XZ = int_ind;  

var_X = mdl.CoefficientCovariance(idx_X, idx_X);
var_XZ = mdl.CoefficientCovariance(idx_XZ, idx_XZ);
cov_X_XZ = mdl.CoefficientCovariance(idx_X, idx_XZ);

% Calculate standard error and Z-statistic for each simple slope value
for i = 1:length(z_vals)
    z = z_vals(i);
    var_slope = var_X + (z^2)*var_XZ + 2*z*cov_X_XZ;
    se_slope = sqrt(var_slope);
    se_slope_arr(i) = se_slope;
    z_stat = s_slps(i) / se_slope;
    p_val(i) = 2 * (1 - normcdf(abs(z_stat))); 
    fprintf('Z = %.2f: Slope = %.4f, SE = %.4f, p = %.4f\n', z, s_slps(i), se_slope, p_val(i));
end

% Get aORs and CIs
aor_slope = exp(s_slps);
me_vals = 1.96*se_slope_arr;
ci_lo = s_slps - me_vals;
ci_hi = s_slps + me_vals;
ci_lo = exp(ci_lo);
ci_hi = exp(ci_hi);

% Plot results
% clf;
errorbar(1:length(z_vals), aor_slope, aor_slope-ci_lo, ci_hi-aor_slope, 'Color', my_color, 'Marker', '.', 'MarkerSize', 25, 'MarkerFaceColor', 'k');
xlim([0, length(z_vals)+1]);
set(gca, 'Xtick', 1:1:length(z_vals));
set(gca, 'XtickLabel', xlabels);
set(gca, 'FontSize', 11);
grid on;
ylabel('aOR');
box off; set(gcf, 'position', [0, 0, 425, 250]); 

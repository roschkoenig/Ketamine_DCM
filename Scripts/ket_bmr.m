%% Analysing repetition effects using Bayesian model reduction
%==========================================================================
% This code uses Bayesian model reduction in order to identify the best
% explanation for the observed repetition effects across a defined model
% space
% As one model clearly wins across different subjects, in a second step,
% Bayesian Parameter Averaging (BPA) is performed to summarise the
% group-level coupling changes underlying repetition

% Housekeeping
%==========================================================================
clear all
D = ket_housekeeping;

% Unpack housekeeping files
%--------------------------------------------------------------------------
Fbase     	= D.Fbase;
Fspm        = D.Fspm;
Fdata       = D.Fdata;
Fanalysis   = D.Fanalysis;
Fbmr        = D.Fbmr;
GMFile      = D.GMFile;
sub         = D.sub;
fs          = filesep;

[rep_lin, rep_non] = ket_bmr_gen_model_space();

%% Generate BMR structure
%%=========================================================================
% Load inverted first level placebo models
%--------------------------------------------------------------------------
files = cellstr(spm_select('FPList', [Fanalysis fs 'Individual'], '^*.mat'));
clear DCM X M 
count = 0;

for f = 2:2:length(files)
    count = count + 1;
    TCM = load(files{f});
    FCM{count} = TCM.DCM;
end

% For each subject, generate reduced submodels to run BMR over
%--------------------------------------------------------------------------
for d = 1:length(FCM)
count = 1;

% Generate DCM structure for BMR - just monophasic/linear
% -------------------------------------------------------------------------
for l = 1:length(rep_lin)
    DCM = ket_bmr_gen(rep_lin{l}, rep_non{1}, Fbmr);          
    P{d,count} = DCM;
    count = count + 1;
end

% Generate DCM structure for BMR - just phasioc/non-linear
% -------------------------------------------------------------------------
for l = 1:length(rep_lin)
    DCM = ket_bmr_gen(rep_lin{1}, rep_non{l}, Fbmr);        
    P{d,count} = DCM;
    count = count + 1;
end

% Generate DCM structure for BMR - monophasic and phasic
% -------------------------------------------------------------------------
for l = 1:length(rep_lin)
    DCM = ket_bmr_gen(rep_lin{l}, rep_non{l}, Fbmr);          
    P{d,count} = DCM;
    count = count + 1;
end

% Replace the last model with the inverted model previously loaded
%--------------------------------------------------------------------------
P{d,end} = FCM{d};
end

% Run BMR andn return reduced models (RCM), comparison (BMC), average (BMA)
%==========================================================================
[RCM, BMC, BMA] = spm_dcm_bmr(P);

% Plot results of Bayesian model comparison
%==========================================================================
figure
F = [BMC.F]';
Fm = mean(F,1);
Fm = Fm - min(Fm);

Fsort = sort(Fm);
dF    = Fsort(end) - Fsort(end-1);

bar(Fm)
title(['Bayesian model evidence for repetition effects across individuals: dF = ' num2str(dF)]);
xlabel('Models: 0, F, B, FB +/- I for linear, nonlinear or both rep effects');
ylabel('Free energy');


%% Perform Bayesian Parameter averaging to review group results
%==========================================================================
% As there was clear evidence for the same model architecture explaining
% the repetition effects in each subjects, we can perform Bayesian
% parameter averaging to identify robust changes across the different
% individual DCMs explaining the repetition effect

% Load fully inverted DCMs into single cell array
%--------------------------------------------------------------------------
files = cellstr(spm_select('FPList', [Fanalysis fs 'Individual'], '^*.mat'));
clear DCM X M 
count = 0;

for f = 2:2:length(files)
    count = count + 1;
    TCM = load(files{f});
    FCM{count} = TCM.DCM;
end

BPA = spm_dcm_bpa(FCM);

% Extract expected values (Ep) and covariances (Cp) from BPA
%--------------------------------------------------------------------------
Cp  = spm_unvec(BPA.Cp, BPA.Ep);

BE  = BPA.Ep.B;
NE  = BPA.Ep.N;
BC  = Cp.B;
NC  = Cp.N;

% Reconstruct effects in each condition
%--------------------------------------------------------------------------
fwd = [3,1; 4,2; 5,3; 6,4];
bwd = flip(fwd,2);

conds = BPA.xU.X;
for c = 1:size(conds,1)
for f = 1:size(fwd,1)
    
    % Extract forward connections
    %----------------------------------------------------------------------
	EFwd(c,f)   = conds(c,1) * BE{1}(fwd(f,1), fwd(f,2)) + conds(c,2) * BE{2}(fwd(f,1), fwd(f,2));
    CFwd(c,f)   = abs(conds(c,1) * BC{1}(fwd(f,1), fwd(f,2)) + conds(c,2) * BC{2}(fwd(f,1), fwd(f,2)));

	% Extract backward connections
    %----------------------------------------------------------------------
    EBwd(c,f)   = conds(c,1) * BE{1}(bwd(f,1), bwd(f,2)) + conds(c,2) * BE{2}(bwd(f,1), bwd(f,2));
    CBwd(c,f)   = abs(conds(c,1) * BC{1}(bwd(f,1), bwd(f,2)) + conds(c,2) * BC{2}(bwd(f,1), bwd(f,2)));

end

for i = 1:2
    
	% Extract intrinsic connections
    %----------------------------------------------------------------------    
    EInt(c,i)   = conds(c,1) * NE{1}(i,i) + conds(c,2) * NE{2}(i,i);
    CInt(c,f)   = abs(conds(c,1) * NC{1}(i,i) + conds(c,2) * NC{2}(i,i));
    
end
end

% Plot Parameter changes across conditions
%--------------------------------------------------------------------------
labels = {'D1', 'S2', 'S6', 'S36'};
figure
subplot(1,3,1), spm_plot_ci(mean(EFwd,2), sum(CFwd,2), [], [], 'exp');
    title('Forward Connections');
    set(gca, 'XTickLabel', labels);
    
subplot(1,3,2), spm_plot_ci(mean(EBwd,2), sum(CBwd,2), [], [], 'exp');
    title('Backward Conections');
    set(gca, 'XTickLabel', labels);
    
subplot(1,3,3), spm_plot_ci(mean(EInt,2), sum(CInt,2), [], [], 'exp');
    title('Modulatory Self-Connections (A1 level)');
    set(gca, 'XTickLabel', labels);
    
set(gcf, 'color', 'w', 'Position', [300 300 800 300]);


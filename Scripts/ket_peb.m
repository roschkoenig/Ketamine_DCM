%% Ketamine DCM analysis using Parametric Empirical Bayes
%==========================================================================
% This runs the second step of a two-level DCM analysis, modelling and 
% parameter changes induced by katemine. It requires the full inversions of
% the first level DCMs to be available

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


%% Run PEB Analysis
%==========================================================================
% This section sets up the between-DCM (2nd level) models, and runs PEB
% recursively over a model space specified in terms of which parameters
% contribute to explaining between-DCM variance. 
% The winning model is then explored further by using Bayesian model
% reduction to identify parameter changes related to the main effect of
% ketamine (effect 2 here)
% This code will produce 
%       1) Figure of Bayesian model comparison at the second level
%       2) The parameterised winning second level model (PEB{11})
%       3) A set of first level DCMs after second level inversion (RCM)
%       4) A Bayesian model average of the second level model after
%          exhaustive parameter seard (RMA)

clear DCM X M

% Load files into single cell array
%--------------------------------------------------------------------------
files = cellstr(spm_select('FPList', [Fanalysis fs 'Individual'], '^*.mat'));
for f = 1:length(files)
    TCM = load(files{f});
    DCM{f} = TCM.DCM;
end

% Main Group Effect
%--------------------------------------------------------------------------
X(:,1)  = ones(1,length(DCM));


% Main Effect of Ketamine
%--------------------------------------------------------------------------
% This encodes the doses of ketamine: 0 = placebo, 1 = low, 2 = high dose
%--------------------------------------------------------------------------
X(:,2)  = [2 0 2 0 2 0 1 0 1 0 2 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 2 0 2 0 1 0];


% Subject specific variation
%--------------------------------------------------------------------------
% This model component is used to model between-subhect variations as
% random effects of not interest 
%--------------------------------------------------------------------------
subfx = zeros(length(DCM), length(sub));
for p = 1:length(sub)
    subfx([1:2] + 2*(p-1), p) = [1 1];
end
X   = [X, subfx];

M.X = X;
M.Xnames{1}     = 'Group';
M.Xnames{2}     = 'Ketamine';
for s = 1:length(sub)
    M.Xnames{2+s} = sub(s);
end

% Reduced models: Only extrinsic parameters
%--------------------------------------------------------------------------
C{1} = {'A'};   % All extrinsic 
C{2} = {'B'};   % All extrinsic condition specific effects
C{3} = {'A', 'B'};  % All extrinsic and conditional
C{4} = {'A{1}(3,1)', 'A{1}(4,2)', 'A{1}(5,3)', 'A{1}(6,4)', 'A{2}(3,1)', 'A{2}(4,2)', 'A{2}(5,3)', 'A{2}(6,4)'}; % Forward
C{5} = {'A{3}(1,3)', 'A{3}(2,4)', 'A{3}(3,5)', 'A{3}(4,6)', 'A{4}(1,3)', 'A{4}(2,4)', 'A{4}(3,5)', 'A{4}(4,6)'}; % Backward
C{6} = {'B{1}(3,1)', 'B{1}(4,2)', 'B{1}(5,3)', 'B{1}(6,4)'};    % Forward conditional
C{7} = {'B{1}(1,3)', 'B{1}(2,4)', 'B{1}(3,5)', 'B{1}(4,6)'};    % Backward conditional

% Reduced models: Only intrinsic model parameters
%--------------------------------------------------------------------------
C{8} = {'M'};       % Modulatory
C{9} = {'N'};       % Modulatory conditional
C{10} = {'M', 'N'}; % Modulatory and condition specific effects
C{11} = {'G'};      % Intrinsic
C{12} = {'T'};      % Time constants
C{13} = {'M', 'N', 'G'};        % Intrinsic coupling
C{14} = {'M', 'N', 'G', 'T'};   % all intrinsic

labels = { 'A', 'B', 'A,B', 'A(Fwd)', 'A(Bwd)', 'B(Fwd)', 'B(Bwd)', ...
           'M', 'N', 'M,N', 'G', 'T', 'M,N,T', 'M,N,T,G', 'all' };
clear PEB F

%% Run PEB recursively over the set of reduced models defined in 'C'
%--------------------------------------------------------------------------
for c = 1:length(C)
    PEB{c} = spm_dcm_peb(DCM', M, C{c});
    F(c)   = PEB{c}.F;
end

%% Plot Bayesian model comparison between reduced second level models
%--------------------------------------------------------------------------
% Plot free energy difference (approx log(model evidence))
%--------------------------------------------------------------------------
subplot(2,1,1)
    bar(F-min(F));
    
    % Labels and Titles
    Franked = sort(F);
    df = Franked(1) - Franked(2);
    ylabel('Free Energy');
    title(['BMC, difference between winning and second best model: dF = ' num2str(df)], 'Fontsize', 15);
    
    % Plot settings
    set(gca, 'XTickLabels', labels);

% Plot posterior model probability
%--------------------------------------------------------------------------
subplot(2,1,2)
    title('Posterior Probability');
    bar(spm_softmax(F'))
    ylabel('Posterior Probability');
    
set(gcf, 'color', 'w');
set(gcf, 'Position', [100 500 900 400]);

%% Repeat PEB in the winning model (11) and run Baysian model reduction
%--------------------------------------------------------------------------
[REB, RCM]  = spm_dcm_peb(DCM',M,C{11});    % winning model from the step above is M11
RMA         = spm_dcm_peb_bmc(REB);


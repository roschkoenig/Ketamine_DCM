% Inverting DCM, returning full grand mean inversion of repetition effect
%==========================================================================
% This function will take the model
% specification in the shape of 2 B-matrices (repetition, drug), the 
% analysis path (where DCMs will be saved) and the data path (where the
% data are saved. From these it estimates the relevant DCM, then returning 
% it as DCM object and saving it to the specified filepath

function DCM = ket_dcm_gm(rep_lin, rep_non, Fanalysis, Fdata, Fspm)

% Initialise SPM
%--------------------------------------------------------------------------
spm('defaults', 'EEG');
fs = filesep;

% Data filename
%--------------------------------------------------------------------------
DCM.xY.Dfile    = [Fdata fs 'pgm_meeg_all'];
DCM.name        = [Fanalysis fs 'DCM_All_' rep_lin.name '_' rep_non.name];

% Fix location of canonical brain in MEEG file
%--------------------------------------------------------------------------
MEEG                                = load(DCM.xY.Dfile);
D                                   = MEEG.D;
D.other.inv{end}.forward.vol        = [Fspm fs 'canonical' fs 'single_subj_T1_EEG_BEM.mat'];
save(DCM.xY.Dfile, 'D');


% Parameters and options used for setting up model
%--------------------------------------------------------------------------
DCM.options.analysis = 'ERP'; % analyze evoked responses
DCM.options.model    = 'CMC'; % CMC model
DCM.options.spatial  = 'ECD'; % spatial model
DCM.options.Tdcm(1)  = 0;     % start of peri-stimulus time to be modelled
DCM.options.Tdcm(2)  = 300;   % end of peri-stimulus time to be modelled
DCM.options.Nmodes   = 8;     % nr of modes for data selection
DCM.options.h        = 4;     % nr of DCT components
DCM.options.onset    = 75;    % selection of onset (prior mean)
DCM.options.D        = 1;     % downsampling
DCM.options.trials   = [6 1 2 3]; % index of ERPs within file
DCM.options.location = 1;     % optimising source location
DCM.options.han      = 1;     % applying hanning window


% Data and spatial model
%==========================================================================
cd(Fdata);
DCM  = spm_dcm_erp_data(DCM);

% Location priors for dipoles
%--------------------------------------------------------------------------
DCM.Lpos  = [[-42; -22; 7] [46; -14; 8] [-61; -32; 8] [59; -25; 8] [-46; 20; 8] [46; 20; 8]];
DCM.Sname = {'left AI', 'right A1', 'left STG', 'right STG', 'left IFG', 'right IFG'};
Nareas    = size(DCM.Lpos,2);

% Spatial model
%--------------------------------------------------------------------------
% DCM = spm_dcm_erp_dipfit(DCM);


% Specify connectivity model
%--------------------------------------------------------------------------
DCM.A{1} = zeros(Nareas, Nareas);   % forward connections
DCM.A{1}(3,1) = 1;
DCM.A{1}(4,2) = 1;
DCM.A{1}(5,3) = 1;
DCM.A{1}(6,4) = 1;

DCM.A{2} = zeros(Nareas,Nareas);    % backward connections
DCM.A{2}(1,3) = 1;
DCM.A{2}(2,4) = 1;
DCM.A{2}(3,5) = 1;
DCM.A{2}(4,6) = 1;

DCM.A{3} = zeros(Nareas,Nareas);    % modulatory connections
DCM.A{3}(1,1) = 1;
DCM.A{3}(2,2) = 1;
DCM.A{3}(3,3) = 1;
DCM.A{3}(4,4) = 1;
DCM.A{3}(5,5) = 1;
DCM.A{3}(6,6) = 1;

DCM.B{1} = rep_lin.matrix;           % model specification
DCM.B{2} = rep_non.matrix;

DCM.C = [1; 1; 0; 0; 0; 0];            % input

% Between trial effects
%--------------------------------------------------------------------------
% Trials defined as S0, S1, S2, S3 (Placebo); S0, S1, S2, S3 (Ketamine);

DCM.xU.X(:,1) = [3; 2; 1; 0];
DCM.xU.name{1} = {'repetition_linear'};
DCM.xU.X(:,2) = [0; 2; 1; 0];
DCM.xU.name{2} = {'repetition_non-linear'};


% Invert
%--------------------------------------------------------------------------                         
DCM = spm_dcm_erp(DCM);


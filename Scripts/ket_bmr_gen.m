function DCM = ket_bmr_gen(rep_lin, rep_non, Fbmr)
% Generating a single DCM without inverting in preparation for BMR
%==========================================================================
% This function accepts the input specifications in order to generate
% models that can subsequently be avaluated using BMR without individually
% inverting each model

% Parameters and options used for setting up model
%--------------------------------------------------------------------------
DCM.options.analysis = 'ERP'; % analyze evoked responses
DCM.options.model    = 'CMC'; % CMC model
DCM.options.spatial  = 'ECD'; % spatial model
DCM.options.Tdcm(1)  = 0;     % start of peri-stimulus time to be modelled
DCM.options.Tdcm(2)  = 250;   % end of peri-stimulus time to be modelled
DCM.options.Nmodes   = 8;     % nr of modes for data selection
DCM.options.h        = 1;     % nr of DCT components
DCM.options.onset    = 30;    % selection of onset (prior mean)
DCM.options.D        = 1;     % downsampling
DCM.options.trials   = [6 1 2 3]; % index of ERPs within file

% Location priors for dipoles
%--------------------------------------------------------------------------
DCM.Lpos  = [[-42; -22; 7] [46; -14; 8] [-61; -32; 8] [59; -25; 8] [-46; 20; 8] [46; 20; 8]];
DCM.Sname = {'left AI', 'right A1', 'left STG', 'right STG', 'left IFG', 'right IFG'};
Nareas    = size(DCM.Lpos,2);


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

DCM.B{1} = rep_lin.matrix;          % model specification
DCM.B{2} = rep_non.matrix;

DCM.C = [1; 1; 0; 0; 0; 0];            % input

% Between trial effects
%--------------------------------------------------------------------------
% Trials defined as S0, S1, S2, S3 (Placebo); S0, S1, S2, S3 (Ketamine);

DCM.xU.X(:,1) = [3; 2; 1; 0];
DCM.xU.name{1} = {'repetition'};
DCM.xU.X(:,2) = [0; 2; 1; 0];
DCM.xU.name{2} = {'repetition_non-linear'};

[pE,pC]  = spm_dcm_neural_priors(DCM.A,DCM.B,DCM.C,DCM.options.model);
DCM.M.pE = pE;
DCM.M.pC = pC;

DCM.name = [Fbmr filesep 'DCM_BMR_' rep_lin.name '_' rep_non.name];

end
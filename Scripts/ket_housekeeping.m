%% Housekeeping
%==========================================================================
% This function defines filepaths and variables used in analysis functions.
% Most user specified information will be defined here

function D = ket_housekeeping

spm('defaults', 'EEG');

Fbase       = '/Users/roschkoenig/Desktop/GitCode/Ketamine_DCM'; 
Fspm        = '/Users/roschkoenig/Dropbox/Research/tools/spm';


fs          = filesep;
Fdata       = [Fbase fs 'SPM-ready Data'];
Fanalysis   = [Fbase fs 'DCMs']; 
Fbmr        = [Fanalysis fs 'BMR'];
GMFile      = [Fanalysis fs 'DCM_All_FBi_FBi.mat'];

addpath(Fspm);
addpath(genpath([Fbase fs 'Scripts']))

files   = spm_select('FPList', Fdata, '^m_');
letters = files(:, end-4);
sub     = unique(letters);

% Package up variables for exporting from function
%--------------------------------------------------------------------------
D.Fbase     = Fbase;
D.Fspm      = Fspm;
D.Fdata     = Fdata;
D.Fanalysis = Fanalysis;
D.Fbmr      = Fbmr;
D.GMFile    = GMFile;
D.sub       = sub;
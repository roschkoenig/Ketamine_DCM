%% Generating Model Space for use in BMR for repetition effect
%==========================================================================
% This function generates the model space of reduced models explaining the
% repetition effect: This is split into two parametric modulations
% (monophasic/linear, and phasic/non-linear) and combinations of effects on
% forward, backward and intrinsic connectivity. 

function [rep_lin, rep_non] = ket_bmr_gen_model_space()

% Models for repetition effects (none, extr, intr, both)
%--------------------------------------------------------------------------
F =   [ 0 0 0 0 0 0; ...
     	0 0 0 0 0 0; ...
     	1 0 0 0 0 0; ...
        0 1 0 0 0 0; ...
      	0 0 1 0 0 0; ...
      	0 0 0 1 0 0];  
    
B =   [ 0 0 1 0 0 0; ...
     	0 0 0 1 0 0; ...
     	0 0 0 0 1 0; ...
        0 0 0 0 0 1; ...
      	0 0 0 0 0 0; ...
      	0 0 0 0 0 0];   
    
I =   [ 1 0 0 0 0 0; ...
     	0 1 0 0 0 0; ...
     	0 0 1 0 0 0; ...
        0 0 0 1 0 0; ...
      	0 0 0 0 1 0; ...
      	0 0 0 0 0 1];   

rep_lin{1}.name = '0';
rep_lin{1}.matrix = zeros(6);

rep_lin{2}.name = 'F';
rep_lin{2}.matrix = F;

rep_lin{3}.name = 'B';
rep_lin{3}.matrix = B;

rep_lin{4}.name = 'FB';
rep_lin{4}.matrix = F + B;

rep_lin{5}.name = '0i';
rep_lin{5}.matrix = I;

rep_lin{6}.name = 'Fi';
rep_lin{6}.matrix = F + I;

rep_lin{7}.name = 'Bi';
rep_lin{7}.matrix = B + I;

rep_lin{8}.name = 'FBi';
rep_lin{8}.matrix = F + B + I;
                
rep_non = rep_lin;

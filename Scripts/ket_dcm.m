%% Ketamine DCM analysis using Parametric Empirical Bayes
%==========================================================================
% This code will run two functions, ket_dcm_gm - to invert the full
% model, and ket_dcm to invert separate placebo and ketamine models for the
% individual subjects. 

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

%% Invert DCMs
%==========================================================================
% This section will take a   !/*long*/!  time.
% A log of the model inversions is saved in the DCM folder that will
% document inversion steps taken for the individual models to invert. 

% Invert DCM for grand mean
%--------------------------------------------------------------------------
diary([Fanalysis fs 'DCM_ALL_log']);
diary('on');

FCM = ket_dcm_gm(rep_lin{end}, rep_non{end}, Fanalysis, Fdata, Fspm);

% Invert individual subjects
%--------------------------------------------------------------------------
for s = 1:length(sub)
    SCM{s} = ket_dcm_sgl(sub(s), GMFile, rep_lin{end}, rep_non{end}, ... 
                         [Fanalysis fs 'Individual'], Fdata, Fspm);
end

diary off

%% Plot example modes (first mode for each of the conditions)
%--------------------------------------------------------------------------
% This section loads the just inverted DCMs and plots the first principal
% eigenmode of both observed ERPs and model predictions for each of the
% four conditions (D1, S2, S6, S36). 

files = cellstr(spm_select('FPList', [Fanalysis fs 'Individual'], '^*.mat'));

cols_unsort     = jet(10);          % standard color scheme
try cols_unsort = cbrewer('qual', 'Paired', 10); end  % try nicer colour scheme

cols(1:2,:) = cols_unsort(5:6,:);   % cbrewer: red
cols(3:4,:) = cols_unsort(9:10,:);  % cbrewer: purple
cols(5:6,:) = cols_unsort(1:2,:);   % cbrewer: blue
cols(7:8,:) = cols_unsort(3:4,:);


for reps = 1:2
figure
for f = 1:18
    DCM = load(files{f+(reps-1)*18});
    DCM = DCM.DCM;

    subplot(9,2,f)
    for c = 1:4
        plot(DCM.H{c}(:,1), 'color', cols(c*2,:), 'Linewidth', 1.5); hold on
        plot(DCM.H{c}(:,1) + DCM.R{c}(:,1), 'color', cols(c*2-1,:), 'Linewidth', 1.5);
        ylim([-10 10]);
     
        xlabel(DCM.name(end-9:end-8))
        set(gcf, 'color', 'w');
        set(gcf, 'Position', [100 + 400*(reps-1) 100 400 800]);
    end
end
end
legend({'D1(pred)', 'D1(obs)', 'S2(pred)', 'S2(obs)', 'S6(pred)', 'S6(obs)', 'S36(pred)', 'S36(obs)'});
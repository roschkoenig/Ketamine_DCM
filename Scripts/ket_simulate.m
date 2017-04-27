%% Simulating the effects of parameter changes on the grand mean
%==========================================================================
% Based on the PEB analysis specific parameter changes were identified in
% the ii -> ss coupling. These are explored further by simulating data
% based on the grand mean model inversion with the added PEB-derived
% effects on ii -> ss coupling in STG and IFG. These are shown both in time
% and in state space, illustrating that reduction in inhibitory connections
% onto ss cells have impacts on superficial pyramidal cells and overall
% model output. 

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

% Load and prepare DCM file
%--------------------------------------------------------------------------
DCM             = load(GMFile);
DCM             = DCM.DCM;
DCM.xY.Dfile    = [Fdata fs 'pgm_meeg_all'];
DCM             = spm_dcm_erp_dipfit(DCM,1);
DCM.name        = [Fanalysis fs 'Temp_DCM'];

% Simulate DCM outoput for different parameter combinations
%==========================================================================
% As identified from the PEB analysis, there are large opposing effects on
% inhibitory interneuron connections on spiny stellate cells in IFG and
% STG. To explore these further, here we simulate the effects of sliding
% parameter changes of both IFG and STG ii -> ss inhibition. 
% ** steps ** defines the resolution of the simulation
clear A1 STG IFG
steps       = 10;
G           = linspace(0, 2, steps);

for s = 1:steps
    
% Extract parameters and (symmetrically) change ii -> ss inhibition
%--------------------------------------------------------------------------
Sp        = DCM.Ep;
Sp.G(3,3) = Sp.G(3,3) + G(s);
Sp.G(4,3) = Sp.G(4,3) + G(s);
Sp.G(5,3) = Sp.G(5,3) - G(s);
Sp.G(6,3) = Sp.G(6,3) - G(s);

% Calculate model prediction based on the new parameterset
%--------------------------------------------------------------------------
y       = spm_gen_erp(Sp, DCM.M, DCM.xU);

% Extract population specific traces from regions
%--------------------------------------------------------------------------
pops    = {'II', 'SP', 'SS', 'DP'};

for p = 1:4
    pop = (p-1)*12;

    A1{p}(:,s) = y{1}(:,1 + pop);
    STG{p}(:,s) = y{1}(:,3 + pop);
    IFG{p}(:,s) = y{1}(:,5 + pop);
    
end

end

% Plot model predictions for increasing parameter changes - time resolved
%--------------------------------------------------------------------------
figure
try     spectral = flip(cbrewer('div', 'Spectral', 100));
catch   spectral = jet(200);    end

colormap(spectral)
subplot(3,1,1)
    imagesc(DCM.xY.pst, G, A1{2}');
    title('Effects of ketamine on A1 superficial pyramidal cells',  'FontWeight', 'bold');
    xlabel('Peristimulus time');
    ylabel('Parameter change');
    colorbar
subplot(3,1,2)
    imagesc(DCM.xY.pst, G, STG{2}');
    title('Effects of ketamine on STG superficial pyramidal cells',  'FontWeight', 'bold');
    xlabel('Peristimulus time');   
    ylabel('Parameter change');
    colorbar
subplot(3,1,3)
	imagesc(DCM.xY.pst, G, IFG{2}');
    title('Effects of ketamine on IFG superficial pyramidal cells', 'FontWeight', 'bold');
    xlabel('Peristimulus time'); 
    ylabel('Parameter change');
    colorbar
    
set(gcf, 'color', 'w');
set(gcf, 'Position', [100 100 400 800]);


% Plot model predictions for increasing parameter changes - state space
%--------------------------------------------------------------------------
figure
try     col50 = flip(cbrewer('div', 'RdYlBu', steps));
catch   col50 = jet(steps);    end

p1 = 2;     % Superficial pyramidal cells    
p2 = 3;     % Spiny stellate interneurons

subplot(3,1,1)
for s = 1:size(A1{p1},2)
    plot(A1{p1}(:,s), A1{p2}(:,s), 'color', col50(s,:), 'Linewidth', 2); hold on
  	xlabel(pops{p1});
    ylabel(pops{p2});
end

subplot(3,1,2)
for s = 1:size(A1{p1},2)
    plot(STG{p1}(:,s), STG{p2}(:,s), 'color', col50(s,:), 'Linewidth', 2); hold on
  	xlabel(pops{p1});
    ylabel(pops{p2});
end

subplot(3,1,3)
for s = 1:size(A1{p1},2)
    plot(IFG{p1}(:,s), IFG{p2}(:,s), 'color', col50(s,:), 'Linewidth', 2); hold on
  	xlabel(pops{p1});
    ylabel(pops{p2});
end

set(gcf, 'color', 'w');
set(gcf, 'Position', [500 100 400 800]);


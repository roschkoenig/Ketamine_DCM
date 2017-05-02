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

%% Load individual subject ERPs into single cell array
%==========================================================================
clist = {'S2P', 'S6P', 'S36P', 'D36P', 'S2K', 'S6K', 'S36K', 'D36K'};
clear D
for s = 1:length(sub)
    D{s}            = spm_eeg_load([Fdata fs 'm_meeg_' sub(s) '.mat']);
    currentconds	= condlist(D{s});
    currentchans    = chanlabels(D{s});
    cz              = find(strcmp(currentchans, 'CZ'));
    fz              = find(strcmp(currentchans, 'FZ'));
    
    for c = 1:length(clist)
        ci = find(strcmp(currentconds, clist{c}));
        C{c}.name           = clist{c};
        C{c}.data(s,:,:)    = D{s}(:,:,ci);
        C{c}.Fz(s,:)        = D{s}(fz,:,ci);
        C{c}.Cz(s,:)        = D{s}(cz,:,ci);
    end
end

%% Calculate ERP statistics
%==========================================================================
% Calculate standard errors around the mean
%--------------------------------------------------------------------------
for c = 1:length(C)
for t = 1:size(C{c}.Fz,2)
    C{c}.FzSE(t)    = std(C{c}.Fz(:,t)) / sqrt(size(C{c}.Fz,1));
end
C{c}.FzHI = mean(C{c}.Fz,1) + C{c}.FzSE;
C{c}.FzLO = mean(C{c}.Fz,1) - C{c}.FzSE;
end

% Calculate time points of significant difference 
%--------------------------------------------------------------------------
for p = 1:2
for t = 1:size(C{1}.Fz,2)
    
    ci  = (p-1)*4;
    bonferroni      = 0.05 / size(C{1}.Fz,2);
    
    % Between S2 and S36 (i.e. repetition effect)
    %----------------------------------------------------------------------
        
    s2  = C{1+ci}.Fz(:,t);
    s36 = C{3+ci}.Fz(:,t);
   
    [H P CI]        = ttest(s2, s36);
    if P < bonferroni, 	repfx(p,t) = 1;
    else                repfx(p,t) = 0; end

	% Between D1 and S36 (i.e. deviance effect)
    %----------------------------------------------------------------------
	d36  = C{4+ci}.Fz(:,t);
    s36 = C{3+ci}.Fz(:,t);
    
    [H P CI]        = ttest(d36, s36);
	if P < bonferroni, 	devfx(p,t) = 1;
    else                devfx(p,t) = 0; end

end

repdur(p) = sum(repfx(p,50:end)) * 2;
devdur(p) = sum(devfx(p,50:end)) * 2;
end

% Plot ERPs and statistics
%==========================================================================
cols_unsort     = jet(10);          % standard color scheme
try cols_unsort = ccbrewer('qual', 'Paired', 10); end  % try nicer colour scheme
figure 

cols(1:2,:) = cols_unsort(9:10,:);  % cbrewer: purple
cols(3:4,:) = cols_unsort(1:2,:);   % cbrewer: blue
cols(5:6,:) = cols_unsort(3:4,:);   % cbrewer: green
cols(7:8,:) = cols_unsort(5:6,:);   % cbrewer: red

clear legid 

for p = 1:2
for c = 1:4
    ci = 4*(p-1) + c;
    ti = time(D{1});
    
    subplot(2,1,p)
    
    % Plotting ERPs and SE intervals around
    %----------------------------------------------------------------------
    legid(c) = plot(ti,mean(C{ci}.Fz,1), 'Color', cols(2 + 2*(c-1),:)); hold on
    plot(ti,C{ci}.FzHI, 'Color', cols(1 + 2*(c-1),:)); 
    plot(ti,C{ci}.FzLO, 'Color', cols(1 + 2*(c-1),:));
    
    % The world's clumsiest way to illustrate the significant intervals...
    %----------------------------------------------------------------------
    scatter(ti,repfx(p,:) * (-7) + 5, 50, 'k.');     
    scatter(ti,devfx(p,:) * 7 - 3, 50, 'r.');
    
    % Set thresholds and axis definitions
    %----------------------------------------------------------------------
    ylim([-2 4]);
    xlim([-0.1 0.3]);
    legend(legid, {'S2', 'S6', 'S36', 'D1'});
    xlabel('Time in ms; red dots = deviance effect, black dots = repetition effect');
end
end

subplot(2,1,1), title('Placebo ERPs');
subplot(2,1,2), title('Ketamine ERPs'); 


%% Calculate MMN statistics
%==========================================================================
% Calculate standard errors around the mean
%--------------------------------------------------------------------------
MMN{1}.dat = C{3}.Fz - C{4}.Fz;
MMN{2}.dat = C{7}.Fz - C{8}.Fz;
ti = time(D{1});

for m = 1:length(MMN)
for t = 1:size(MMN{1}.dat,2)
    MMN{m}.SEM(t) = std(MMN{m}.dat(:,t)) / sqrt(size(MMN{m}.dat,1));
end
MMN{m}.HI = mean(MMN{m}.dat,1) + MMN{m}.SEM;
MMN{m}.LO = mean(MMN{m}.dat,1) - MMN{m}.SEM;
end

% Test for attenuation of MMN around 200ms, where rep effects are strongest
%--------------------------------------------------------------------------
p = MMN{1}.dat;
k = MMN{2}.dat;

ppeaks = max(p(:, 100:150)');   % note that time is indexed in 2ms steps
kpeaks = max(k(:, 100:150)');
[Hp Pp CIp Sp] = ttest(ppeaks, kpeaks, 'tail', 'right');

ptroughs = min(p(:, 150:200)');   % note that time is indexed in 2ms steps
ktroughs = min(k(:, 150:200)');
[Ht Pt CIt St] = ttest(ptroughs, ktroughs, 'tail', 'left');

% Plot MMN for placebo and ketamine
%==========================================================================
figure
l(1) = plot(ti, mean(p,1), 'k', 'Linewidth', 1.5); hold on
plot(ti, MMN{1}.HI, 'Color', [0.5 0.5 0.5]);
plot(ti, MMN{1}.LO, 'Color', [0.5 0.5 0.5]);

l(2) = plot(ti, mean(k,1), 'r', 'Linewidth', 1.5); hold on
plot(ti, MMN{2}.HI, 'm');
plot(ti, MMN{2}.LO, 'm');

title('MMN for ketamine and placebo');
legend(l, {'Placebo', 'Ketamine'});
set(gcf, 'color', 'w');
ylabel('Voltage difference in uV');
xlabel('Time in s');


%% Plot MMN Scalp maps
%--------------------------------------------------------------------------
cols    = flip(cbrewer('div', 'RdYlBu', 100));
colormap parula
GM      = spm_eeg_load([Fdata fs 'gm_meeg_all']);
order =  {'F7', 'T3', 'T5', 'O1', 'P3', 'C3', 'F3', 'FP1', ...
          'CZ', 'FZ', 'PZ', ...
          'FP2', 'F4', 'C4', 'P4', 'O2', 'T6', 'T4', 'F8'};
      
for o = 1:length(order)
    clist       = chanlabels(GM);
    oldind(o)   = find(strcmp(clist, order{o}));
    data(o,:,:) = GM(oldind(o), :, :);
end

mmn_id{1} = [1 6;  7 12];
mmn_id{2} = [2 6;  8 12];
mmn_id{3} = [3 6;  9 12];

clear d
for m = 1:length(mmn_id)
    id      = mmn_id{m};
    d{1}    = data(:,:,id(1,1)) - data(o,:,id(1,2));
    d{2}    = data(:,:,id(2,1)) - data(o,:,id(2,2));
    
    subplot(2,3,m)
    imagesc(d{1}(:,50:end)', [-2 2]);
    subplot(2,3,m + 3)
    imagesc(d{2}(:,50:end)', [-2 2]);
end





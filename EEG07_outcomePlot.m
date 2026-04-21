clear;
close all;
clc;

% Declare paths
pathProject = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/';
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');
addpath('/Users/claraziane/Documents/Académique/Informatique/MATLAB/eeglab2021.1'); %EEGLab


Participants = {'P04'; 'P12'; 'P18'; 'P26'; 'P27'; 'P29'; 'P37'; 'P41'; 'P44'}; %'P10'; 'P12'; 'P18'; 'P27'; 'P41'
Sessions     = {'RW'; 'FB'};
Conditions   = {'TapST';  'TapDT';...
               'WalkST'; 'WalkDT'};
Comparisons  = {'pre'; 'post'};

% Preallocate matrix
compTopo       = nan(64, length(Participants),length(Conditions)*length(Comparisons),length(Sessions));
Power          = nan(length(Participants),length(Conditions)*length(Comparisons),length(Sessions));
phaseMean      = nan(length(Participants),length(Conditions)*length(Comparisons),length(Sessions));
phaseCI        = nan(length(Participants), 2, length(Conditions)*length(Comparisons),length(Sessions));
ITPC           = nan(length(Participants),length(Conditions)*length(Comparisons),length(Sessions));
stabilityIndex = nan(length(Participants),length(Conditions)*length(Comparisons),length(Sessions));

eeglab;
for iSession = length(Sessions)
    iPlot = 1;
    iTopo = 17;
    iCond = 1;

    for iCondition = 1:length(Conditions)

        for iParticipant = 1:length(Participants)

            pathPreproc = [pathProject 'DATA/Processed/' Participants{iParticipant} '/' Sessions{iSession} '/EEG/'];
            pathResults = [pathProject 'Results/' Participants{iParticipant} '/' Sessions{iSession} '/EEG/'];
            load([pathResults 'resultsEEG.mat']);

            for iCompare = 1:length(Comparisons)
                condName = [Comparisons{iCompare} Conditions{iCondition} ];

                % Load results structure
                load([pathPreproc condName '_compRESS.mat'], 'comp2plot', 'chanLocs');

                % Topoplots
                compTopo(:, iParticipant, iPlot+iCompare-1, iSession) = comp2plot;

                figure(iPlot+iCompare-1+1);
                subplot(1,length(Participants), iParticipant);...
                    topoplot(comp2plot./max(comp2plot), chanLocs, 'maplimits', [-1 1], 'numcontour', 0, 'conv', 'off', 'electrodes', 'off', 'shading', 'interp'); hold on;
                    title(Participants{iParticipant})
                    sgtitle(condName, 'FontSize', 24, 'FontWeight', 'bold')

                if strcmpi(resultsEEG.(condName).compKeep, 'N')
                    Power(iParticipant, iPlot+iCompare-1, iSession) = NaN;
                    phaseMean(iParticipant, iPlot+iCompare-1, iSession) = NaN;
                    phaseCI(iParticipant, :, iPlot+iCompare-1, iSession) = NaN;
                    ITPC(iParticipant, iPlot+iCompare-1, iSession) = NaN;
                    stabilityIndex(iParticipant, iPlot+iCompare-1, iSession) = NaN;

                else
                    % Power
                    Power(iParticipant, iPlot+iCompare-1, iSession) = resultsEEG.(condName).power;

                    % Phase
                    Phase = [];
                    Phase = resultsEEG.(condName).phase;
                    phaseMean(iParticipant, iPlot+iCompare-1, iSession) = resultsEEG.(condName).phaseMean;
                    SEM = resultsEEG.(condName).phaseStd / sqrt(length(Phase));
                    t = tinv([0.025 0.975], length(Phase)-1);
                    phaseCI(iParticipant, :, iPlot+iCompare-1, iSession) = resultsEEG.(condName).phaseMean + t * SEM;

                    % ITPC
                    ITPC(iParticipant, iPlot+iCompare-1, iSession) = resultsEEG.(condName).phaseR;

                    % Stability Index
                    stabilityIndex(iParticipant, iPlot+iCompare-1, iSession) = resultsEEG.(condName).stabilityIndex;

                    if iCompare == 2
                        deltaSI(iParticipant, iCondition) = stabilityIndex(iParticipant, iPlot+iCompare-1, iSession) - stabilityIndex(iParticipant, iPlot+iCompare-2, iSession);
                    end


                end


            end % end Comparisons

            if iParticipant == length(Participants)
                iPlot = iPlot + 2;
            end

        end % end Participants

        % Plot average topo per condition
        iCompare = 1;
        for iTopo = iTopo+1:iTopo+2

            if strcmpi(Conditions{iCondition}(1:4), 'none') == 1 && strcmpi(Comparisons{iCompare}, 'DT') == 1 %There is no DT condition in the none conditions
            else
                topoMean = mean(squeeze(compTopo(:,:,iCond,iSession)),2);

                figure(iTopo);
                topoplot(topoMean./max(topoMean), chanLocs, 'maplimits', [-1 1], 'numcontour', 0, 'conv', 'off', 'electrodes', 'off', 'shading', 'interp'); hold on;
                title([strcat(Comparisons{iCompare}, Conditions{iCondition})], 'FontSize', 24, 'FontWeight', 'bold')
                saveas(figure(iTopo), [pathProject 'Results/All/' Sessions{iSession} '/EEG/topoMean_' strcat(Comparisons{iCompare}, Conditions{iCondition}) '.png'])
            end
            iCond = iCond +1;
            iCompare = iCompare + 1;

        end


    end % end Conditions

    %% Plot
    plotScatter(Power(:,:,iSession), Comparisons, Conditions, 'Power (SNR)');
    plotScatterCI(phaseMean(:,:,iSession), phaseCI, Comparisons, Conditions, 'Phase (rad)');
    plotScatter(ITPC(:,:,iSession), Comparisons, Conditions, 'Inter-trial Phase Coherence');
    plotScatter(stabilityIndex(:,:,iSession), Comparisons, Conditions, 'Stability Index (Hz)');

    plotScatter(deltaSI, [], Conditions, '\Delta_{Stability Index} (Hz)');

    %% Save
    saveas(figure(2), [pathProject 'Results/All/' Sessions{iSession} '/EEG/topo_' Comparisons{1} Conditions{1} '.png'])
    saveas(figure(3), [pathProject 'Results/All/' Sessions{iSession} '/EEG/topo_' Comparisons{2} Conditions{1} '.png'])
    saveas(figure(4), [pathProject 'Results/All/' Sessions{iSession} '/EEG/topo_' Comparisons{1} Conditions{2} '.png'])
    saveas(figure(5), [pathProject 'Results/All/' Sessions{iSession} '/EEG/topo_' Comparisons{2} Conditions{2} '.png'])
    
    saveas(figure(6), [pathProject 'Results/All/' Sessions{iSession} '/EEG/topo_' Comparisons{1} Conditions{3} '.png'])
    saveas(figure(7), [pathProject 'Results/All/' Sessions{iSession} '/EEG/topo_' Comparisons{2} Conditions{3} '.png'])    
    saveas(figure(8), [pathProject 'Results/All/' Sessions{iSession} '/EEG/topo_' Comparisons{1} Conditions{4} '.png'])
    saveas(figure(9), [pathProject 'Results/All/' Sessions{iSession} '/EEG/topo_' Comparisons{2} Conditions{4} '.png']) 
    
    saveas(figure(10), [pathProject 'Results/All/' Sessions{iSession} '/EEG/fig_eegPower.png'])
    saveas(figure(11), [pathProject 'Results/All/' Sessions{iSession} '/EEG/fig_eegPhase.png'])
    saveas(figure(12), [pathProject 'Results/All/' Sessions{iSession} '/EEG/fig_eegITPC.png'])
    saveas(figure(13), [pathProject 'Results/All/' Sessions{iSession} '/EEG/fig_eegStabilityIndex.png'])
  
    saveas(figure(14), [pathProject 'Results/All/' Sessions{iSession} '/EEG/fig_deltaStabilityIndex.png'])

    close all;

end % end Sessions
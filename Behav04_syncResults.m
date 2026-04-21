clear all;
close all;
clc;

% Declare paths
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');

Participants = {'P04'; 'P07'; 'P10'; 'P11'; 'P12'; 'P13'; 'P16'; 'P18'; 'P21'; 'P23'; 'P25'; 'P26'; 'P27'; 'P29'; 'P36'; 'P37'; 'P39'; 'P40'; 'P41'; 'P44'}; %RW

Sessions     = {'RW'; 'FB'};
Conditions   = {'TapST';  'TapDT';
                'WalkST'; 'WalkDT'};
Comparisons  = {'pre'; 'post'};

% Preallocate matrix
rLogit      = nan(length(Participants),length(Conditions));
rRAW        = nan(length(Participants),length(Conditions));
IBI         = nan(length(Participants),length(Conditions));
asyncMean   = nan(length(Participants),length(Conditions));
asyncCI     = nan(length(Participants), 2, length(Conditions));
phaseMean   = nan(length(Participants),length(Conditions));
phaseCI     = nan(length(Participants), 2, length(Conditions));
noSyncPhase = nan(length(Participants),length(Conditions));

for iSession = 1:length(Sessions)
    iPlot = 1;

    for iCondition = 1:length(Conditions)

        for iParticipant = 1:length(Participants)

            pathImport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/'];
            load([pathImport 'resultsSync.mat']);

            for iCompare = 1:length(Comparisons)
                condName = [Comparisons{iCompare} Conditions{iCondition}];

                % Asynchronies
                Asynchrony = [];
                Asynchrony = resultsSync.(condName).Asynchrony;
                asyncMean(iParticipant, iPlot+iCompare-1) = mean(Asynchrony);
                SEM = std(Asynchrony) / sqrt(length(Asynchrony));
                t = tinv([0.025 0.975], length(Asynchrony)-1);
                asyncCI(iParticipant, :, iPlot+iCompare-1) = mean(Asynchrony) + t * SEM;

                % Phase angles (in rad)
                phaseAngle = [];
                phaseAngle = resultsSync.(condName).phaseRad;
                if resultsSync.(condName).pRaleigh >= 0.05  % When participants do not synchronize, accuracy value is replaced by NaN
                    phaseMean(iParticipant, iPlot+iCompare-1)   = NaN;
                    phaseCI(iParticipant, : , iPlot+iCompare-1) = NaN;
                else
                    phaseMean(iParticipant, iPlot+iCompare-1) = resultsSync.(condName).phaseDegMean;
                    SEM = circ_std(phaseAngle) / sqrt(length(phaseAngle));
                    t = tinv([0.025 0.975], length(phaseAngle)-1);
                    phaseCI(iParticipant, : , iPlot+iCompare-1) = rad2deg(resultsSync.(condName).phaseRadMean + t * SEM);
                end            
           
                % Resultant vector lengths
                rLogit(iParticipant, iPlot+iCompare-1) = log(resultsSync.(condName).resultantLength ./ (1-resultsSync.(condName).resultantLength));
                rRaw(iParticipant, iPlot+iCompare-1)   = resultsSync.(condName).resultantLength;

                % Inter-beat interval deviations
                IBI(iParticipant, iPlot+iCompare-1) = resultsSync.(condName).IBIDeviation;

                if iCompare == 2
                    deltaR(iParticipant, iCondition) = rLogit(iParticipant, iPlot+iCompare-1) - rLogit(iParticipant, iPlot+iCompare-2);
                end

            end % End Comparisons

            if iParticipant == length(Participants)
                iPlot = iPlot + 2;
            end

        end % End Participants

    end % End Conditions
   
    %% Plot
    plotScatter(rLogit, Comparisons, Conditions, 'Synchronization Consistency (logit)');    
    plotScatter(rRaw, Comparisons, Conditions, 'Synchronization Consistency');    
    plotScatter(phaseMean, Comparisons, Conditions, 'Synchronization Accuracy (°)'); 
    plotScatter(IBI, Comparisons, Conditions, 'Interbeat Interval Deviations');
    plotScatterCI(asyncMean, asyncCI, Comparisons, Conditions, 'Asynchronies (ms)');
    plotScatterCI(phaseMean, phaseCI, Comparisons, Conditions, 'Phase Angles (°)');
    plotScatter(deltaR, [], Conditions, '\Delta_{Synchronization Consistency} (logit)');


    % Save
    saveas(figure(1), [pathResults '/All/' Sessions{iSession} '/Behavioural/fig_syncConsistency_Logit.png'])
    saveas(figure(2), [pathResults '/All/' Sessions{iSession} '/Behavioural/fig_syncConsistency_vectorLength.png'])
    saveas(figure(3), [pathResults '/All/' Sessions{iSession} '/Behavioural/fig_syncAccuracy.png'])
    saveas(figure(4), [pathResults '/All/' Sessions{iSession} '/Behavioural/fig_syncIBI.png'])
    saveas(figure(5), [pathResults '/All/' Sessions{iSession} '/Behavioural/fig_syncAsyncCI.png'])
    saveas(figure(6), [pathResults '/All/' Sessions{iSession} '/Behavioural/fig_syncAccuracyCI.png'])
    saveas(figure(7), [pathResults '/All/' Sessions{iSession} '/Behavioural/fig_deltaConsistency.png'])
  
    close all;

end % End Sessions

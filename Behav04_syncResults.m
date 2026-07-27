clear all;
close all;
clc;

% Declare paths
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');

Participants = {'P04'; 'P07'; 'P10'; 'P11'; 'P12'; 'P13'; 'P16'; 'P18'; 'P21'; 'P23'; 'P25'; 'P26'; 'P27'; 'P29'; 'P36'; 'P37'; 'P39'; 'P40'; 'P41'; 'P44'}; %RW

Sessions     = {'RW'; 'FB'};
Conditions   = {'TapST';  'TapDT'; 'WalkST'; 'WalkDT'};
figLabels    = {'TapST';  'TapDT'; 'WalkST'; 'WalkDT'; 'TapST';  'TapDT'; 'WalkST'; 'WalkDT'};
Comparisons  = {'pre'; 'post'};

% Preallocate matrix
rLogit      = nan(length(Participants),length(Conditions)*length(Comparisons), length(Sessions));
rRAW        = nan(length(Participants),length(Conditions)*length(Comparisons), length(Sessions));
IBI         = nan(length(Participants),length(Conditions)*length(Comparisons), length(Sessions));
asyncMean   = nan(length(Participants),length(Conditions)*length(Comparisons), length(Sessions));
asyncCI     = nan(length(Participants), 2, length(Conditions)*length(Comparisons), length(Sessions));
phaseMean   = nan(length(Participants),length(Conditions)*length(Comparisons), length(Sessions));
phaseCI     = nan(length(Participants), 2, length(Conditions)*length(Comparisons), length(Sessions));
noSyncPhase = nan(length(Participants),length(Conditions)*length(Comparisons), length(Sessions));

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
                asyncMean(iParticipant, iPlot+iCompare-1, iSession) = mean(Asynchrony);
                SEM = std(Asynchrony) / sqrt(length(Asynchrony));
                t = tinv([0.025 0.975], length(Asynchrony)-1);
                asyncCI(iParticipant, :, iPlot+iCompare-1, iSession) = mean(Asynchrony) + t * SEM;

                % Phase angles (in rad)
                phaseAngle = [];
                phaseAngle = resultsSync.(condName).phaseRad;
                if resultsSync.(condName).pRaleigh >= 0.05  % When participants do not synchronize, accuracy value is replaced by NaN
                    phaseMean(iParticipant, iPlot+iCompare-1, iSession)   = NaN;
                    phaseCI(iParticipant, : , iPlot+iCompare-1, iSession) = NaN;
                else
                    phaseMean(iParticipant, iPlot+iCompare-1, iSession) = resultsSync.(condName).phaseDegMean;
                    SEM = circ_std(phaseAngle) / sqrt(length(phaseAngle));
                    t = tinv([0.025 0.975], length(phaseAngle)-1);
                    phaseCI(iParticipant, : , iPlot+iCompare-1, iSession) = rad2deg(resultsSync.(condName).phaseRadMean + t * SEM);
                end

                % Resultant vector lengths
                rLogit(iParticipant, iPlot+iCompare-1, iSession) = log(resultsSync.(condName).resultantLength ./ (1-resultsSync.(condName).resultantLength));
                rRaw(iParticipant, iPlot+iCompare-1, iSession)   = resultsSync.(condName).resultantLength;

                % Inter-beat interval deviations
                IBI(iParticipant, iPlot+iCompare-1, iSession) = resultsSync.(condName).IBIDeviation;

            end % End Comparisons

            if iParticipant == length(Participants)
                iPlot = iPlot + 2;
            end

        end % End Participants

    end % End Conditions

    % Replace outliers with NaNs
    [rLogit(:,:,iSession)] = removeOutliers(rLogit(:,:,iSession));
    [rRaw(:,:,iSession)]   = removeOutliers(rRaw(:,:,iSession));

end % End Sessions

% Compute delta perf
deltaR = rLogit(:,2:2:end,:) - rLogit(:,1:2:end-1,:);

%% Plot
% Plot both sessions side by side
plotScatter(reshape(rLogit, size(rLogit,1), [], 1), Comparisons, figLabels, 'Synchronization Consistency (logit)');
plotScatter(reshape(rRaw, size(rRaw,1), [], 1), Comparisons, figLabels, 'Synchronization Consistency');
plotScatter(reshape(phaseMean, size(phaseMean,1), [], 1), Comparisons, figLabels, 'Synchronization Accuracy (°)');
plotScatter(reshape(IBI, size(IBI,1), [], 1), Comparisons, figLabels, 'Interbeat Interval Deviations');
plotScatterCI(reshape(asyncMean, size(asyncMean,1), [], 1), asyncCI, Comparisons, figLabels, 'Asynchronies (ms)');
plotScatterCI(reshape(phaseMean, size(phaseMean,1), [], 1), phaseCI, Comparisons, figLabels, 'Phase Angles (°)');
plotScatter(reshape(deltaR, size(deltaR,1), [], 1), [], figLabels, '\Delta_{Synchronization Consistency} (logit)');

% Save
saveas(figure(1), [pathResults '/All/Behavioural/fig_syncConsistency_Logit_noOutliers.png'])
saveas(figure(2), [pathResults '/All/Behavioural/fig_syncConsistency_vectorLength_noOutliers.png'])
saveas(figure(3), [pathResults '/All/Behavioural/fig_syncAccuracy.png'])
saveas(figure(4), [pathResults '/All/Behavioural/fig_syncIBI.png'])
saveas(figure(5), [pathResults '/All/Behavioural/fig_syncAsyncCI.png'])
saveas(figure(6), [pathResults '/All/Behavioural/fig_syncAccuracyCI.png'])
saveas(figure(7), [pathResults '/All/Behavioural/fig_deltaConsistency_noOutliers.png'])

close all;

% end % End Sessions

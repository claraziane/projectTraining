clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants = {'P04'; 'P07'; 'P10'; 'P11'; 'P12'; 'P13'; 'P16'; 'P18'; 'P21'; 'P23'; 'P25'; 'P26'; 'P27'; 'P29'; 'P36'; 'P37'; 'P39'; 'P40'; 'P41'; 'P44'}; %RW
Sessions     = {'RW'; 'FB'};
Conditions   = {'preTapST';  'preTapDT';  'preWalkST';  'preWalkDT';...
               'postTapST'; 'postTapDT'; 'postWalkST'; 'postWalkDT';};


varX = {'power'; 'phaseR'; 'stabilityIndex'}; 
varY = {'imiMean'; 'imiCV'; 'phaseDegMean'; 'resultantLength'};

xLabels = {'Power (SNR)'; 'Phase Coupling'; 'Stability Index (Hz)'};
yLabels = {'Inter-Movement Interval (ms)'; 'Coefficient of Variation_{Inter-Movement Interval}'; 'Synchronization Accuracy (°)'; 'Synchronization Consistency (logit)'}';

corrType = 'Spearman';

for iSession = 2%length(Sessions)
    iFig = 1;

    for iX = 1:length(varX)
        xLabel = (xLabels{iX});

        for iY = 1:length(varY)
            yLabel = (yLabels{iY});

            for iCondition = 1:length(Conditions)

                for iParticipant = 1:length(Participants)

                    % Load data
                     load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/EEG/resultsEEG.mat'])
                     load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/resultsSync.mat'])
                     load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/resultsBehav.mat'])
                     
                     if strcmpi(varX{iX}, 'power') || strcmpi(varX{iX}, 'phaseR') || strcmpi(varX{iX}, 'stabilityIndex')
                         if strcmpi(resultsEEG.(Conditions{iCondition}).compKeep, 'N')
                             dataX(iParticipant,iCondition) = NaN;
                         else
                             dataX(iParticipant,iCondition) = resultsEEG.(Conditions{iCondition}).(varX{iX})  ;
                         end
                     elseif strcmpi(varX{iX}, 'imiCV')
                         dataX(iParticipant,iCondition) = resultsBehav.(Conditions{iCondition}).(varX{iX});
                     end

                     if strcmpi(varY{iY}, 'imiMean') || strcmpi(varY{iY}, 'imiCV')
                         dataY(iParticipant,iCondition) = resultsBehav.(Conditions{iCondition}).(varY{iY});
                     elseif strcmpi(varY{iY}, 'power') || strcmpi(varY{iY}, 'phaseR') || strcmpi(varY{iY}, 'stabilityIndex')
                         dataY(iParticipant,iCondition) = resultsEEG.(Conditions{iCondition}).(varY{iY})  ;
                     elseif strcmpi(varY{iY}, 'resultantLength')
                         dataY(iParticipant,iCondition) = log(resultsSync.(Conditions{iCondition}).(varY{iY}) ./ (1- resultsSync.(Conditions{iCondition}).(varY{iY})));
                     else
                         dataY(iParticipant,iCondition) = resultsSync.(Conditions{iCondition}).(varY{iY});
                     end

                end

            end

            % Remove outliers
            [dataX] = removeOutliers(dataX);
            [dataY] = removeOutliers(dataY);
            
            % Plot
            [corrType] = plotCorrel(dataX, dataY, xLabel, yLabel, Conditions, corrType);
%             sgtitle([figTitles{iVar}], 'FontSize', 20, 'FontWeight', 'bold')
            saveas(figure(iFig), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/All/' Sessions{iSession} '/' corrType '/scoresRaw/fig_' varY{iY} 'vs' varX{iX} '_noOutliers.png']);

            clear dataX dataY
            iFig = iFig+1;

        end

    end
    close all;

end
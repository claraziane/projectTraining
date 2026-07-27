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
              'postTapST'; 'postTapDT'; 'postWalkST'; 'postWalkDT'};
figTitles   = {'TapST__RW';  'TapDT__RW';  'WalkST__RW';  'WalkDT__RW';...
              'TapST__FB';  'TapDT__FB';  'WalkST__FB';  'WalkST__FB';};


varX = {'power'; 'phaseR'; 'stabilityIndex'};
varY = {'imiMean'; 'imiCV'; 'phaseDegMean'; 'resultantLength'};

xLabels = {'Power (SNR)'; 'Phase Coupling'; 'Stability Index (Hz)'};
yLabels = {'Inter-Movement Interval (ms)'; 'Coefficient of Variation_{Inter-Movement Interval}'; 'Synchronization Accuracy (°)'; 'Synchronization Consistency (logit)'}';

corrType = 'Spearman';

iFig = 1;

for iX = 1:length(varX)
    xLabel = (xLabels{iX});

    for iY = 1:length(varY)
        yLabel = (yLabels{iY});

        for iSession = 1:length(Sessions)

            for iCondition = 1:length(Conditions)

                for iParticipant = 1:length(Participants)

                    % Load data
                    load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/EEG/resultsEEG.mat'])
                    load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/resultsSync.mat'])
                    load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/resultsBehav.mat'])

                    if strcmpi(varX{iX}, 'power') || strcmpi(varX{iX}, 'phaseR') || strcmpi(varX{iX}, 'stabilityIndex')
                        if strcmpi(resultsEEG.(Conditions{iCondition}).compKeep, 'N')
                            dataX(iParticipant,iCondition, iSession) = NaN;
                        else
                            dataX(iParticipant,iCondition, iSession) = resultsEEG.(Conditions{iCondition}).(varX{iX})  ;
                        end
                    elseif strcmpi(varX{iX}, 'imiCV')
                        dataX(iParticipant,iCondition, iSession) = resultsBehav.(Conditions{iCondition}).(varX{iX});
                    end

                    if strcmpi(varY{iY}, 'imiMean') || strcmpi(varY{iY}, 'imiCV')
                        dataY(iParticipant,iCondition, iSession) = resultsBehav.(Conditions{iCondition}).(varY{iY});
                    elseif strcmpi(varY{iY}, 'power') || strcmpi(varY{iY}, 'phaseR') || strcmpi(varY{iY}, 'stabilityIndex')
                        dataY(iParticipant,iCondition, iSession) = resultsEEG.(Conditions{iCondition}).(varY{iY})  ;
                    elseif strcmpi(varY{iY}, 'resultantLength')
                        dataY(iParticipant,iCondition, iSession) = log(resultsSync.(Conditions{iCondition}).(varY{iY}) ./ (1- resultsSync.(Conditions{iCondition}).(varY{iY})));
                    else
                        dataY(iParticipant,iCondition, iSession) = resultsSync.(Conditions{iCondition}).(varY{iY});
                    end

                end

            end

            % Remove outliers
            [dataX(:,:,iSession)] = removeOutliers(dataX(:,:,iSession));
            [dataY(:,:,iSession)] = removeOutliers(dataY(:,:,iSession));

        end

        % Compute delta perf (post-pre)
        deltaY = dataY(:,size(dataY,2)/2+1:end,:) - dataY(:,1:size(dataY,2)/2,:);
        deltaX = dataX(:,size(dataX,2)/2+1:end,:) - dataX(:,1:size(dataX,2)/2,:);

        % Plot
        [corrType] = plotCorrel(reshape(deltaX, size(deltaX,1),[],1), reshape(deltaY, size(deltaY,1),[],1), xLabel, yLabel, figTitles, corrType);
        %             sgtitle([figTitles{iVar}], 'FontSize', 20, 'FontWeight', 'bold')
        saveas(figure(iFig), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/All/' corrType '/scoresDelta/fig_' varY{iY} 'vs' varX{iX} '_noOutliers.png']);

        clear dataX dataY
        iFig = iFig+1;

    end

end
close all;
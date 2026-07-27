clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');
addpath '/Users/claraziane/Documents/Académique/Informatique/projetDT'

Participants = {'P04'; 'P07'; 'P10'; 'P11'; 'P12'; 'P13'; 'P16'; 'P18'; 'P21'; 'P23'; 'P25'; 'P26'; 'P27'; 'P29'; 'P36'; 'P37'; 'P39'; 'P40'; 'P41'; 'P44'}; %RW
Sessions     = {'RW'; 'FB'};
Conditions   = {'preTapST';  'preTapDT';  'preWalkST';  'preWalkDT';...
    'postTapST'; 'postTapDT'; 'postWalkST'; 'postWalkDT'};
figTitles   = {'TapST__RW';  'TapDT__RW';  'WalkST__RW';  'WalkDT__RW';...
    'TapST__FB';  'TapDT__FB';  'WalkST__FB';  'WalkST__FB';};

xLabel  = {'Fatigue'};
yLabels = {'Inter-Movement Interval (ms)'; 'Coefficient of Variation_{Inter-Movement Interval}'; 'Synchronization Accuracy (°)'; 'Synchronization Consistency (logit)'; 'Power (SNR)'; 'Phase Coupling'; 'Stability Index (Hz)'}';
varY = {'imiMean'; 'imiCV'; 'phaseDegMean'; 'resultantLength'; 'power'; 'phaseR'; 'stabilityIndex'};

corrType = 'Spearman';

iFig = 1;
for iY = 1:length(varY)
    yLabel = (yLabels{iY});

    for iSession = 1:length(Sessions)

        for iCondition = 1:length(Conditions)

            for iParticipant = 1:length(Participants)

                % No fatigue data for participants listed below
                if strcmpi(Participants(iParticipant), 'P10') &&  strcmpi(Sessions(iSession), 'RW')
                elseif strcmpi(Participants(iParticipant), 'P18') &&  strcmpi(Sessions(iSession), 'RW')
                elseif strcmpi(Participants(iParticipant), 'P27') &&  strcmpi(Sessions(iSession), 'RW')
                elseif strcmpi(Participants(iParticipant), 'P41') &&  strcmpi(Sessions(iSession), 'RW')
                elseif  strcmpi(Participants(iParticipant), 'P12')
                else

                    % Load data
                    load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/EEG/resultsEEG.mat'])
                    load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/resultsSync.mat'])
                    load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/resultsBehav.mat'])
                    load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/resultsFatigue.mat'])

                    % Y data
                    if strcmpi(varY{iY}, 'power') || strcmpi(varY{iY}, 'phaseR') || strcmpi(varY{iY}, 'stabilityIndex')
                        if strcmpi(resultsEEG.(Conditions{iCondition}).compKeep, 'N')
                            dataY(iParticipant,iCondition, iSession) = NaN;
                        else
                            dataY(iParticipant,iCondition, iSession) = resultsEEG.(Conditions{iCondition}).(varY{iY})  ;
                        end
                    elseif strcmpi(varY{iY}, 'imiMean') || strcmpi(varY{iY}, 'imiCV')
                        dataY(iParticipant,iCondition, iSession) = resultsBehav.(Conditions{iCondition}).(varY{iY});
                    elseif strcmpi(varY{iY}, 'resultantLength')
                        dataY(iParticipant,iCondition, iSession) = log(resultsSync.(Conditions{iCondition}).(varY{iY}) ./ (1- resultsSync.(Conditions{iCondition}).(varY{iY})));
                    else
                        dataY(iParticipant,iCondition, iSession) = resultsSync.(Conditions{iCondition}).(varY{iY});
                    end

                    % Fatigue data (X)
                    dataX(iParticipant,iCondition, iSession) = resultsFatigue.(Conditions{iCondition});

                end

            end

        end

        % Remove outliers
%         [dataX(:,:,iSession)] = removeOutliers(dataX(:,:,iSession));
        [dataY(:,:,iSession)] = removeOutliers(dataY(:,:,iSession));

    end
   
    deltaY = dataY(:,size(dataY,2)/2+1:end,:) - dataY(:,1:size(dataY,2)/2,:);
    deltaX = dataX(:,size(dataX,2)/2+1:end,:) - dataX(:,1:size(dataX,2)/2,:);
    dataX(:,1:size(dataX,2)/2,:) = []; % Keep only post-training scores

    % Plot
    [corrType] = plotCorrel(reshape(dataX, size(dataX,1),[],1), reshape(deltaY, size(deltaY,1),[],1), xLabel, yLabel, figTitles, corrType);
    saveas(figure(iFig), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/All/' corrType '/scoresRaw/Fatigue/fig_Fatiguevs' varY{iY} '_noOutliers.png']);

    [corrType] = plotCorrel(reshape(deltaX, size(deltaX,1),[],1), reshape(deltaY, size(deltaY,1),[],1), xLabel, yLabel, figTitles, corrType);
    saveas(figure(iFig+1), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/All/' corrType '/scoresDelta/Fatigue/fig_Fatiguevs' varY{iY} '_noOutliers.png']);

    clear dataX dataY deltaY
    iFig = iFig+2;

end

close all;
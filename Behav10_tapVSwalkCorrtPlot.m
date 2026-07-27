clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants = {'P04'; 'P07'; 'P10'; 'P11'; 'P12'; 'P13'; 'P16'; 'P18'; 'P21'; 'P23'; 'P25'; 'P26'; 'P27'; 'P29'; 'P36'; 'P37'; 'P39'; 'P40'; 'P41'; 'P44'};
Sessions     = {'RW'; 'FB'};
Difficulty   = {'ST'; 'DT'};
Time         = {'pre'; 'post'};
figSubtitles = {'ST__RW';  'DT__RW'; ' ST__FB';  'DT__FB';};

figTitles = {'Inter-Movement Interval (ms)'; 'Coefficient of Variation_{Inter-Movement Interval}'; 'Synchronization Accuracy (°)'; 'Synchronization Consistency (logit)'; 'Power (SNR)'; 'Phase Coupling'; 'Stability Index (Hz)'};
var       = {'imiMean'; 'imiCV'; 'phaseDegMean'; 'resultantLength'; 'power'; 'phaseR'; 'stabilityIndex'};

corrType = 'Spearman';

iFig = 1;

iCondition = 1;
for iVar = 5:length(var)
    %     xLabel = (xLabels{iVar});

    for iSession = 1:length(Sessions)

        for iTime = 1:length(Time)

            for iDifficulty = 1:length(Difficulty)
                xCondition = strcat(Time{iTime}, 'Tap', Difficulty{iDifficulty});
                yCondition = strcat(Time{iTime}, 'Walk', Difficulty{iDifficulty});

                for iParticipant = 1:length(Participants)

                    % EEG data
                    if strcmpi(var{iVar}, 'power') || strcmpi(var{iVar}, 'phaseR') || strcmpi(var{iVar}, 'stabilityIndex')
                        load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/EEG/resultsEEG.mat'])

                        % X data
                        if strcmpi(resultsEEG.(xCondition).compKeep, 'N')
                            dataX(iParticipant,iCondition, iSession) = NaN;
                        else
                            dataX(iParticipant,iCondition, iSession) = resultsEEG.(xCondition).(var{iVar});
                        end

                        % Y data
                        if strcmpi(resultsEEG.(yCondition).compKeep, 'N')
                            dataY(iParticipant,iCondition, iSession) = NaN;
                        else
                            dataY(iParticipant,iCondition, iSession) = resultsEEG.(yCondition).(var{iVar});
                        end


                    % Behavioural data
                    elseif strcmpi(var{iVar}, 'imiMean') || strcmpi(var{iVar}, 'imiCV')
                        load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/resultsBehav.mat'])

                        dataX(iParticipant,iCondition, iSession) = resultsBehav.(xCondition).(var{iVar});
                        dataY(iParticipant,iCondition, iSession) = resultsBehav.(yCondition).(var{iVar});

                    elseif strcmpi(var{iVar}, 'resultantLength')
                        load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/resultsSync.mat'])

                        dataX(iParticipant,iCondition, iSession) = log(resultsSync.(xCondition).(var{iVar}) ./ (1- resultsSync.(xCondition).(var{iVar})));
                        dataY(iParticipant,iCondition, iSession) = log(resultsSync.(yCondition).(var{iVar}) ./ (1- resultsSync.(yCondition).(var{iVar})));

                    else
                        load([pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/resultsSync.mat'])

                        dataX(iParticipant,iCondition, iSession) = resultsSync.(xCondition).(var{iVar});
                        dataY(iParticipant,iCondition, iSession) = resultsSync.(yCondition).(var{iVar});
                    end

                end
                iCondition = iCondition + 1;

            end

        end

        % Remove outliers
        [dataX(:,:,iSession)] = removeOutliers(dataX(:,:,iSession));
        [dataY(:,:,iSession)] = removeOutliers(dataY(:,:,iSession));

        iCondition = 1;

    end

    % Compute delta perf (post-pre)
    deltaY = dataY(:,size(dataY,2)/2+1:end,:) - dataY(:,1:size(dataY,2)/2,:);
    deltaX = dataX(:,size(dataX,2)/2+1:end,:) - dataX(:,1:size(dataX,2)/2,:);

    % Plot
    [corrType] = plotCorrel(reshape(deltaX, size(deltaX,1),[],1), reshape(deltaY, size(deltaY,1),[],1), 'Tap', 'Walk', figSubtitles, corrType);
    sgtitle([figTitles{iVar}], 'FontSize', 20, 'FontWeight', 'bold')
    saveas(figure(iFig), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/All/' corrType '/tapVSwalk/fig_' var{iVar} '_noOutliers.png']);

    clear dataX dataY
    iFig = iFig+1;

end
close all;
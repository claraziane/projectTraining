clear all;
close all;
clc;

% Declare paths
pathResults = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/';
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/'); %Functions for figures

Participants = {'P04'; 'P07'; 'P10'; 'P11'; 'P12'; 'P13'; 'P16'; 'P18'; 'P21'; 'P23'; 'P25'; 'P26'; 'P27'; 'P29'; 'P36'; 'P37'; 'P39'; 'P40'; 'P41'; 'P44'}; %RW
Sessions     = {'RW'; 'FB'};
Comparisons  = {'Pre'; 'Post'}; 

Tests         = {'Paced_music_ross_mean'};
variableName = {'itiCV'; 'itiMean'; 'Async'; 'Rayleigh'; 'asyncSEM'; 'vectorDir'; 'vectorLength'};
Variables    = {'_CV_iti';...
                '_mean_iti';...
                '_mean_absolute_asynchrony'; ...
                '_rayleigh';...
                '_sem_absolute_asynchrony';...
                '_vector_direction'; ...
                '_vector_length'};

% Import test scores
Scores = readtable([pathResults 'All/all-scores.csv']);

% Find participant line in CSV file
participantLine = Scores.subject;

iPlot = 0;

% Preallocate matrix
vectorDir    = nan(length(Participants), length(Comparisons), length(Sessions));
vectorLength = nan(length(Participants), length(Comparisons), length(Sessions));
rLogit       = nan(length(Participants), length(Comparisons), length(Sessions));

for iSession = 1:length(Sessions)

    for iParticipant = 1:length(Participants)

        % Create folder for participant's results if does not exist
        pathParticipant = fullfile(pathResults, Participants{iParticipant}, '/', Sessions{iSession}, '/BAASTA/');
        if ~exist(pathParticipant, 'dir')
            mkdir(pathParticipant)
        end

        for iCompare = 1:length(Comparisons) % Pre vs. Post

            % Find line in result table corresponding to participant ID
            for iLine = 1:length(participantLine)
                if strcmpi([Participants{iParticipant} '_' Sessions{iSession} '_' Comparisons{iCompare}], participantLine{iLine})
                    participantIndex = iLine;
                    break;
                end
            end

            for iVariable = 1:length(Variables)
                % Importing scores from BAASTA table to result structure 
                resultsBAASTA.([Comparisons{iCompare}]).([variableName{iVariable}]) = Scores.(['Paced_music_ross_mean' Variables{iVariable}])(participantIndex);
                
                % For plotting
                if strcmpi(variableName{iVariable}, 'vectorDir')
                    vectorDir(iParticipant, iCompare, iSession) = Scores.(['Paced_music_ross_mean' Variables{iVariable}])(participantIndex);
                elseif strcmpi(variableName{iVariable}, 'vectorLength')
                    rLogit(iParticipant, iCompare, iSession) = log(Scores.(['Paced_music_ross_mean' Variables{iVariable}])(participantIndex) ./ (1-Scores.(['Paced_music_ross_mean' Variables{iVariable}])(participantIndex)));    
                    vectorLength(iParticipant, iCompare, iSession) = Scores.(['Paced_music_ross_mean' Variables{iVariable}])(participantIndex);
                end

            end

        end % End Comparisons

%         % Save results
%         save([pathParticipant '/resultsBAASTA.mat'], 'resultsBAASTA');
        clear resultsBAASTA

    end % End Participants

    % Remove outliers
    vectorDir(:, :, iSession)    = removeOutliers(vectorDir(:, :, iSession));
    vectorLength(:, :, iSession) = removeOutliers(vectorDir(:, :, iSession));
    rLogit(:, :, iSession)       = removeOutliers(vectorDir(:, :, iSession));

    % Plot
    plotScatter(vectorDir(:, :, iSession), Comparisons, 'BAASTA', 'Synchronization Accuracy (°)');
    plotScatter(vectorLength(:, :, iSession), Comparisons, 'BAASTA', 'Synchronization Consistency');
    plotScatter(rLogit(:, :, iSession), Comparisons, 'BAASTA', 'Synchronization Consistency (logit)');

    % Save plots
    saveas(figure(iPlot + 1), [pathResults '/All/' Sessions{iSession} '/BAASTA/fig_syncAccuracy_noOutliers.png'])
    saveas(figure(iPlot + 2), [pathResults '/All/' Sessions{iSession} '/BAASTA/fig_syncConsistencyRaw_noOutliers.png'])
    saveas(figure(iPlot + 3), [pathResults '/All/' Sessions{iSession} '/BAASTA/fig_syncConsistencyLogit_noOutliers.png'])

    iPlot = iPlot + 3;

end % End Sessions 
    
% Compute delta perf
deltaDir    = vectorDir(:,2:2:end,:) - vectorDir(:,1:2:end-1,:);
deltaLength = vectorLength(:,2:2:end,:) - vectorLength(:,1:2:end-1,:);
deltaLogit  = rLogit(:,2:2:end,:) - rLogit(:,1:2:end-1,:);

% Plot both sessions side by side
plotScatter(deltaDir, {'ST'}, Sessions, 'Synchronization Accuracy (°)');
plotScatter(deltaLength, {'ST'}, Sessions, 'Synchronization Consistency');
plotScatter(deltaLogit, {'ST'}, Sessions, 'Synchronization Consistency (logit)');

% Save plots
saveas(figure(iPlot + 1), [pathResults '/All/BAASTA/fig_deltaAccuracy_noOutliers.png'])
saveas(figure(iPlot + 2), [pathResults '/All/BAASTA/fig_deltaConsistencyRaw_noOutliers.png'])
saveas(figure(iPlot + 3), [pathResults '/All/BAASTA/fig_deltaConsistencyLogit_noOutliers.png'])


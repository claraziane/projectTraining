clear all;
close all;
clc;

% Declare paths
pathResults = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/';
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/'); %Functions for figures
addpath('/Users/claraziane/Documents/Académique/Informatique/projetDT')

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
        save([pathParticipant '/resultsBAASTA.mat'], 'resultsBAASTA');
        clear resultsBAASTA

    end % End Participants

    % Remove outliers
    vectorDir(:, :, iSession)    = removeOutliers(vectorDir(:, :, iSession));
    vectorLength(:, :, iSession) = removeOutliers(vectorLength(:, :, iSession));
    rLogit(:, :, iSession)       = removeOutliers(rLogit(:, :, iSession));

end % End Sessions 

% Plot
plotScatter(reshape(vectorDir, size(vectorDir,1), [], 1), Comparisons, Sessions,'Synchronization Accuracy (°)');
plotScatter(reshape(vectorLength, size(vectorLength,1), [], 1), Comparisons, Sessions, 'Synchronization Consistency');
plotScatter(reshape(rLogit, size(rLogit,1), [], 1), Comparisons, Sessions, 'Synchronization Consistency (logit)');

% Save plots
saveas(figure(1), [pathResults '/All/BAASTA/fig_syncAccuracy_noOutliers.png'])
saveas(figure(2), [pathResults '/All/BAASTA/fig_syncConsistencyRaw_noOutliers.png'])
saveas(figure(3), [pathResults '/All/BAASTA/fig_syncConsistencyLogit_noOutliers.png'])
    
% Compute delta perf
deltaDir    = vectorDir(:,2:2:end,:) - vectorDir(:,1:2:end-1,:);
deltaLength = vectorLength(:,2:2:end,:) - vectorLength(:,1:2:end-1,:);
deltaLogit  = rLogit(:,2:2:end,:) - rLogit(:,1:2:end-1,:);

% Plot both sessions side by side
plotScatter(reshape(deltaDir, size(deltaDir,1), [],1), {'ST'}, Sessions, 'Synchronization Accuracy (°)', 2);
plotScatter(reshape(deltaLength, size(deltaLength,1), [],1), {'ST'}, Sessions, 'Synchronization Consistency', 2);
plotScatter(reshape(deltaLogit, size(deltaLogit,1), [],1), {'ST'}, Sessions, 'Synchronization Consistency (logit)', 2);

% Save plots
saveas(figure(4), [pathResults '/All/BAASTA/fig_deltaAccuracy_noOutliers.png'])
saveas(figure(5), [pathResults '/All/BAASTA/fig_deltaConsistencyRaw_noOutliers.png'])
saveas(figure(6), [pathResults '/All/BAASTA/fig_deltaConsistencyLogit_noOutliers.png'])
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

for iSession = length(Sessions)

    % Preallocate matrix
    vectorDir    = nan(length(Participants), length(Comparisons));
    vectorLength = nan(length(Participants), length(Comparisons));

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
                    vectorDir(iParticipant, iCompare) = Scores.(['Paced_music_ross_mean' Variables{iVariable}])(participantIndex);
                elseif strcmpi(variableName{iVariable}, 'vectorLength')
                    rLogit(iParticipant, iCompare) = log(Scores.(['Paced_music_ross_mean' Variables{iVariable}])(participantIndex) ./ (1-Scores.(['Paced_music_ross_mean' Variables{iVariable}])(participantIndex)));    
                    vectorLength(iParticipant, iCompare) = Scores.(['Paced_music_ross_mean' Variables{iVariable}])(participantIndex);
                end

            end

        end % End Comparisons

        % Save results
        save([pathParticipant '/resultsBAASTA.mat'], 'resultsBAASTA');
        clear resultsBAASTA

    end % End Participants
    
    % Plot
    plotScatter(vectorDir, Comparisons, 'BAASTA', 'Synchronization Accuracy (°)');
    plotScatter(vectorLength, Comparisons, 'BAASTA', 'Synchronization Consistency');
    plotScatter(rLogit, Comparisons, 'BAASTA', 'Synchronization Consistency (logit)');

    % Save plots
    saveas(figure(1), [pathResults '/All/' Sessions{iSession} '/BAASTA/fig_syncAccuracy.png'])
    saveas(figure(2), [pathResults '/All/' Sessions{iSession} '/BAASTA/fig_syncConsistencyRaw.png'])
    saveas(figure(3), [pathResults '/All/' Sessions{iSession} '/BAASTA/fig_syncConsistencyLogit.png'])

end % End Sessions 
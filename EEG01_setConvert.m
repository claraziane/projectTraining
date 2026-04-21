%% This script converts .eeg files to .set files
% -Load .eeg file
% -Import channel locations
% -Remove accelerometer data
% -Save as .set file

close all;
clear all;
clc;

% Declare paths
pathData = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/DATA/');
addpath('/Users/claraziane/Documents/Académique/Informatique/MATLAB/eeglab2021.1')
chanStr = '/Users/claraziane/Documents/Académique/Informatique/MATLAB/eeglab2021.1/plugins/dipfit5.4/standard_BESA/standard-10-5-cap385.elp';

Participants = {'P07'}; 
Sessions     = {'RW'; 'FB'};
Conditions   = {'preTapST';  'preTapDT';  'postTapST'; 'postTapDT';...
               'preWalkST'; 'preWalkDT'; 'postWalkST'; 'postWalkDT'};

extRoot   = sprintf('.eeg');
extFinal  = sprintf('.set');

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
for iParticipant = :length(Participants)

    for iSession = 1:length(Sessions)
        pathRaw       = fullfile(pathData, 'RAW/', Participants{iParticipant},  Sessions{iSession}, '/EEG/');
        pathProcessed = fullfile(pathData, 'Processed/', Participants{iParticipant},  Sessions{iSession}, '/EEG/');

        for iCondition = 1:length(Conditions)

            fileRead  = [pathRaw Conditions{iCondition} extRoot];
            fileWrite = [pathProcessed Conditions{iCondition} extFinal];

            % Create folder for participant's processed data
            if ~exist(pathProcessed, 'dir')
                mkdir(pathProcessed)
            end

            % Import .eeg data into EEGLab
            EEG = pop_fileio(fileRead);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); % Edit/save EEG dataset structure information
            EEG = eeg_checkset(EEG);
          
            % Remove accelerometer data
             EEG = pop_chanedit(EEG, 'changefield',{65,'type','Acc'}, 'changefield',{66,'type','Acc'},'changefield',{67,'type','Acc'});
             EEG = eeg_checkset(EEG);

            % Add channel location
            EEG = pop_chanedit(EEG, 'lookup',chanStr);
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); % Stores specified EEG dataset(s) in the ALLEEG variable

            % Save
            EEG = pop_saveset(EEG, fileWrite);

            % Delete data from ALLEEG
            ALLEEG = [];

        end % Conditions

    end % Sessions

end % Participants

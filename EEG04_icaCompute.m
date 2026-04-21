%% Preprocessing data
% -Computes ICA
% -Cleans data by removing IC tagged as eye
close all;
clear all;
clc;

pathImport = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/DATA/Processed/';
addpath('/Users/claraziane/Documents/Académique/Informatique/MATLAB/eeglab2021.1')  % EEGLab
addpath('/Users/claraziane/Documents/Académique/Informatique/bemobil-pipeline');    % Bemobil pipeline
addpath('/Users/claraziane/Documents/Académique/Informatique/bemobil-pipeline/EEG_preprocessing')
addpath('/Users/claraziane/Documents/Académique/Informatique/bemobil-pipeline/AMICA_processing')

Participants = {'P07'};
Sessions     = {'RW'; 'FB'};
Conditions   = {'preTapST';  'preTapDT';  'postTapST'; 'postTapDT';...
               'preWalkST'; 'preWalkDT'; 'postWalkST'; 'postWalkDT'};

fileName  = 'preprocessed.set';

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
projectTraining_bemobil_config
for iParticipant = 1:length(Participants)

    for iSession = 2%length(Sessions)

        pathExport = [pathImport 'All/' Sessions{iSession} '/'];
        load([pathExport 'icReject.mat'])

        for iCondition = 1:length(Conditions) %1 P07?
           
            condStr = Conditions{iCondition};
            pathRoot  = fullfile(pathImport, '03_Preprocessing', Participants{iParticipant}, Sessions{iSession},Conditions{iCondition});

            % Load
            EEG = pop_loadset('filename', fileName,'filepath', pathRoot);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','on');

            % Remove baseline of the signal (must be before filtering)
            EEG = pop_rmbase(EEG, [],[]);
            EEG = eeg_checkset(EEG);

            % ICA decomposition
            [ALLEEG, EEG, CURRENTSET] = bemobil_process_all_AMICA(ALLEEG, EEG, CURRENTSET, str2num(Participants{iParticipant}(end-1:end)), Sessions{iSession}, condStr, bemobil_config);

            icReject.([Participants{iParticipant}]).([Conditions{iCondition}]) = EEG.etc.ic_cleaning.ICs_throw;
            save([pathExport '/icReject.mat'], 'icReject');

            ALLEEG = [];

        end
        
    end
    
end
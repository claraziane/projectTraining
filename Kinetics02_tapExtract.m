clear all; 
close all;
clc;

% Declare paths
pathData = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/DATA/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projetDT'); %Path to functions

Participants = {'P12'};
Sessions     = {'RW'; 'FB'};
Conditions   = {'preTapSP';  'preTapST'; 'preTapDT';...
                'postTapST'; 'postTapDT';...
               'postTapSP'};
            
for iParticipant = length(Participants)

    for iSession = 1:length(Sessions)

        % Declare paths
        pathImport = ([pathData 'RAW/' Participants{iParticipant} '/' Sessions{iSession} '/QTM/']);
        pathExport = ([pathData 'Processed/' Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/']);

        if ~exist(pathExport, 'dir')
            mkdir(pathExport)
        elseif exist([pathExport 'dataKin.mat'], 'file')
            load([pathExport 'dataKin.mat'])
        end

        for iCondition = 1:length(Conditions)

            Data  = load([pathImport Conditions{iCondition} '.mat']);
            Freq  = Data.(Conditions{iCondition}).Force(1).Frequency;

            if strcmpi(Conditions{iCondition}(end-1:end), 'SP')
                Time = Freq*60*1;
            else
                Time = Freq*60*5;
            end

            % Extact kenetic data from structure
            Kinetics = Data.(Conditions{iCondition}).Analog.Data(2,1:Time);

            % Extract tap onsets
            [mvtOnset, mvtFreq, IMI, cadence] = getTaps(Kinetics, Freq);

            % Store data in structure
            dataKin.([Conditions{iCondition}]).mvtOnset(:,1) = mvtOnset;   % Store tap onsets in structure
            dataKin.([Conditions{iCondition}]).mvtFreq(1,1)  = mvtFreq;    % Store tap frequency in structure
            dataKin.(Conditions{iCondition}).cadence         = cadence;    % Store number of taps per minute in structure
            dataKin.([Conditions{iCondition}]).IMI(:,1)      = IMI;        % Store inter-tap interval in structure
            dataKin.(Conditions{iCondition}).sampFreq        = Freq;
                       
            % Save structure
            save([pathExport '/dataKin'], 'dataKin');

            clear Kinetics mvtOnsets Data
            close all;

        end
        clear dataKin

    end

end

clear all; 
close all;
clc;

% Declare paths
pathData = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/DATA/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projetDT'); %Path to functions

Participants = {'P12'};
Sessions     = {'RW'; 'FB'};
Conditions   = {'preWalkSP';  'preWalkST'; 'preWalkDT';...
                'postWalkST'; 'postWalkDT';...
               'postWalkSP'};
            
for iParticipant = length(Participants)

    for iSession = 1%:length(Sessions)

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
            Kinetics = Data.(Conditions{iCondition}).Force(1).Force(3,1:Time)+...
                       Data.(Conditions{iCondition}).Force(2).Force(3,1:Time);

            % Extract step onsets
            [mvtOnsets] = getSteps(Kinetics, Freq);

            % Extract cadence and step frequency
            [cadence, mvtFreq] = getCadence(mvtOnsets, Freq);

            % Store data in structure
            dataKin.(Conditions{iCondition}).mvtOnsets = mvtOnsets;
            dataKin.(Conditions{iCondition}).mvtFreq   = mvtFreq;
            dataKin.(Conditions{iCondition}).cadence   = cadence;
            dataKin.(Conditions{iCondition}).sampFreq  = Freq;
            
            % Save structure
            save([pathExport '/dataKin'], 'dataKin');

            clear Kinetics mvtOnsets Data
            close all;

        end
        clear dataKin

    end

end

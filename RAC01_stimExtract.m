clear all;
close all;
clc;


% Declare paths
pathData = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/DATA/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projetDT'); %Path to functions

Participants = {'P07'}; %'P10; P12; 'P18'; 'P27'; 'P41'
Sessions     = {'RW'; 'FB'};
Conditions   = {'preWalkST';  'preWalkDT'; 'preTapST'; 'preTapDT';...
             'postWalkST'; 'postWalkDT';    'postTapST'; 'postTapDT'};
                        
for iParticipant = length(Participants)

    for iSession = 2%:length(Sessions)

        % Declare paths
        pathImport = ([pathData 'RAW/' Participants{iParticipant} '/' Sessions{iSession} '/']);
        pathExport = ([pathData 'Processed/' Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/']);

        if ~exist(pathExport, 'dir')
            mkdir(pathExport)
        elseif exist([pathExport 'dataRAC.mat'], 'file')
            load([pathExport 'dataRAC.mat'])
        end

        for iCondition = 1:length(Conditions)

            % Load data
            load([pathImport '/Audio/' Conditions{iCondition} '.mat'], 'dataAudio')
            Data  = load([pathImport '/QTM/' Conditions{iCondition} '.mat']);
            Freq  = Data.(Conditions{iCondition}).Analog.Frequency;

            % Define BPM
            if strcmp(Conditions{iCondition}(end-5:end-2), 'Walk')
                preferredBPM = dataAudio.walkBPM;
            elseif strcmp(Conditions{iCondition}(end-4:end-2), 'Tap')
                preferredBPM = dataAudio.tapBPM  ;
            end
            
            % Extact audio data from structure
            Audio = Data.([Conditions{iCondition}]).Analog.Data(1,1:Freq*60*5);

            % Extract beat frequency, BPM, and IOI
            [beatFreq, BPM, IOI, beatOnset] = getBeat(Audio, Freq, preferredBPM);
%           [beatFreq, BPM, IOI, beatOnset] = getBeat_fastStim(Audio, Freq, preferredBPM);

            % Extract beat category
            if strcmpi(Conditions{iCondition}(end-1:end), 'DT')
                load([pathImport '/Expe/' Conditions{iCondition} '_Targets.mat'], 'Beats');
                Beats(Beats   == 0) = [];
                Beats = Beats(end-length(beatOnset)+1:end);
                 for iBeat = 1:length(beatOnset)
                     if Beats(iBeat) == 1
                         beatCat{iBeat, 1} = 'Standard';
                     elseif Beats(iBeat) == 2
                         beatCat{iBeat, 1} = 'targetLow';
                     elseif Beats(iBeat) == 3
                         beatCat{iBeat, 1} = 'targetHigh';
                     end
                end
            else
                for iBeat = 1:length(beatOnset)
                    beatCat{iBeat, 1} = 'Standard';
                end
            end

            % Store data in structure
            dataRAC.([Conditions{iCondition}]).beatOnset(:,1)     = beatOnset; % Store beat onsets in structure
            dataRAC.([Conditions{iCondition}]).beatFrequency(1,1) = beatFreq;  % Store frequency in structure (other method)
            dataRAC.([Conditions{iCondition}]).BPM(1,1)           = BPM;       % Store BPM in structure
            dataRAC.(Conditions{iCondition}).sampFreq             = Freq;
            dataRAC.(Conditions{iCondition}).beatCat              = beatCat;

            % Save structure
            save([pathExport 'dataRAC.mat'], 'dataRAC');
            
            clear Audio beatOnset IOI dataAudio         
            close all;

        end %Conditions
        clear dataRAC 

    end %Sessions

end %Participants

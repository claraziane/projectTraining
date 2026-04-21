%% Importing events
% -Remove data before and after triggers
% -Import all beat onsets within EEG structure
% -Import all tap onsets within EEG structure
% -Import all step onsets within EEG structure

close all;
clear all;
clc;

% Declare paths
pathData    = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/DATA/Processed/');
addpath('/Users/claraziane/Documents/Académique/Informatique/MATLAB/eeglab2021.1')

Participants = {'P07'}; %'P10; P12; 'P18'; 'P27'; 'P41'
Sessions     = {'RW'; 'FB'};
Conditions   = {'preTapST';  'preTapDT';  'postTapST'; 'postTapDT';...
               'preWalkST'; 'preWalkDT'; 'postWalkST'; 'postWalkDT'};

extRoot  = '.set';
extFinal = '_events.set';
         
warning('on')
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
for iParticipant = length(Participants)

    for iSession = 1:length(Sessions)

        pathProcessed = fullfile(pathData, Participants{iParticipant}, Sessions{iSession}, '/EEG/');
        if ~exist(pathProcessed, 'dir')
            mkdir(pathProcessed)
        end        
        
        % Load events
        load([pathData Participants{iParticipant} '/' Sessions{iSession}, '/Behavioural/dataKin.mat'])
        load([pathData Participants{iParticipant} '/' Sessions{iSession}, '/Behavioural/dataRAC.mat'])

        for iCondition =  1:length(Conditions)

            fileRead  = [Conditions{iCondition} extRoot];
            fileWrite = [Conditions{iCondition} extFinal];

            % Load data
            EEG = pop_loadset('filename', fileRead,'filepath', pathProcessed);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','on');

            %% Start/End triggers

            % Keep only signal inbetween start and end triggers
            triggers =  [EEG.event.latency];

            for iTrigger = 1:length(triggers)

                if strcmpi(({EEG.event(iTrigger).type(1:4)}), 'S 15')

                    if triggers(iTrigger) == min(triggers(iTrigger:end)) && ~exist('triggerStart','var')
                        triggerStart =  triggers(iTrigger) + (997.5/(1000/EEG.srate)); %Accounts for delay from qualisys and wireless trigger
                        triggerEnd   =  triggerStart + (EEG.srate*60*5) -1;
                    end

                end

            end
            EEG = pop_select(EEG,'time',[triggerStart/ALLEEG.srate triggerEnd/ALLEEG.srate]);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'overwrite', 'on', 'gui','off'); % Edit/save EEG dataset structure information
            
            disp(EEG.pnts)
            if EEG.pnts ~= EEG.srate*60*5
                warning(['Number of points incorrect for ' Participants{iParticipant} ' during ' Conditions{iCondition} '!!'])
                pause()
            end

            %% Beat onsets
            % Extract events' acquisition frequency
            beatRate = dataRAC.(Conditions{iCondition}).sampFreq;

            % Extract events from structure
            beatOnsets = dataRAC.(Conditions{iCondition}).beatOnset;

            % Interpolate values to fit EEG acquisition frequency
            beatOnsets = round(beatOnsets * (EEG.srate/beatRate));

            nEvents = length(EEG.event);
            for iEvent=1:length(beatOnsets)
                EEG.event(nEvents+iEvent).type = 'RAC' ;
                EEG.event(nEvents+iEvent).latency = beatOnsets(iEvent) ;
                EEG.event(nEvents+iEvent).duration = 1 ;
                EEG.event(nEvents+iEvent).urevent = nEvents+iEvent  ;
            end
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');

            %% Movements      

            % Extract events' acquisition frequency
            mvtRate = dataKin.(Conditions{iCondition}).sampFreq;

            % Extract events from structure
            mvtOnsets = dataKin.(Conditions{iCondition}).mvtOnsets;

            % Interpolate values to fit EEG acquisition frequency
            mvtOnsets = round(mvtOnsets * (EEG.srate/mvtRate));

            nEvents = length(EEG.event);
            for iEvent=1:length(mvtOnsets)
                EEG.event(nEvents+iEvent).type = 'Mvt' ;
                EEG.event(nEvents+iEvent).latency = mvtOnsets(iEvent) ;
                EEG.event(nEvents+iEvent).duration = 1 ;
                EEG.event(nEvents+iEvent).urevent = nEvents+iEvent  ;
            end
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');

            % Save new _event.set file in preprocessed folder
            EEG = pop_saveset(EEG, 'filename', fileWrite, 'filepath', pathProcessed);

            ALLEEG = []; EEG = [];
            clear beatOnsets mvtOnsets triggerStart triggerEnd triggers

        end % Condtitions

        clear dataKin dataRAC

    end % Sessions

end % Participants
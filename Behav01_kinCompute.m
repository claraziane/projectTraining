clear all;
close all;
clc;

% Declare paths
pathData = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/DATA/Processed/');
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');

Participants = {'P07'};
Sessions     = {'RW'; 'FB'};
Conditions   = {'preTapSP';   'preTapST';   'preTapDT';...
                'postTapST';  'postTapDT';  'postTapSP';...
                'preWalkSP';  'preWalkST';  'preWalkDT';...
                'postWalkST'; 'postWalkDT'; 'postWalkSP'};
    
for iParticipant = 1:length(Participants)

    for iSession = 1:length(Sessions)

        pathExport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/'];
        if ~exist(pathExport, 'dir')
            mkdir(pathExport)
        end

        % Load behavioural data
        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataKin.mat']);

        for iCondition = 1:length(Conditions)
            IMI = [];

                % Extract acquisition frequency
                Freq = dataKin.([Conditions{iCondition}]).sampFreq;

                % Extracting step onsets   
                Onsets = [];
                Onsets = dataKin.([Conditions{iCondition}]).mvtOnsets;
                IMI = diff(Onsets); 

            % Convert frames to ms                  
            IMI = (IMI / Freq) * 1000; 

            % Computing coefficient of variability of inter-mvt intervals
            imiStd = std(IMI);
            imiCV = imiStd/mean(IMI);

            % Storing results in structure
            resultsBehav.([Conditions{iCondition}]).IMI     = IMI;
            resultsBehav.([Conditions{iCondition}]).imiMean = mean(IMI);
            resultsBehav.([Conditions{iCondition}]).imiCV   = imiCV;
            resultsBehav.([Conditions{iCondition}]).cadence = dataKin.([Conditions{iCondition}]).cadence;

        end % End Conditions

        % Save results
        save([pathExport 'resultsBehav.mat'], 'resultsBehav');

        clear resultsBehav dataKin

    end % End Sessions

end % End Participants

clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');
addpath '/Users/claraziane/Documents/Académique/Informatique/projetDT'
addpath '/Users/claraziane/Documents/Académique/Informatique/projectFig'

Participants = {'P04'; 'P07'; 'P10'; 'P11'; 'P12'; 'P13'; 'P16'; 'P18'; 'P21'; 'P23'; 'P25'; 'P26'; 'P27'; 'P29'; 'P36'; 'P37'; 'P39'; 'P40'; 'P41'; 'P44'};
Game         = {'RW'; 'FB'};
xLabels      = {'RW', 'FB', 'RW', 'FB', 'RW', 'FB', 'RW', 'FB', 'RW', 'FB', 'RW', 'FB';
                'FB', 'RW', 'FB', 'RW', 'FB', 'RW', 'FB', 'RW', 'FB', 'RW', 'FB', 'RW'};

% Load demographic info
gameAssign = readtable('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/dataCollection/subjectAssignment.xlsx');

for iMovement = 1:2

    if iMovement == 1
        Conditions   = {'preTapST'; 'postTapST'; 'preTapST'; 'postTapST';...
                        'preTapDT'; 'postTapDT'; 'preTapDT'; 'postTapDT'};

    else
        Conditions   = {'preWalkST'; 'postWalkST'; 'preWalkST'; 'postWalkST';...
                        'preWalkDT'; 'postWalkDT'; 'preWalkDT'; 'postWalkDT'};

    end
    syncConsistency = nan(length(Participants), length(Conditions), length(Game));

    for iGame = 1:length(Game)

        for iParticipant = 1:length(Participants)

            % Load data
            pathImport = [pathResults Participants{iParticipant} '/' Game{iGame}];
            load([pathImport  '/Behavioural/resultsSync.mat']);

            % Find participant's line in gameAssign table
            for iLine = 1:size(gameAssign,1)
                if strcmpi(gameAssign.ID{iLine}, Participants{iParticipant})
                    subjline = iLine;
                    break;
                end
            end

            % Find game assigned
            Group = gameAssign.Group(iLine);
            Group = char(Group);

            if strcmpi(Group, Game{iGame})

                for iCondition = [1 2 5 6]
                    syncConsistency(iParticipant, iCondition, iGame) = log(resultsSync.(Conditions{iCondition}).resultantLength ./ (1-resultsSync.(Conditions{iCondition}).resultantLength));
                end

            else
                if iGame == 1
                    gameIndex = 2;
                elseif iGame == 2
                    gameIndex = 1;
                end

                for iCondition = [3 4 7 8]
                    syncConsistency(iParticipant, iCondition, gameIndex) = log(resultsSync.(Conditions{iCondition}).resultantLength ./ (1-resultsSync.(Conditions{iCondition}).resultantLength));
                end


            end

        end

    end

    for iGame = 1:length(Game)
        syncConsistency(:,:,iGame) = removeOutliers(syncConsistency(:,:,iGame));

        plotScatter(syncConsistency(:,:,iGame),[], [xLabels(iGame,:)]', 'Synchronization Consistency (logit)', 4);
        sgtitle(['Participants who started with ' Game{iGame}], 'FontSize', 20, 'FontWeight', 'bold')
                
    end

end
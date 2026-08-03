clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants   = {'P04'; 'P07'; 'P10'; 'P11'; 'P12'; 'P13'; 'P16'; 'P18'; 'P21'; 'P23'; 'P25'; 'P26'; 'P27'; 'P29'; 'P36'; 'P37'; 'P39'; 'P40'; 'P41'; 'P44'};
factorGame     = {'RW'; 'FB'};
factorTime     = {'Pre'; 'Post'};

%Pre-allocating matrices
ID       = [];
Game     = [];
Time     = [];
syncConsistency = [];
syncAccuracy    = []; 

% Load demographic info
dataDemog = readtable([pathResults 'All/demographicInfo.xlsx']);

for iParticipant = 1:length(Participants)

    for iGame = 1:length(factorGame)

        load([pathResults Participants{iParticipant} '/' factorGame{iGame} '/BAASTA/resultsBAASTA.mat'])

        for iTime = 1:length(factorTime)

            % Find participant's line in demographic table
            ID = [ID ; {Participants{iParticipant}}];
            for iLine = 1:size(dataDemog,1)
                if strcmpi(dataDemog.ID{iLine}, Participants{iParticipant})
                    subjline = iLine;
                    break;
                end
            end

            % Fill stats table
            Game     = [Game; {factorGame{iGame}}];
            Time     = [Time; {factorTime{iTime}}];

            syncConsistency = [syncConsistency; log(resultsBAASTA.(factorTime{iTime}).vectorLength ./ (1-resultsBAASTA.(factorTime{iTime}).vectorLength))];
            syncAccuracy    = [syncAccuracy; resultsBAASTA.(factorTime{iTime}).vectorDir];

        end

    end

end

% Convert to table format
resultsTable = table(ID, Game, Time, syncConsistency, syncAccuracy, 'VariableNames', {'ID', 'Game', 'Time', 'syncConsistency', 'syncAccuracy'});
writetable(resultsTable, [pathResults '/All/statsTableBAASTA_noOutliers.csv'])
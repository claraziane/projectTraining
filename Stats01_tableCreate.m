clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants   = {'P04'; 'P07'; 'P10'; 'P11'; 'P12'; 'P13'; 'P16'; 'P18'; 'P21'; 'P23'; 'P25'; 'P26'; 'P27'; 'P29'; 'P36'; 'P37'; 'P39'; 'P40'; 'P41'; 'P44'}; %RW
factorGame     = {'RW'; 'FB'};
factorTime     = {'pre'; 'post'};
factorMovement = {'Tap'; 'Walk'};
factorLoad     = {'SP'; 'ST'; 'DT'}; % 'SP'; 

%Pre-allocating matrices
ID       = [];
Game     = [];
Time     = [];
Movement = [];
Load     = [];

mvtVariability  = [];
mvtIMI          = [];
syncAccuracy    = [];
syncConsistency = [];

Flexibility   = [];
Inhibition    = [];
workingMemory = [];

BAT = [];
BTI = [];

% Load demographic info
dataDemog = readtable([pathResults 'All/demographicInfo.xlsx']);

for iParticipant = 1:length(Participants)

    for iGame = 1:length(factorGame)

        load([pathResults Participants{iParticipant} '/' factorGame{iGame} '/Behavioural/resultsBehav.mat'])
        load([pathResults Participants{iParticipant} '/' factorGame{iGame} '/Behavioural/resultsSync.mat'])
        load([pathResults Participants{iParticipant} '/' factorGame{iGame} '/Behavioural/resultsOddball.mat'])
        load(['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/' Participants{iParticipant} '/01/resultsCog.mat'])

        for iTime = 1:length(factorTime)

            for iMovement = 1:length(factorMovement)

                for iLoad = 1:length(factorLoad)
                    condition = strcat(factorTime(iTime), factorMovement(iMovement), factorLoad(iLoad));

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
                    Movement = [Movement; {factorMovement(iMovement)}];
                    Load     = [Load; {factorLoad{iLoad}}];

                    mvtVariability  = [mvtVariability; resultsBehav.(condition{1,1}).imiCV];
                    mvtIMI          = [mvtIMI; resultsBehav.(condition{1,1}).imiMean];

%                     % EEG variables
%                     if strcmpi(resultsEEG.(condition{1,1}).compKeep, 'N')
%                         power = [power; NaN];
%                         phaseCoupling = [phaseCoupling; NaN];
%                         ITPC = [ITPC; NaN];
%                         stabilityIndex = [stabilityIndex; NaN];
% 
%                     else
%                         stabilityIndex  = [stabilityIndex; resultsEEG.(condition{1,1}).stabilityIndex];
%                         power  = [power; resultsEEG.(condition{1,1}).power];
% 
%                         % Logit transformation
%                         phase = [];
%                         phase = resultsEEG.(condition{1,1}).phaseR;
%                         phaseCoupling = [phaseCoupling; phase];
%                         ITPC  = [ITPC; log(phase ./ (1-phase))];
%                     end

                    %% Cognitive functions
                    Flexibility   = [Flexibility; resultsCog.Flexibility];
                    Inhibition    = [Inhibition; resultsCog.Inhibition];
                    workingMemory = [workingMemory; resultsCog.workingMemory];

                    %% Rhythmic Abilities

                    if ~strcmpi(factorLoad(iLoad), 'SP')

                        if resultsSync.(condition{1,1}).pRaleigh >= 0.05
                            syncAccuracy = [syncAccuracy; NaN];
                        else
                            syncAccuracy = [syncAccuracy; resultsSync.(condition{1,1}).phaseDegMean];
                        end
                        syncConsistency = [syncConsistency; log(resultsSync.(condition{1,1}).resultantLength ./ (1-resultsSync.(condition{1,1}).resultantLength))];

                    end

%                     % BAT
%                     BAT   = [BAT; resultsBAASTA.BAT];
% 
%                     % Classify participants based on beat perception
%                     [splitBAT] = findMedianSplit('BAT', [], 'resultsBAASTA');
%                     if resultsBAASTA.BAT > splitBAT
%                         beatPerception = [beatPerception; 'Good'];
%                     else
%                         beatPerception = [beatPerception; 'Poor'];
%                     end
% 
%                     % BTI
%                     BTI   = [BTI; resultsBAASTA.BTI];
% 
%                     % Classify participants based on BTI
%                     [splitBTI] = findMedianSplit('BTI', [], 'resultsBAASTA');
%                     if resultsBAASTA.BTI >= splitBTI
%                         rhythmSkills = [rhythmSkills; 'Good'];
%                     else
%                         rhythmSkills = [rhythmSkills; 'Poor'];
%                     end

                end

            end

        end

    end

end

% Convert to table format
resultsTable = table(ID, Game, Time, Movement, Load, mvtIMI, mvtVariability, Flexibility, Inhibition, workingMemory, ...
'VariableNames', {'ID', 'Game', 'Time', 'Movement', 'Load', 'IMI', 'CV', 'Flexibility', 'Inhibition', 'workingMemory'});
% Save table
writetable(resultsTable, [pathResults '/All/statsTableBehav.csv'])

% % Sync only
% resultsTable = table(ID, Game, Time, Movement, Load, syncAccuracy, syncConsistency, Flexibility, Inhibition, workingMemory, ...
% 'VariableNames', {'ID', 'Game', 'Time', 'Movement', 'Load', 'syncAccuracy', 'syncConsistency', 'Flexibility', 'Inhibition', 'workingMemory'});
% writetable(resultsTable, [pathResults '/All/statsTableSync.csv'])


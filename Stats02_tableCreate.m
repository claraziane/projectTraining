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
factorLoad     = {'SP'; 'ST'; 'DT'};

%Pre-allocating matrices
ID       = [];
Game     = [];
Movement = [];
Load     = [];

mvtVariability  = [];
mvtIMI          = [];
syncAccuracy    = [];
syncConsistency = [];

Flexibility   = [];
Inhibition    = [];
workingMemory = [];

musicConsistency = [];

% Load demographic info
dataDemog = readtable([pathResults 'All/demographicInfo.xlsx']);

for iParticipant = 1:length(Participants)

    for iGame = 1:length(factorGame)

        load([pathResults Participants{iParticipant} '/' factorGame{iGame} '/Behavioural/resultsBehav.mat'])
        load([pathResults Participants{iParticipant} '/' factorGame{iGame} '/Behavioural/resultsSync.mat'])
        load([pathResults Participants{iParticipant} '/' factorGame{iGame} '/Behavioural/resultsOddball.mat'])
        load([pathResults Participants{iParticipant} '/' factorGame{iGame} '/BAASTA/resultsBAASTA.mat'])

        load(['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/' Participants{iParticipant} '/01/resultsCog.mat'])

        for iMovement = 1:length(factorMovement)

            for iLoad = 1:length(factorLoad)

                for iTime = 1:length(factorTime)

                    condition = strcat(factorTime(iTime), factorMovement(iMovement), factorLoad(iLoad));

                    if iTime == 1

                        preVar = resultsBehav.(condition{1,1}).imiCV;
                        preIMI = resultsBehav.(condition{1,1}).imiMean;

                        if ~strcmpi(factorLoad(iLoad), 'SP')
                            preAccuracy = resultsSync.(condition{1,1}).phaseDegMean;
                            preConsistency = log(resultsSync.(condition{1,1}).resultantLength ./ (1-resultsSync.(condition{1,1}).resultantLength));
                        end

                        preMusic = log(resultsBAASTA.(strcat('P', condition{1,1}(2:3))).vectorLength ./ (1-resultsBAASTA.(strcat('P', condition{1,1}(2:3))).vectorLength));


                    else

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
                        Movement = [Movement; {factorMovement(iMovement)}];
                        Load     = [Load; {factorLoad{iLoad}}];

                        mvtVariability  = [mvtVariability; resultsBehav.(condition{1,1}).imiCV - preVar];
                        mvtIMI          = [mvtIMI; resultsBehav.(condition{1,1}).imiMean - preIMI];

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

                            %                         if resultsSync.(condition{1,1}).pRaleigh >= 0.05
                            %                             syncAccuracy = [syncAccuracy; NaN];
                            %                         else
                            syncAccuracy = [syncAccuracy; resultsSync.(condition{1,1}).phaseDegMean - preAccuracy];
                            %                         end
                            syncConsistency = [syncConsistency;...
                                log(resultsSync.(condition{1,1}).resultantLength ./ (1-resultsSync.(condition{1,1}).resultantLength)) - preConsistency];

                        end

                        % BAASTA
                        musicConsistency = [musicConsistency;...
                            log(resultsBAASTA.(strcat('P', condition{1,1}(2:4))).vectorLength ./ (1-resultsBAASTA.(strcat('P', condition{1,1}(2:4))).vectorLength)) - preMusic];


                    end

                end

            end

        end

    end

end

% Convert to table format
resultsTable = table(ID, Game, Movement, Load, mvtIMI, mvtVariability, Flexibility, Inhibition, workingMemory, ...
    'VariableNames', {'ID', 'Game', 'Movement', 'Load', 'IMI', 'CV', 'Flexibility', 'Inhibition', 'workingMemory'});
% Save table
writetable(resultsTable, [pathResults '/All/statsTableBehav.csv'])

% % Sync only
% resultsTable = table(ID, Game, Movement, Load, syncAccuracy, syncConsistency, Flexibility, Inhibition, workingMemory, ...
% 'VariableNames', {'ID', 'Game', 'Movement', 'Load', 'syncAccuracy', 'syncConsistency', 'Flexibility', 'Inhibition', 'workingMemory'});
% writetable(resultsTable, [pathResults '/All/statsTableSync.csv'])

% % BAASTA only
% resultsTable = table(ID, Game, Movement, Load, musicConsistency, Flexibility, Inhibition, workingMemory, ...
% 'VariableNames', {'ID', 'Game', 'Movement', 'Load', 'musicConsistency', 'Flexibility', 'Inhibition', 'workingMemory'});
% writetable(resultsTable, [pathResults '/All/statsTableBAASTA.csv'])

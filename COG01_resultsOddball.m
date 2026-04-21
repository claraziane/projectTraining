clear;
close all;
clc;

% Declare paths
pathData     = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/DATA/RAW/');
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');

Participants = {'P04'; 'P07'; 'P10'; 'P11'; 'P12'; 'P13'; 'P16'; 'P18'; 'P21'; 'P23'; 'P25'; 'P26'; 'P27'; 'P29'; 'P36'; 'P37'; 'P39'; 'P40'; 'P41'; 'P44'}; %RW

Sessions     = {'RW'; 'FB'};
Conditions   = {'preTapDT'; 'postTapDT'; 'preWalkDT';'postWalkDT'};

for iParticipant = 1:length(Participants)

    for iSession = 1:length(Sessions)
        dataCog = readtable([pathData Participants{iParticipant} '/' Sessions{iSession} '/Expe/oddball.xlsx']);


        for iCondition = 1:length(Conditions)
            for iLine = 1:size(dataCog,1)
                if strcmpi(dataCog.Var1{iLine}, Conditions{iCondition})
                    Condline = iLine;
                end
            end

            lowError  = abs(dataCog.TrueValue(Condline) - dataCog.Counted(Condline));
            highError = abs(dataCog.TrueValue_1(Condline) - dataCog.Counted_1(Condline));


            resultsOddball.(Conditions{iCondition}) = lowError + highError;

        end
        save([pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/resultsOddball.mat'], 'resultsOddball');
        clear resultsOddball

    end


end

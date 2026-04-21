clear all; 
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/'); %Functions for figures

Participants = {'P04'; 'P07'; 'P10'; 'P11'; 'P12'; 'P13'; 'P16'; 'P18'; 'P21'; 'P23'; 'P25'; 'P26'; 'P27'; 'P29'; 'P36'; 'P37'; 'P39'; 'P40'; 'P41'; 'P44'}; %RW

Sessions     = {'RW'; 'FB'};
Conditions   = {'preTapDT'; 'postTapDT'; 'preWalkDT'; 'postWalkDT'};
xLabels      = {  'preTap';   'postTap';   'preWalk';   'postWalk'};  
Comparisons = {'DT'};

for iSession = 1:length(Sessions)
    iPlot = 1;

    % Preallocate matrix
    Errors   = nan(length(Participants),length(Conditions));

    for iCondition = 1:length(Conditions)

        for iParticipant = 1:length(Participants)

            pathImport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/'];
            load([pathImport 'resultsOddball.mat']);

            Errors(iParticipant, iCondition) = resultsOddball.(Conditions{iCondition});
               
        end % End Participants

    end % End Conditions
    
    % Plot
    plotScatter(Errors, Comparisons, xLabels, 'Number of Errors');
   
    % Save
    saveas(figure(1), [pathResults 'All/' Sessions{iSession} '/Cognition/fig_cogOddball.png'])
    close all;

end % End Sessions
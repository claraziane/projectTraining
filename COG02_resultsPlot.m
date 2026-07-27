clear all; 
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/'); %Functions for figures

Participants = {'P04'; 'P07'; 'P10'; 'P11'; 'P12'; 'P13'; 'P16'; 'P18'; 'P21'; 'P23'; 'P25'; 'P26'; 'P27'; 'P29'; 'P36'; 'P37'; 'P39'; 'P40'; 'P41'; 'P44'}; %RW

Sessions     = {'RW'; 'FB'};
Conditions   = {'preTapDT'; 'postTapDT'; 'preWalkDT'; 'postWalkDT'};
figLabels    = {'preTapDT'; 'postTapDT'; 'preWalkDT'; 'postWalkDT'; 'preTapDT'; 'postTapDT'; 'preWalkDT'; 'postWalkDT'};
xLabels      = {  'preTap';   'postTap';   'preWalk';   'postWalk'};  
Comparisons  = {'DT'};

% Preallocate matrix
Errors   = nan(length(Participants),length(Conditions), length(Sessions));

for iSession = 1:length(Sessions)
    iPlot = 1;

    for iCondition = 1:length(Conditions)

        for iParticipant = 1:length(Participants)

            pathImport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/'];
            load([pathImport 'resultsOddball.mat']);

            Errors(iParticipant, iCondition, iSession) = resultsOddball.(Conditions{iCondition});
               
        end % End Participants

    end % End Conditions
    
    % Remove outliers
    [Errors(:,:,1)] = removeOutliers(Errors(:,:,1));

    % Plot
    plotScatter(Errors(:,:,iSession), Comparisons, xLabels, 'Number of Errors');
   
    % Save
    saveas(figure(iSession), [pathResults 'All/' Sessions{iSession} '/Cognition/fig_cogOddball_noOutliers.png'])

end % End Sessions

% Compute delta perf
deltaErrors = Errors(:,2:2:end,:) - Errors(:,1:2:end-1,:);

% Plot both sessions side by side
plotScatter(reshape(Errors, size(Errors,1), [],1), Comparisons, figLabels, 'Number of Errors');
plotScatter(reshape(deltaErrors, size(deltaErrors,1), [],1), Comparisons, {'Tap__RW'; 'Walk__RW'; 'Tap__FB'; 'Walk__FB'}, 'Number of Errors');

% Save
saveas(figure(iSession+1), [pathResults 'All/Cognition/fig_cogOddball_noOutliers.png'])
saveas(figure(iSession+2), [pathResults 'All/Cognition/fig_deltaOddball_noOutliers.png'])

close all;
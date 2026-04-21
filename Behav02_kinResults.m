clear all; 
close all;
clc;

% Declare paths
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/'); %Functions for figures

Participants = {'P04'; 'P07'; 'P10'; 'P11'; 'P12'; 'P13'; 'P16'; 'P18'; 'P21'; 'P23'; 'P25'; 'P26'; 'P27'; 'P29'; 'P36'; 'P37'; 'P39'; 'P40'; 'P41'; 'P44'}; %FB

Sessions     = {'RW'; 'FB'};
Conditions   = {'TapSP';  'TapST';  'TapDT';
                'WalkSP'; 'WalkST'; 'WalkDT'};
Comparisons  = {'pre'; 'post'};

for iSession = 1:length(Sessions)
    iPlot = 1;

    % Preallocate matrix
    imiCV      = nan(length(Participants),length(Conditions)*length(Comparisons));
    imiMean    = nan(length(Participants),length(Conditions)*length(Comparisons));
    cadence    = nan(length(Participants),length(Conditions)*length(Comparisons));

    for iCondition = 1:length(Conditions)

        for iParticipant = 1:length(Participants)

            % Load data
            pathImport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/'];
            load([pathImport 'resultsBehav.mat']);

            for iCompare = 1:length(Comparisons)
                condName = [Comparisons{iCompare} Conditions{iCondition}];

                imiCV(iParticipant, iPlot+iCompare-1)   = resultsBehav.(condName).imiCV;
                imiMean(iParticipant, iPlot+iCompare-1) = resultsBehav.(condName).imiMean;
                cadence(iParticipant, iPlot+iCompare-1) = resultsBehav.(condName).cadence;

                if iCompare == 2
                    deltaCV(iParticipant, iCondition) = resultsBehav.(condName).imiCV - imiCV(iParticipant, iPlot+iCompare-2);
                    deltaIMI(iParticipant, iCondition) = resultsBehav.(condName).imiMean - imiMean(iParticipant, iPlot+iCompare-2);
                    deltaCadence(iParticipant, iCondition) = resultsBehav.(condName).cadence - cadence(iParticipant, iPlot+iCompare-2);
                end

            end % End Comparisons

            if iParticipant == length(Participants)
                iPlot = iPlot + 2; 
            end

        end % End Participants

    end % End Conditions

    % Plot
    plotScatter(imiCV, Comparisons, Conditions, 'Coefficient of Variation_{Inter-Movement Interval}');
    plotScatter(imiMean, Comparisons, Conditions, 'Inter-Movement Interval (ms)');
    plotScatter(cadence, Comparisons, Conditions, 'Cadence (movements per minute)');

    plotScatter(deltaCV, [], Conditions, '\Delta_{Coefficient of Variation}');
    plotScatter(deltaIMI, [], Conditions, '\Delta_{Inter-Movement Interval} (ms)');
    plotScatter(deltaCadence, [], Conditions, '\Delta_{Cadence} (movements per minute)');

    % Save
    saveas(figure(1), [pathResults '/All/' Sessions{iSession} '/Behavioural/fig_mvtCV.png'])
    saveas(figure(2), [pathResults '/All/' Sessions{iSession} '/Behavioural/fig_mvtIMI.png'])
    saveas(figure(3), [pathResults '/All/' Sessions{iSession} '/Behavioural/fig_mvtCadence.png'])

    saveas(figure(4), [pathResults '/All/' Sessions{iSession} '/Behavioural/fig_deltaCV.png'])
    saveas(figure(5), [pathResults '/All/' Sessions{iSession} '/Behavioural/fig_deltaIMI.png'])
    saveas(figure(6), [pathResults '/All/' Sessions{iSession} '/Behavioural/fig_deltaCadence.png'])

    close all;

end % End Sessions
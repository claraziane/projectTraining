clear all; 
close all;
clc;

% Declare paths
pathData     = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/DATA/Processed/');
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants = {'P07'};
Sessions     = {'RW'; 'FB'};
Conditions   = {'preTapST';   'preTapDT';...
                'postTapST';  'postTapDT';...
                'preWalkST';  'preWalkDT';...
                'postWalkST'; 'postWalkDT'};
   
for iParticipant = 1:length(Participants)

    for iSession = 1:length(Sessions)

        pathExport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/'];
        if ~exist(pathExport, 'dir')
            mkdir(pathExport)
        end

        % Load behavioural data
        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataKin.mat']);
        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataRAC.mat']);

        for iCondition = 1:length(Conditions)

            % Extract acquisition frequency
            freqRAC  = dataRAC.([Conditions{iCondition}]).sampFreq;

            % Extracting beat onsets
            beatOnset = [];
            beatOnset = dataRAC.([Conditions{iCondition}]).beatOnset;
            beatOnset = (beatOnset / freqRAC) * 1000; %Convert to ms
            IOI = mean(diff(beatOnset));

            mvtOnset = [];
            freqMvt = dataKin.([Conditions{iCondition}]).sampFreq;

            % Extracting mvt onsets
            mvtOnset = dataKin.([Conditions{iCondition}]).mvtOnsets(2:end-1);
            mvtOnset = (mvtOnset / freqMvt) * 1000; %Convert to ms

            %% Estimating period-matching accuracy (i.e., extent to which step tempo matches stimulus tempo) using IBI deviation

            % Matching step onsets to closest beat
            beatMatched = [];
            for iMvt = 1:length(mvtOnset)
                [minValue matchIndex] = min(abs(beatOnset-mvtOnset(iMvt)));
                beatMatched(iMvt,1) = beatOnset(matchIndex);
            end

            % Calculating interstep interval
            mvtInterval = [];
            mvtInterval = diff(mvtOnset);

            % Calculating interbeat interval
            racInterval = [];
            racInterval = diff(beatMatched);
            
            % Calculating IBI deviation
            IBI = [];
            IBI = mean(abs(mvtInterval - racInterval))/mean(racInterval);

            %% Estimating phase-matching accuracy (i.e., the difference between step onset times and beat onset times) using circular asynchronies
            asynchrony           = [];
            asynchronyNormalized = [];
            asynchronyCircular   = [];
            asynchronyRad        = [];

            asynchrony           = mvtOnset - beatMatched;
            asynchronyNormalized = asynchrony(1:end-1)./mvtInterval;
            asynchronyCircular   = asynchronyNormalized * 360;
            asynchronyRad        = asynchronyCircular * pi/180;
            asynchronyMean       = circ_mean(asynchronyRad, [], 1);
%             figure; scatter(1,asynchronyCircular)

            % Running Rao's test (a not-significant test means participant failed to synchronize)
            [pRao U UC] = circ_raotest(asynchronyCircular);

            % Calculating circular variance
            [varianceCircular varianceAngular] = circ_var(asynchronyRad);

            % Calculating phase angles (error measure of synchronization based on the phase difference between two oscillators)
            phaseAngle     = [];
            phaseAngle     = 360*(asynchrony/IOI);
            
            phaseError     = [];
            phaseError     = abs(phaseAngle);
            phaseErrorRad  = deg2rad(phaseError);
            phaseErrorMean = circ_mean(phaseErrorRad(phaseErrorRad ~=0), [], 1);

            phaseRad       = [];
            phaseRad       = deg2rad(phaseAngle);
            phaseRadMean = circ_mean(phaseRad(phaseRad ~=0), [], 1);

            % Calculating resultant vector length (expresses the stability of the relative phase angles over time)
            resultantLength = circ_r(phaseRad, [], [], 1);
            [pRaleigh] = circ_rtest(phaseRad);

            % Storing results in structure
            resultsSync.([Conditions{iCondition}]).IBIDeviation = IBI;
            resultsSync.([Conditions{iCondition}]).Asynchrony = asynchrony;
            resultsSync.([Conditions{iCondition}]).circularAsynchrony = asynchronyCircular;
            resultsSync.([Conditions{iCondition}]).asynchronyMean = asynchronyMean;
            resultsSync.([Conditions{iCondition}]).circularVariance = varianceCircular;
            resultsSync.([Conditions{iCondition}]).pRao = pRao;
            resultsSync.([Conditions{iCondition}]).pRaleigh = pRaleigh;
            resultsSync.([Conditions{iCondition}]).phaseAngle = phaseAngle;
            resultsSync.([Conditions{iCondition}]).phaseRad = phaseRad;
            resultsSync.([Conditions{iCondition}]).phaseError = phaseError;
            resultsSync.([Conditions{iCondition}]).phaseErrorMean = phaseErrorMean;
            resultsSync.([Conditions{iCondition}]).phaseRadMean = phaseRadMean;
            resultsSync.([Conditions{iCondition}]).phaseDegMean = rad2deg(phaseRadMean);
            resultsSync.([Conditions{iCondition}]).resultantLength = resultantLength;

        end % End Conditions

        % Save results
        save([pathExport 'resultsSync.mat'], 'resultsSync');

    end % End Sessions

end % End Participants
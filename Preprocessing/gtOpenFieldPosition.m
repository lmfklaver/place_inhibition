function [positionOF] = gtOpenFieldPosition(basePath, csvFileName)
% Purpose: Read open field position from excel sheet(output from bonsai or
% deeplabcut model) and also make a plot of movement trajectory
% Dependencies: Need a folder labeled 'Videos_CSVs' in data folder with an
% csv titled 'basename(first 12 characters)_' + 'fileName'

% Input: basePath of data folder

% Output: 2 vectors: one for x position and one for y position
%         Plot of trajectory

% Reagan Bullins 4/26/21

% example [positionOF] = gtOpenFieldPosition(basepath,'PositionEstimate.csv')  *for a file name = m247_210418_PositionEstimate.csv

basename = bz_BasenameFromBasepath(basePath);
cd(basePath);
cd('Videos_CSVs');
[OF_Position_Estimated] = load([basename(1:12) csvFileName]);
pixelConversion = 4.54; %(pixels/cm)
positionOF.xpos = OF_Position_Estimated(:,1)/pixelConversion;
positionOF.ypos = OF_Position_Estimated(:,2)/pixelConversion;

OF_Trajectory = plot(positionOF.xpos, positionOF.ypos, '-r')
title('Open Field Position Trajectory')
xlabel('X Position (cm)')
ylabel('Y Position (cm)')
cd(basePath);
cd('Figures');
savefig([basename '_' csvFileName(1:end-4) '_Trajectory.fig'])

end
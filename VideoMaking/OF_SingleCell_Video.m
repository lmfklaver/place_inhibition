%% script to make open field video (one cell spiking activity appears on video)
% First must run alignVidDLC 
% PURPOSE
%          Make a video of the animal on linear track or open field, add
%          red dots whenever the specifed cell fires
% INPUTS
%          basePath         String: data location
% PROCESS
%          1) Define video name fed into VideoReader
%          2) Get the pixel coordinates of the corners of the rigs
%          3) Make the video
    cd([basePath '\Videos_CSVs']);
%% MANUAL - Find pixel coordinates of corners of open field in matlab and from bonsai output
% To get pixel coordinates in Matlab:
    % Open the video (DEFINE VIDEO NAME HERE)
        videoObject = VideoReader([basename(1:12) 'VideoOpenField.avi']);
    % Extract the first frame from the movie structure.
        thisFrame = read(videoObject, 1);
        imwrite(thisFrame, 'TestFrame.jpeg');
        image = 'TestFrame.jpeg';
    % Load pixels
        I = imread('TestFrame.jpeg');  %read the image in I
        imshow(I);  
        [x_pixel,y_pixel,RGB_pixel] = impixel(I);   
        % select points and hit return key
% To get pixel coordinates of bonsai:
    % plot the position estimates outputted by bonsai and find the
    % coordinates of the corners (estimate where the actual corner is)
        x_pos = VtrackingOF.xpos;
        y_pos = VtrackingOF.xpos;
        plot(x_pos, y_pos);
        % hover over corners and record below
%% MANUAL - coordinates of rig corners
% OPEN FIELD Coordinates below (pixels are different in bonsai in matlab -
% at least for older recordings - may be same for newer recordings)
% Make Conversion
% session 21
    % MATLAB  
    %         top left:     475,472
    %         top right:    767,465
    %         bottom right: 766,748
    %         bottom left:  487,752
    % Bonsai video original
    %         top left:     84,351
    %         top right:    358,350
    %         bottom right: 353,76
    %         bottom left:  86,88
    % Bonsai video rotated clockwise once
    %         top left:     86,88
    %         top right:    84,351
    %         bottom right: 358, 350
    %         bottom left:  353, 76
    % MATLAB corners flipped Top right abot botom left
    %         top left:     475,472
    %         top right     487,752
    %         bottom right: 766,748
    %         bottom left:  767, 465
    % Define coords matlab coordinates (top left, top right, bottom left,
    % bottom right)
              ML_TL_X = 475;
              ML_TL_Y = 472;
              ML_TR_X = 487;
              ML_TR_Y = 752;
              ML_BR_X = 766;
              ML_BR_Y = 748;
              ML_BL_X = 767;
              ML_BL_Y = 465;
    % Define coords in experiment video
              EX_TL_X = 86;
              EX_TL_Y = 88;
              EX_TR_X = 84;
              EX_TR_Y = 351;
              EX_BR_X = 358;
              EX_BR_Y = 350;
              EX_BL_X = 353;
              EX_BL_Y = 76;
     % Plot to make sure coords reflect each other
               plot(ML_TL_X, ML_TL_Y, '.r');
               hold on
               plot(ML_TR_X, ML_TR_Y, '.y');
               plot(ML_BR_X, ML_BR_Y, '.g');
               plot(ML_BL_X, ML_BL_Y, '.c');
               plot(EX_TL_X, EX_TL_Y, 'or');
               plot(EX_TR_X, EX_TR_Y, 'oy');
               plot(EX_BR_X, EX_BR_Y, 'og');
               plot(EX_BL_X, EX_BL_Y, 'oc');
               legend({'TL','TR','BR','BL'})
    % subtract x coordinates and avg difference
              TL_X = ML_TL_X-EX_TL_X;
              TR_X = ML_TR_X-EX_TR_X;
              BR_X = ML_BR_X-EX_BR_X;
              BL_X = ML_BL_X-EX_BL_X;
              mean_diff_x = mean([TL_X TR_X BR_X BL_X]);
    % subtract y coordinates and avg difference
              TL_Y = ML_TL_Y-EX_TL_Y;
              TR_Y = ML_TR_Y-EX_TR_Y;
              BR_Y = ML_BR_Y-EX_BR_Y;
              BL_Y = ML_BL_Y-EX_BL_Y;
              mean_diff_y = mean([TL_Y TR_Y BR_Y BL_Y]);
    % avg means
              conversion_add2Exp = mean([mean_diff_x mean_diff_y]);
%% Video making
    cell_idx = 11; %define what cell to map
% Read position of animal
    x_pos = VtrackingOF.xpos;
    y_pos = VtrackingOF.xpos;
    positionTimes = frameTimes(:,1);
% Make a video writer object and open it    
    cd(videoPathOF);
    OF_Video = dir(fullfile(videoPathOF, '*.mp4'));
    OFVideoDLC = convertCharsToStrings(OF_Video.name);
    v = VideoReader(OFVideoDLC);
    vw = VideoWriter('VideoOpenFieldMarked.avi','MOTION JPEG AVI');
    vw.FrameRate = v.FrameRate;
    open(vw);
% Count how many frames the video has
    videoPlayer = vision.VideoPlayer;
    frameidx = 0;
    numFrames = 0;
   while hasFrame(v)
        frame = readFrame(v);
        frameidx = frameidx + 1;
        numFrames = numFrames + 1;
     end
% find spikes that occur in the open field
    spikes_of = spikes.times{cell_idx}(find(spikes.times{cell_idx}> Time.OF.start & spikes.times{cell_idx} < Time.OF.stop));
% Make bins of 1 ms to sort spikes
    t = spikes_of(1):.001:spikes_of(end); %binning in 1 ms... 
% Sort spikes in  1 ms bins
    [spikes_logical, edges_spikes] = histcounts(spikes_of,t);
% Get the number of bins
    nTimePoints = length(t); % Number of time points
% See how many time bins happen in one frame (step size)
    step = (nTimePoints/numFrames);
    bin2video = 1:step:nTimePoints;
    spikesPerFrame = zeros(length(bin2video)-1,1) %for length of frames
    % for each frame/bin, find how many spikes fell in that time bin
    for ibin = 1:length(bin2video)-1
        spikesPerFrame(ibin,1) = sum(spikes_logical(1,(round(bin2video(ibin)):round(bin2video(ibin+1)))));
    end
    % if more than one spike fell in the time bin, just make it one (making
    % a video - only to plot one dot in each location)
    spikesPerFrame(spikesPerFrame(:,1) >=1,1) = 1;
    
    % Make a matrix for x and y coordinates of mark points (will store
    % previous marked points to continually mark on future frames)
    past_marker_points(:,1) = zeros(numFrames,1);
    past_marker_points(:,2) = zeros(numFrames,1);
    numFrames = 0;
    frameidx = 0;
% for each frame, see if a spike occurs
    % if it does, then plot the new spike in addition to the old
    % if it does not, then plot the old spikes
    while hasFrame(v)
        frame = readFrame(v);
        frameidx = frameidx + 1;
        numFrames = numFrames + 1;

        % TO DO: might want to make it so if the posision is not detected
        % but there is a spike in a frame, then take last position found...
        
        % If there are spikes that occur in this frame, and the position
        % was detected then plot the spike and all previous spikes
        if spikesPerFrame(frameidx) >= 1 & (isnan(x(frameidx,1))== 0)
            %add a spike position to the marker points
            past_marker_points(frameidx,:) = [x(frameidx,1) y(frameidx,1)];
            % find where the spike locations there has been
            past_markers_idx = find(past_marker_points(:,1)>0 & past_marker_points(:,2) >0);
            % make a matrix of x and y coordinates marking spike locations
            past_marker_mat = past_marker_points(past_markers_idx,:);
            % insert markers for all spikes
            previous_markedFrame = insertMarker(frame,past_marker_mat, '*','Size', 5, 'Color','r');
            videoPlayer(previous_markedFrame);
            % write it to the video
            writeVideo(vw, previous_markedFrame);
            
        % If there are not spikes found or if spikes were found but had no
        % correpsonding position, just mark previous recorded spikes
        else 
            past_markers_idx = find(past_marker_points(:,1)>0 & past_marker_points(:,2) >0);
            past_marker_mat = past_marker_points(past_markers_idx,:);
            previous_markedFrame = insertMarker(frame,past_marker_mat, '*','Size', 5, 'Color','r');
            videoPlayer(previous_markedFrame);
            writeVideo(vw, previous_markedFrame);
        end
       
    end
    close(vw);
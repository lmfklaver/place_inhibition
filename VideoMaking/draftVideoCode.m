cell_idx = 1; %define what cell to map
    %%%%%%%%%%%%%%%%% OPEN FIELD %%%%%%%%%%%%%%%%%%%%%%%%
% Read position of animal
    positionEstimate_file = csvread([basename(1:12) 'PositionEstimate.csv']);
    x_pos = positionEstimate_file(:,1);
    x = x_pos + conversion_add2Exp;
    y_pos = positionEstimate_file(:,2);
    y = y_pos + conversion_add2Exp;
    fid = fopen([basename(1:12) 'PositionTimestamps.csv']);
    C = textscan(fid,'%s','HeaderLines',8,'Delimiter',',','EndOfLine','\r\n','ReturnOnError',false);
    fclose(fid);
    positionTimes = C{1}(5:5:end);
    positionTimes = cell2mat(positionTimes);
    positionTimes = positionTimes(:,15:27);
% Make a video writer object and open it    
    cd([basePath '\Videos_CSVs']);
    v = VideoReader([basename(1:12) 'VideoOpenField.avi']);
    vw = VideoWriter('VideoOpenFieldMarked.avi','MOTION JPEG AVI');
    vw.FrameRate = v.FrameRate;
    open(vw);
    
    % for 21 session:  frames = 35831, estimates = 35372
  
    % Frames to which marker must be inserted
    %markFrames = spikes.times{cell_idx};
    %frameidx = 0;
    videoPlayer = vision.VideoPlayer;
    
    numFrames = 0;
    frameidx = 0;
   while hasFrame(v)
        frame = readFrame(v);
        frameidx = frameidx + 1;
        numFrames = numFrames + 1;
     end
% find spikes that occur in the open field
    spikes_of = spikes.times{cell_idx}(find(spikes.times{cell_idx}> Time.OF.start & spikes.times{cell_idx} < Time.OF.stop));
% subtract the time of open field start to make the spikes 'align'
% witht the video - probably need to do this a better way...
    spikes_of = spikes_of - Time.OF.start;
% Make bins of 1 ms to sort spikes
    t = spikes_of(1):.001:spikes_of(end); %binning in 1 ms... 
% Sort spikes in  1 ms bins
    [spikes_logical, edges_spikes] = histcounts(spikes_of,t);
% Get the number of bins
    nDataPoints = length(t); % Number of time points
% See how many time bins happen in one frame (step size)
    step = (nDataPoints/numFrames);
    bin2video = 1:step:nDataPoints;
    spikesPerFrame = zeros(length(bin2video)-1,1)
    for ibin = 1:length(bin2video)-1
        spikesPerFrame(ibin,1) = sum(spikes_logical(1,(round(bin2video(ibin)):round(bin2video(ibin+1)))));
    end
    spikesPerFrame(spikesPerFrame(:,1) >=1,1) = 1;
    
    
    % Make a matrix for x and y coordinates of mark points (will store
    % previous marked points to continually mark on future frames)
    past_marker_points(:,1) = zeros(numFrames,1);
    past_marker_points(:,2) = zeros(numFrames,1);
    %numFrames = 0;
    frameidx = 0;
    % make a empty matrix to hold marker points
    for iframe = 9330:9800
        frame = read(v, iframe);
        frameidx = frameidx + 1;
       
        % TO DO: might want to make it so if the posision is not detected
        % but there is a spike in a frame, then take last position found...
        if spikesPerFrame(iframe) >= 1 & (isnan(x(iframe,1))== 0)
            markedFrame = insertMarker(frame, [x(iframe,1) y(iframe,1)], '*','Size', 5, 'Color','r');
            videoPlayer(markedFrame);
            writeVideo(vw, markedFrame);
            past_markers_idx = find(past_marker_points(:,1)>0 & past_marker_points(:,2) >0);
            past_marker_mat = past_marker_points(past_markers_idx,:);
            previous_markedFrame = insertMarker(frame,past_marker_mat, '*','Size', 5, 'Color','r');
            videoPlayer(previous_markedFrame);
            writeVideo(vw, previous_markedFrame);
%             for imark = 1:length(past_markers_idx)
%                 previous_markedFrame = insertMarker(frame, [past_marker_points(past_markers_idx(imark),1) past_marker_points(past_markers_idx(imark),2)], '*','Size', 10, 'Color','r');
%                 videoPlayer(previous_markedFrame);
%                 writeVideo(vw, previous_markedFrame);
%                 
%             end
            past_marker_points(iframe,:) = [x(iframe,1) y(iframe,1)];
        else
            videoPlayer(frame);
             writeVideo(vw, frame)
        end
       
    end
    close(vw);
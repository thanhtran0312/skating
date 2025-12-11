clear all
clc

%% set paths
rootdir = '/Users/goal0312/Desktop/thesis';
input_path = fullfile(rootdir, '1_videos', 'video_1');
video_files = dir(fullfile(input_path, '*.mp4'));



% n_frame = length(vid.NumFrames);
% n_feature = floor(vid.Width*vid.Height);
% max_pix_per_frame = zeros(vid.Width, vid.Height,'uint8');
% max_pix_per_frame = zeros(vid.Width, vid.Height,'uint8');

%% try: load 1 frame and compute pixel matrix of that frame
% first_frame = read(vid,1);


% A = [1 3 4; 5 6 7];
% B = [2 3 5; 9 8 1];
% C = cat(3, A,B);
% D = permute(C, [1 2 3]);
% E = reshape(D, size(C,3), [], 1);

% min_matrix = zeros(vid.Height, vid.Width);
% max_matrix = zeros(vid.Height, vid.Width);
% 
% for i = 1:vid.Height
%     for j = 1:vid.Width
%         min_matrix(i,j) = min(first_frame(i,j,:));
%         max_matrix(i,j) = max(first_frame(i,j,:));
%     end
% end

%% wrong version 
for j = 1:size(video_files,1)
    vid = VideoReader(fullfile(input_path, video_files(j).name));
    first_frame = read(vid,1);
    gray1  = rgb2gray(first_frame);
    min_matrix = gray1;
    max_matrix = gray1;
        
    for i = 2:vid.NumFrames
        frame = read(vid,i);
        grayi = rgb2gray(frame);
        min_matrix = min(min_matrix, grayi);
        max_matrix = max(max_matrix, grayi);
    end
end

%% maybe right: max-min => too many movements
% at least once during the entire recording, this pixel
% experienced a large intensity change. Not that this pixel
% contains motion, or the motion occurs frequently in this pixel


% initialize min-max matrices 
vid = VideoReader(fullfile(input_path, video_files(1).name));
first_frame = read(vid,1);
gray1  = rgb2gray(first_frame);

min_matrix = gray1;
max_matrix = gray1;

% loop over all videos and all frames
for j = 1:length(video_files)

    vid = VideoReader(fullfile(input_path, video_files(j).name));

    while hasFrame(vid)
        frame = readFrame(vid);
        grayi = rgb2gray(frame);

        min_matrix = min(min_matrix, grayi);
        max_matrix = max(max_matrix, grayi);
    end
end

% change map:
% high value => pixels that change a lot over time
% low value => static pixels

changes = max_matrix - min_matrix;
imagesc(changes); 
axis image;
colormap turbo;
colorbar;

%% sum difference: skip 5 frame => too little movements 

% initialize accumulator
vid = VideoReader(fullfile(input_path, video_files(1).name));
first_frame = rgb2gray(readFrame(vid));
lumdiff_allframes = zeros(size(first_frame));

% loop through all videos
for j = 1:length(video_files)
    
    vid = VideoReader(fullfile(input_path, video_files(j).name));
    
    % read first frame
    prev = im2double(rgb2gray(readFrame(vid)));

    % process remaining frames
    while hasFrame(vid)  
        frame_count = frame_count + 1;
        curr = im2double(rgb2gray(readFrame(vid)));

        if mod(frame_count,5) == 0
            lumdiff_allframes = lumdiff_allframes + abs(curr - prev);
            prev = curr;
        end
    end
end

% display heatmap
imagesc(lumdiff_allframes);
axis image;
colormap turbo;
colorbar;


%% chat: skip 20 frames, somewhere in between
skip = 20;
for j = 1:length(video_files)
    
    vid = VideoReader(fullfile(input_path, video_files(j).name));
    while hasFrame(vid)
        prev = im2double(rgb2gray(readFrame(vid)));  % frame n
    
        % skip 4 frames
        for k = 1:(skip-1)
            if hasFrame(vid)
                readFrame(vid);
            end
        end
    
        if hasFrame(vid)
            curr = im2double(rgb2gray(readFrame(vid)));  % frame n+5
            lumdiff_allframes = lumdiff_allframes + abs(curr - prev);
        end
    end
end

imagesc(lumdiff_allframes);
axis image;
colormap turbo;
colorbar;

%% conclusion: cutting according to min-max to be conservative 
%% next step: pose estimation 
% when i created the filtered stimuli, i cropped and resized 
% the frames, so the positions of the skater across frames 
% in the vids now are different from the ones i got from vitpose.

% i have to scale it to track her position for the position task

load('/Users/goal0312/Desktop/thesis/7_experiment/interpolated_2d_coords.mat','coords')

keypoints_orig = coords;
crop_row_start = 50;
crop_col_start = 70;
orig_crop_h = 725 - 50 + 1;   % 676
orig_crop_w = 1800 - 70 + 1;  % 1731
cols = 1564;
rows = 778;

% your resize target (from your filter grid)
scale_x = cols / orig_crop_w;
scale_y = rows / orig_crop_h;

% recalculate — works on whole matrix at once
keypoints_new = keypoints_orig;
keypoints_new(:,:,1) = (keypoints_orig(:,:,1) - crop_col_start + 1) * scale_x;  % x
keypoints_new(:,:,2) = (keypoints_orig(:,:,2) - crop_row_start + 1) * scale_y;  % y

%% pick one keypoint from one frame and verify visually
stimdir = '/Users/goal0312/Desktop/thesis/7_experiment/normal';
movies = dir(fullfile(stimdir,'*mp4'));

frame = rgb2gray(readFrame(VideoReader(fullfile(stimdir, movies(1).name))));

figure;
imshow(frame);
hold on;
% plot keypoint 1 of frame 1
scatter(keypoints_new(1,1,1), keypoints_new(1,1,2), 'r', 'filled');

%%
stimdir = '/Users/goal0312/Desktop/thesis/1_videos/video_1_smaller_chunks';
movies = dir(fullfile(stimdir,'*mp4'));

frame = rgb2gray(readFrame(VideoReader(fullfile(stimdir, movies(1).name))));
img_cropped = frame(50:725, 70:1800);
img_resized = imresize(img_cropped, [rows cols]);

figure;
imshow(img_resized);
hold on;
% plot keypoint 1 of frame 1
scatter(keypoints_new(1,1,1), keypoints_new(1,1,2), 'r', 'filled');


%% save
save('rescaled_coords.mat',"keypoints_new")




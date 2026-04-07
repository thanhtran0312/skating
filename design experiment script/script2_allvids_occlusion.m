load('/Users/goal0312/Desktop/thesis/4_VITPOSE_2d/interpolated_2d_coords.mat','coords');

n_vids = size(coords,1);
fps = 50;
win = 0.1;
step = round(win * fps); 
occ_num = 5;
occ_duration = 0.1; 
minIOI = 7;


% per 5 frames, how many pixels the pelvis moves
pelvis_x = squeeze((coords(:,12,1,:) + coords(:,13,1,:))/2);
pelvis_y = squeeze((coords(:,12,2,:) + coords(:,13,2,:))/2);

dx = pelvis_x(:,1+step:step:end) - pelvis_x(:,1:step:end-step);
dy = pelvis_y(:,1+step:step:end) - pelvis_y(:,1:step:end-step);
speeds = sqrt(dx.^2 + dy.^2);

% figure;histogram(speeds(:))   
org_framenum = ones(52,4200);

% padding first & last 5 séc
org_framenum(:,1:5*fps) = 0;
org_framenum(:,end-5*fps:end) = 0;

% mask too slow speed
frame_idx = 1:step:4200-step;

for ifile = 1:size(coords,1)
    slow_mask = find(speeds(ifile,:) < prctile(speeds(ifile,:),10));
    slow_frame = frame_idx(slow_mask);
    for i = 1:length(slow_frame)
        org_framenum(ifile,slow_frame(i):slow_frame(i)+5) = 0;
    end    
end    

% where there are 5 frames in around

occlusion_onset = zeros(n_vids,occ_num);
occ_duration_frames = round(occ_duration * fps);

for ivid = 1:n_vids    
    frame_where_occ_possible = find(org_framenum(ivid,:)==1);
    total_frames = numel(frame_where_occ_possible) - (occ_num+1)*minIOI*fps - (occ_num*occ_duration*fps);
    valid_onset = [];
    for i = 1:length(frame_where_occ_possible)-occ_duration_frames
        chunk = frame_where_occ_possible(i:i+occ_duration_frames);
        if chunk(end) - chunk(1) == occ_duration_frames  % all continuous
            valid_onset(end+1) = frame_where_occ_possible(i);
        end
    end
    rng(ivid*100);
    occ_onset = rand(occ_num+1,1); % 6x1 random real numbers
    occ_onset = occ_onset*fps/sum(occ_onset*fps)*total_frames; % 5 x 1
    occ_onset = round(cumsum((occ_onset+minIOI*fps))); % 5 x 1
    occ_onset(end) = [];
    valid_onset(occ_onset)
    occlusion_onset(ivid,:) = occ_onset;
end 

save('occlusion_matrix.mat', 'occlusion_onset')
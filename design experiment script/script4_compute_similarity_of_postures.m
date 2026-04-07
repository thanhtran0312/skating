load('/Users/goal0312/Desktop/thesis/7_experiment/normalized_coords.mat','normalized_coords');
load('/Users/goal0312/Desktop/thesis/4_VITPOSE_2d/interpolated_2d_coords.mat','coords');

load('/Users/goal0312/Desktop/thesis/7_experiment/occlusion_matrix.mat','occlusion_onset');


%% test
% compute similarity with cosine
coord_1 = squeeze(coords(1,:,:,23));
coord_2 = squeeze(coords(1,:,:,40));
pose_a = coord_1(:);
pose_b = coord_2(:);

cossim = dot(pose_a,pose_b)/(norm(pose_a)*norm(pose_b));

% visualize similarity
path = '/Users/goal0312/Desktop/thesis/1_videos/video_1_smaller_chunks';
vid1 = VideoReader(fullfile(path, "chunk7.mp4"));
frame1 = read(vid1,1347);

vid2 = VideoReader(fullfile(path, "chunk52.mp4"));
frame2 = read(vid2,3505);

figure; imshow(frame1)
figure; imshow(frame2)


% all vids
% 1 vid choose, we have 5 occlusions
% for each occlusions get one incoherent frame but same position
% 52 x 5
% i did manually raise threshold for some frame
threshold_dist = 10;
threshold_posture = 0.3;
incongruent_frame = zeros(size(coords,1), size(occlusion_onset,2));
incongruent_vid = zeros(size(coords,1), size(occlusion_onset,2));
incongruent_dist = zeros(size(coords,1), size(occlusion_onset,2));
incongruent_cossim = zeros(size(coords,1), size(occlusion_onset,2)); 

for ivid = 1:size(coords,1)  % for 52 vids
    for iframe = 1:size(occlusion_onset,2)  % 5 occlusion moments per vid
        % normalized coords of occlusion frame
        anchored_coords = squeeze(normalized_coords(ivid,:,:,occlusion_onset(ivid,iframe))); 
        anchored_coords = anchored_coords(:); % flatten
        % pelvis position of occlusion frame
        anchored_position = squeeze((coords(ivid,12,:,occlusion_onset(ivid,iframe)) + coords(ivid,13,:,occlusion_onset(ivid,iframe)))/2); 

        found = false;
        for icompared_vid = 1:size(coords,1) % compare across 52 vids
            if found, break; end
            for icompared_frame = 1:size(coords,4) % all frames of each vid
                compared_position = squeeze(coords(icompared_vid,12,:,icompared_frame) + coords(icompared_vid,13,:,icompared_frame))/2;
                compared_coords = squeeze(normalized_coords(icompared_vid,:,:,icompared_frame));
                compared_coords = compared_coords(:);
                
                dist = norm(anchored_position - compared_position);
                cossim = dot(anchored_coords,compared_coords)/(norm(anchored_coords)*norm(compared_coords));

                if cossim < threshold_posture && dist < threshold_dist
                    incongruent_frame(ivid,iframe) = icompared_frame;
                    incongruent_vid(ivid,iframe) = icompared_vid;
                    incongruent_dist(ivid,iframe) = dist;
                    incongruent_cossim(ivid,iframe) = cossim;

                    found = true;
                    break
                end        
            end
        end
    end 
end
for ivid = 1:size(coords,1)
    for iframe = 1:size(occlusion_onset,2)
        incongruent(ivid,iframe).frame   = incongruent_frame;
        incongruent(ivid,iframe).vid     = incongruent_vid;
        incongruent(ivid,iframe).dist    = incongruent_dist;
        incongruent(ivid,iframe).cossim  = incongruent_cossim;
    end
end

save('incongruent_stimuli.mat', 'incongruent', 'occlusion_onset')

%% save the frames to show during experiment
% path
input_path = '/Users/goal0312/Desktop/thesis/7_experiment/normal';
output_path = '/Users/goal0312/Desktop/thesis/7_experiment/posture_incoherent';
movies = dir(fullfile(input_path,'*mp4'));
names = {movies.name};
[names,idx] = natsortfiles(names);
movies = movies(idx);
% write down the file
for icol = 1:52
    for irow = 1:5
        vid = incongruent_vid(icol,irow);
        frame = incongruent_frame(icol,irow);
        video = VideoReader(fullfile(input_path,movies(vid).name));
        readframe = read(video,frame);
        name = sprintf('occ_vid_%d_time_%d_.png',icol,irow);
        imwrite(readframe, fullfile(output_path,name));
    end
end    
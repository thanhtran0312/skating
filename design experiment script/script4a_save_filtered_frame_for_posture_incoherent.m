%% filter frames

%% path
load("occlusion_matrix.mat","occlusion_onset");
rootdir = '/Users/goal0312/Desktop/thesis';
% stimdir = fullfile(rootdir, '7_experiment','posture_incoherent_normal');
% % rootdir = '/Users/goal0312/Desktop/thesis';
% % rootdir =    "\\cimec-storage6.cimec.unitn.it\ingdev\projects\THANH";
% % stimdir = fullfile(rootdir, 'IceSkating','experiment','stimuli','video_1_smaller_chunks');
% % outputdir3= fullfile(rootdir, 'IceSkating','experiment','stimuli','normal');
outputdir1 = '/Users/goal0312/Desktop/thesis/7_experiment/posture_incoherent_low';
outputdir2 = '/Users/goal0312/Desktop/thesis/7_experiment/posture_incoherent_high';

input_1 = '/Users/goal0312/Desktop/thesis/7_experiment/low_frequency';
input_2 = '/Users/goal0312/Desktop/thesis/7_experiment/high_frequency';
low_vids = dir(fullfile(input_1,'*mp4'));
names1 = {low_vids.name};
[names1,idx1] = natsortfiles(names1);
low_vids = low_vids(idx1);

high_vids = dir(fullfile(input_2,'*mp4'));
names2 = {high_vids.name};
[names2,idx2] = natsortfiles(names2);
high_vids = high_vids(idx2);

for ivid = 1:52
    for iocc = 1:5
        frameth = occlusion_onset(ivid,iocc);
        
        vid1 = VideoReader(fullfile(input_1,low_vids(1).name));
        readframe1 = read(vid1,frameth);
        outputname1 = sprintf("low_occ_vid_%d_time_%d.png",ivid,iocc);
        imwrite(readframe1,fullfile(outputdir1,outputname1));

        vid2 = VideoReader(fullfile(input_2,high_vids(1).name));
        readframe2 = read(vid2,frameth);
        outputname2 = sprintf("high_occ_vid_%d_time_%d.png",ivid,iocc);
        imwrite(readframe2,fullfile(outputdir2,outputname2));
    end
end

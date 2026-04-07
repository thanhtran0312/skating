%% path
rootdir = '/Users/goal0312/Desktop/thesis';
stimdir = fullfile(rootdir, '1_videos','video_1_smaller_chunks');
% rootdir = '/Users/goal0312/Desktop/thesis';
% rootdir =    "\\cimec-storage6.cimec.unitn.it\ingdev\projects\THANH";
% stimdir = fullfile(rootdir, 'IceSkating','experiment','stimuli','video_1_smaller_chunks');
% outputdir3= fullfile(rootdir, 'IceSkating','experiment','stimuli','normal');
outputdir1 = '/Users/goal0312/Desktop/thesis/7_experiment/low_frequency';
outputdir2 = '/Users/goal0312/Desktop/thesis/7_experiment/high_frequency';
outputdir3= '/Users/goal0312/Desktop/thesis/7_experiment/normal';

movies = dir(fullfile(stimdir,'*mp4'));
names = {movies.name};
[names,idx] = natsortfiles(names);
movies = movies(idx);

%% PPD and cutoffs
ppd = 1024 / 10;            % 102.4 px/degree
lsf_cutoff = 1 * ppd;       % 102.4
hsf_cutoff = 5 * ppd;       % 512

%% build filter grid using test frame
test_vid = VideoReader(fullfile(stimdir, movies(1).name));
test_frame = rgb2gray(readFrame(test_vid));
test_cropped = test_frame(50:725, 70:1800);
test_resized = imresize(test_cropped, [round(8.7*89.37) round(17.5*89.37)]);
[rows, cols] = size(test_resized);

cx = ceil(cols/2);
cy = ceil(rows/2);
[X, Y] = meshgrid(1:cols, 1:rows);
dist_grid = sqrt((X-cx).^2 + (Y-cy).^2);

H_low  = exp(-(dist_grid.^2) / (2*lsf_cutoff^2));
H_high = 1 - exp(-(dist_grid.^2) / (2*hsf_cutoff^2));

fprintf('Filter size: %d x %d\n', rows, cols)
fprintf('PPD: %.1f | LSF: %.1f | HSF: %.1f\n', ppd, lsf_cutoff, hsf_cutoff)

%% filter all movies
for i = 1:length(movies)
    movie = VideoReader(fullfile(stimdir, movies(i).name));
    outputname_lsf = sprintf('low_frequency_filtered_%d.mp4', i);
    outputname_hsf = sprintf('high_frequency_filtered_%d.mp4', i);

    writer_lsf = VideoWriter(fullfile(outputdir1, outputname_lsf), 'MPEG-4');
    writer_hsf = VideoWriter(fullfile(outputdir2, outputname_hsf), 'MPEG-4');
    writer_lsf.FrameRate = movie.FrameRate;
    writer_hsf.FrameRate = movie.FrameRate;
    writer_lsf.Quality = 95;
    writer_hsf.Quality = 95;
    open(writer_lsf)
    open(writer_hsf)

    frame_count = 0;
    img_hsf_prev = [];
    img_lsf_prev = [];      % add this
    alpha = 0.7;

    outputname = sprintf('chunk%d.mp4', i);
    writer = VideoWriter(fullfile(outputdir3, outputname), 'MPEG-4');
    writer.FrameRate = movie.FrameRate;
    writer.Quality = 95;
    open(writer)
    frame_count = 0;
    img_prev = [];      % add this

    while hasFrame(movie)
        frame = rgb2gray(readFrame(movie));
        frame_count = frame_count + 1;

        % crop and resize
        img_cropped = frame(50:725, 70:1800);
        img_resized = imresize(img_cropped, [rows cols]);

        % % FFT and filter
        F = fftshift(fft2(double(img_resized)));
        img_lsf = real(ifft2(ifftshift(F .* H_low)));
        img_hsf = real(ifft2(ifftshift(F .* H_high)));

        initialize on first frame
        if frame_count == 1
            img_lsf_prev = img_lsf;
            img_hsf_prev = img_hsf;
        end

        % temporal smoothing for both
        img_lsf_smooth = alpha * img_lsf + (1-alpha) * img_lsf_prev;
        img_hsf_smooth = alpha * img_hsf + (1-alpha) * img_hsf_prev;

        % update previous frames
        img_lsf_prev = img_lsf;
        img_hsf_prev = img_hsf;

        convert to uint8
        img_lsf_uint8 = uint8(mat2gray(img_lsf_smooth) * 255);
        img_hsf_uint8 = uint8(mat2gray(img_hsf_smooth) * 255);

        % write
        writeVideo(writer_lsf, repmat(img_lsf_uint8, [1 1 3]));
        writeVideo(writer_hsf, repmat(img_hsf_uint8, [1 1 3]));
        writeVideo(writer, repmat(img_resized, [1 1 3]));

    end    
    close(writer_lsf);
    close(writer_hsf);
    close(writer);
end

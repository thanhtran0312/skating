% for one participant
% one run: 
% 1. VidA-T1-N 
% 2. VidB-T1-B
% 3. VidC-T1-H
% 4. VidD-T2-N
% 5. VidE-T2-B
% 6. VidF-T2-H


n_subs = 30;
n_runs = 7;
n_blocks = 6;

%% n x 6 runs x 6 conds x 2

% 1 run
n_conds = 1:6;
condall = perms(n_conds);                        
condall = condall(randperm(size(condall,1)), :);
condall = condall(1:n_subs,:); % each participant 

% vid
vid = repmat([1 2 3 4 5 6], size(condall,1),1);

% 30 subs now have 1 run - each block in a run get a vid
condmat1 = cat(3,vid,condall);

% shuffle across participants
perm = randperm(size(condall,1));
perm = condall(perm,:);            % 48x4 - index condall with those 48 random integers

for isub = 1:n_subs
    condmat1(isub,:,:) = condmat1(isub,perm(isub,:),:);
end

% now we have condmat 30 subs x 6 blocks in one run x 2 (video & cond)
% we want 30 subs x 6 blocks x 6 runs x 2

%% 
% 6 runs
condmat = zeros(n_subs,n_blocks,n_runs,2);
% condmat_temp = zeros(n_subs,n_blocks,2);
% perm = randperm(size(condall,1));
% perm = condmat1(:,perm,:);
condmat1 = zeros(n_subs,n_blocks,n_runs/2,2);
condmat2 = zeros(n_subs,n_blocks,n_runs/2,2);


for irun = 1:n_runs
    for isub = 1:n_subs
        shuffle_idx = randperm(n_blocks);                        % random order of 1:6
        condmat(isub, :, irun, 1) =  vid(isub, shuffle_idx);     % vid moves with this index
        condmat(isub, :, irun, 2) = condall(isub, shuffle_idx); % cond moves with same index
    end
end

for irun = 1:n_runs
    for isub = 1:n_subs
        shuffle_idx = randperm(n_blocks);                        % random order of 1:6
        if irun < 4
            condmat1(isub, :, irun, 1) =  vid(isub, shuffle_idx);     % vid moves with this index
            condmat1(isub, :, irun, 2) = condall(isub, shuffle_idx); % cond moves with same index
        elseif irun >= 4
            condmat2(isub, :, irun, 1) =  vid(isub, shuffle_idx);     % vid moves with this index
            condmat2(isub, :, irun, 2) = condall(isub, shuffle_idx); % cond moves with same index
        end
    end
end

size(condmat)
a = squeeze(condmat(30,:,6,1)) % 1 run - all blocks - vid
b = squeeze(condmat(30,:,6,2)) % 1 run - all blocks - condition

c = condmat(30,:,:,1) % 1 run - all blocks - vid
d = condmat(30,:,:,2) % 1 run - all blocks - condition

shuffle_idx(end:-1:1)

%% 

n_subs = 30;
n_runs = 6;
n_blocks = 6;

% condition key:
% 1=T1N, 2=T1B, 3=T1H
% 4=T2N, 5=T2B, 6=T2H

% runs 1-3: vid1=T1B, vid2=T1H, vid3=T1N, vid4=T2B, vid5=T2H, vid6=T2N
conds_first = [1,2,3,4,5,6];

% runs 4-6: task flips, filter stays with video
%           vid1=T2B, vid2=T2H, vid3=T2N, vid4=T1B, vid5=T1H, vid6=T1N
conds_last  = [4,5,6,1,2,3];


condmat = zeros(n_subs, n_blocks, n_runs, 2);
for isub = 1:n_subs
    vid = randperm(52);
    for irun = 1:n_runs
        shuffle_idx = randperm(n_blocks);  % shuffle blocks, vid & cond move together
        if irun <= 3
            conds = conds_first;
        else
            conds = conds_last;
        end
        condmat(isub, :, irun, 1) = vid(shuffle_idx);
        condmat(isub, :, irun, 2) = conds(shuffle_idx);

    end
end

save('condmat', 'condmat');

condmat(1,:,:,:)



% how many times each clip was seen
count_vid = zeros(52,1);
for isub = 1:30
    for iblock = 1:6
        count_vid(condmat(isub,iblock,1,1),1) =  count_vid(condmat(isub,iblock,1,1),1) + 1;
    end
end
count_vid(condmat(isub,:,1,1),1)
count_vid(condmat(:,:,1,1),1) =  count_vid(condmat(:,:,1,1),1) + 1;

%% check for correctness of extracted annotations (for example for lumen)
clc;clear;
what = 'img_box_lumenORwall';
samples = {'2517_RMS.czi'};
set = '10x';
for i = 1:length(samples)
    tr_num = samples{i};
    dd = dir(['/home/azamhamidinekoo/Documents/dataset/RMS-dataset/Annotations/vasculature/',set,'/',tr_num,'/',what,'/*.png']);
    for ii = 1:length(dd)
        imgname = strrep(dd(ii).name,'.png','T.png');
%         label = imread(fullfile(dd(ii).folder,dd(ii).name));
        label = imread(strrep(fullfile(dd(ii).folder,dd(ii).name),what,'lumen'));
        img = imread(fullfile(strrep(dd(ii).folder,what,'box'),imgname));
        if ~exist(strrep(dd(ii).folder,what,'check_for_correct_annotation_extraction'),'dir')
            mkdir(strrep(dd(ii).folder,what,'check_for_correct_annotation_extraction'))
        end
        savefigpath = fullfile(strrep(dd(ii).folder,what,'check_for_correct_annotation_extraction'),imgname);
        traceBoundary(img,label,savefigpath)
    end
end

%%
function traceBoundary(I,mask,address)
fig = figure;
BW1 = mask;
[B1,~] = bwboundaries(BW1,'noholes');
imshow(I)
hold on
for k = 1:length(B1)
    boundary = B1{k};
    plot(boundary(:,2), boundary(:,1), 'b', 'LineWidth', 1)
end
saveas(fig,address)
end


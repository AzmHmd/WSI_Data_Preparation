clear;clc
%
root = '/home/azamhamidinekoo/Documents/projects/HE_vasculature_pix2pixHD_Azam/';
rootprojects = dir([root,'checkpoints/fold*']);
for rp = 1:length(rootprojects)
    project = rootprojects(rp).name;
    mkdir(fullfile(rootprojects(rp).folder,rootprojects(rp).name,'learning_curve'));
    savepath = fullfile(rootprojects(rp).folder,rootprojects(rp).name,'learning_curve');
    %% show the results on images
    d = dir([root,'/results/',project,'/test_latest/images/*_synthesized_image.jpg']);
    savefigpath = [root,'/results/',project,'/test_latest/savedfigures'];
    if ~exist([root,'/results/',project,'/test_latest/savedfigures'],'dir')
        mkdir(savefigpath);
    end
    for i = 1:length(d)
        img = imread(strrep(fullfile(d(i).folder,d(i).name),'synthesized_image','input_label'));
        %img_resized = imresize(img,[1000 1000]);
        %     label = imread(['/home/azamhamidinekoo/Documents/projects/HE_vasculature_pix2pixHD/dataset/',dataset,'/test_B/',strrep(d(i).name,'_synthesized_image.jpg','.png')]);
        label = imread(strrep(fullfile(d(i).folder,d(i).name),'synthesized_image','real_image'));
        predictedMask=imread(fullfile(d(i).folder,d(i).name));
        %     fig = figure();
        %     subplot(131);imshow(img)
        %     subplot(132);imshow(label*100)
        %     subplot(133);imshow(predictedMask*100)
        
        imwrite([img,255*ones(size(img,1),1,3),100*repmat(label,[size(img,1) size(img,2)],1,1,3),255*ones(size(img,1),1,3),100*predictedMask],[savefigpath,'/',strrep(d(i).name,'_synthesized_image.jpg','Alltogether.png')])
        traceBoundary(img,rgb2gray(predictedMask),rgb2gray(label),[savefigpath,'/',strrep(d(i).name,'_synthesized_image.jpg','_compare.png')])
    end
end
%%
function traceBoundary(I,pred,annot,address)
fig = figure;
BW_pred = imbinarize(pred);
BW_annot = imbinarize(annot);
[Bpred,~] = bwboundaries(BW_pred,'noholes');
[Bannot,~] = bwboundaries(BW_annot,'noholes');
imshow(I)
hold on
for k = 1:length(Bpred)
    boundary = Bpred{k};
    plot(boundary(:,2), boundary(:,1), 'b', 'LineWidth', 1)
end
clear boundary
for k = 1:length(Bannot)
    boundary = Bannot{k};
    plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 1)
end
saveas(fig,address)
close all;
end
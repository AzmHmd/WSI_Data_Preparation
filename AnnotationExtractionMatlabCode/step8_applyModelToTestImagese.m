clear;clc
% 
project = '080520__fold1_10x_10x';
dataset = 'fold1_10x_10x';
%% show the results on images
d = dir(['/home/azamhamidinekoo/Documents/projects/HE_vasculature_pix2pixHD/results/',project,'/test_latest/images/*_synthesized_image.jpg']);
savefigpath = ['/home/azamhamidinekoo/Documents/projects/HE_vasculature_pix2pixHD/results/',project,'/test_latest/savedfigures'];
if ~exist(['/home/azamhamidinekoo/Documents/projects/HE_vasculature_pix2pixHD/results/',project,'/test_latest/savedfigures'],'dir')
    mkdir(savefigpath);
end
for i = 1:length(d)
    [img,map] = imread(strrep(fullfile(d(i).folder,d(i).name),'synthesized_image','input_label'));
    img_resized = imresize(img,[1000 1000]);
    label = imread(['/home/azamhamidinekoo/Documents/projects/HE_vasculature_pix2pixHD/dataset/',dataset,'/test_B/',strrep(d(i).name,'_synthesized_image.jpg','.png')]);
    predictedMask=imread(fullfile(d(i).folder,d(i).name));
    %     fig = figure();
    %     subplot(131);imshow(img)
    %     subplot(132);imshow(label*100)
    %     subplot(133);imshow(predictedMask*100)
    
    %imwrite([img,255*ones(size(img,1),5,3),100*repmat(imresize(label,[size(img,1) size(img,2)]),1,1,3),255*ones(size(img,1),5,3),100*predictedMask],[savefigpath,'/',strrep(d(i).name,'_synthesized_image.jpg','.png')])
    traceBoundary(img_resized,rgb2gray(predictedMask),label,[savefigpath,'/',strrep(d(i).name,'_synthesized_image.jpg','_compare.png')])
end


%%
% project = '080520__fold1_10x_10x';
% dataset = 'fold1_10x_10x';
% d = dir(['/home/azamhamidinekoo/Documents/projects/HE_vasculature_pix2pixHD/dataset/',dataset,'/train_A/*.png']);
% savefigpath = ['/home/azamhamidinekoo/Documents/projects/HE_vasculature_pix2pixHD/dataset/',dataset,'/boundaries'];
% for i = 1:length(d)
%     [img,map] = imread(fullfile(d(i).folder,d(i).name));
% %     img_resized = imresize(img,[1000 1000]);
%     label = imread([strrep(fullfile(d(i).folder,d(i).name),'train_A','train_B')]);
% 
%     traceBoundary(img,label,label,[savefigpath,'/',d(i).name])
% end

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
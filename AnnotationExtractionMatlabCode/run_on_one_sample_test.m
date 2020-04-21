
root = '/home/azamhamidinekoo/Documents/dataset/';
training_numbers = {'2250_RMS.czi','2390_RMS.czi','2400_RMS.czi','2403_RMS.czi'...
    '2504_RMS.czi','2514_RMS.czi','2519_RMS.czi','2542_RMS.czi','3503_RMS.czi','3509_RMS.czi'};

for i = 1:length(training_numbers)
    tr_num = training_numbers{i};

ImagePath  =[root,'RMS-dataset/raw/',strrep(tr_num,'_',' ')];
AnnoPath = [root , '/PolyscopeSDK/downloadedAnnotations/',tr_num,'.txt'];
PatchPath = ['/home/azamhamidinekoo/Documents/dataset/RMS-dataset/Annotations/Patches_annotated/2514';

% LabelMap = containers.Map({'#ffffff', '#00ff00'}, {'WhiteLabels', 'GreenLabels'});
LabelMap = containers.Map('#00ff00','GreenLabels');


% ExtractTilesPolyscope(ImagePath, AnnoPath, PatchPath, LabelMap);
ExtractTilesPolyscope_version2(ImagePath, AnnoPath, PatchPath, LabelMap)


%%
% p = '/home/azamhamidinekoo/Documents/dataset/RMS-dataset/Annotations/Patches_annotated/2514/GreenLabels/';
% files = dir([p,'*.png']);
% for i = 1:size(files)
%     img = imread([files(i).folder,'/',files(i).name]);
%     if sum(img(:)) ~= 0 
%         %imshow(img)
%         disp([files(i).folder,'/',files(i).name])
%         pause(1)
%         close all
%     end
%     clear img
% end

%%
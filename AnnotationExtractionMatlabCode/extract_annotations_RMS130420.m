clc;clear;
root = '/home/azamhamidinekoo/Documents/dataset/';
training_numbers = {'2250_RMS.czi','2390_RMS.czi','2400_RMS.czi','2403_RMS.czi'...
     '2504_RMS.czi','2514_RMS.czi','2519_RMS.czi','2542_RMS.czi','3503_RMS.czi','3509_RMS.czi'};
% training_numbers = {'2250_RMS.czi'};
% sets = {'10x','20x','40x'};
sets = {'10x'};

for s = 1:length(sets)
    set = sets{s};
    if strcmp(set,'40x')
        % use this setting for 40x magnification
        resolution = 1;
        tileSize = [2000 2000];
    elseif strcmp(set,'20x')
        % use this setting for 20x magnification
        resolution = 2;
        tileSize = [1000 1000];
    elseif strcmp(set,'10x')
        % use this setting for 10x magnification
        resolution = 3;
        tileSize = [500 500];
    end
    
    for i = 1:length(training_numbers)
        tr_num = training_numbers{i};
        
        ImagePath  =[root,'RMS-dataset/raw/',strrep(tr_num,'_',' ')];
        AnnoPath = [root , '/PolyscopeSDK/downloadedAnnotations/',tr_num,'.txt'];
        PatchPath = [root,'RMS-dataset/Annotations/vasculature/',set,'/',tr_num,'/'];
        %     PatchPath = [root,'RMS-dataset/Annotations/vasculature/1_2000/',tr_num,'/'];
        
%         LabelMap = containers.Map('#ffff00','YellowLabels');
        LabelMap = containers.Map({'#00ff00','#00ffff','#ffff00'},{'GreenLabels','BlueLabels','YellowLabels'});
        
        
        % ExtractTilesPolyscope(ImagePath, AnnoPath, PatchPath, LabelMap);
        %     ExtractTilesPolyscope_version2(ImagePath, AnnoPath, PatchPath, LabelMap)
        ExtractTilesPolyscope_version3(ImagePath, AnnoPath, PatchPath, LabelMap,tileSize, resolution)
    end
end

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


clc;clear;
% poolobj = gcp('nocreate');
% delete(poolobj);

root = '/home/azamhamidinekoo/Documents/dataset/';


%  training_numbers = {'2514_RMS.czi','2250_RMS.czi','2542_RMS.czi','3503_RMS.czi'};
training_numbers = {'2517_RMS.czi'};
% training_numbers = {'2400_RMS.czi','2403_RMS.czi','2247_RMS.czi','3509_RMS.czi','2519_RMS.czi','2504_RMS.czi'};
 
%     '2400_RMS.czi','3509_RMS.czi','2519_RMS.czi','2403_RMS.czi',...
%     '2542_RMS.czi','2247_RMS.czi'};
% training_numbers = {'2216_RMS.czi','2504_RMS.czi','2390_RMS.czi','3503_RMS.czi'};
% ----------------------------------------------------------------------------------
% testing_numbers = {'2841_RMS.czi','2832_RMS.czi','2523_RMS.czi','2831_RMS.czi',...
% '2517_RMS.czi','2401_RMS.czi','3498_RMS.czi',};

samples = training_numbers;
set ='10x';
%parpool()

resolution = 2;
tileSize = [1000 1000];

for i = 1:length(samples)
    tr_num = samples{i}
    
    ImagePath  =[root,'RMS-dataset/raw/',strrep(tr_num,'_',' ')];
    AnnoPath = [root , 'PolyscopeSDK/downloadedAnnotations/',tr_num,'.txt'];
    PatchPath = [root,'RMS-dataset/Annotations/vasculature/',set,'/',tr_num,'/'];
    
    %         LabelMap = containers.Map('#ffff00','YellowLabels');
    LabelMap = containers.Map({'#00ff00','#00ffff','#0000ff','#000080'},{'lumen','wall','box1','box2'});
%     LabelMap = containers.Map({'#00ff00'},{'lumen'});
    
    ExtractTilesPolyscope_all_resolutions(ImagePath, AnnoPath, PatchPath, LabelMap,tileSize, resolution)
%     ExtractTilesPolyscope_20x(ImagePath, AnnoPath, PatchPath, LabelMap,tileSize, resolution)
end

%% check for correctness of extracted annotations (for example for lumen)
what = 'lumen';
for i = 1:length(samples)
    tr_num = samples{i}
    dd = dir([root,'RMS-dataset/Annotations/vasculature/',set,'/',tr_num,'/',what,'/*T.png']);
    for ii = 1:length(dd)
        maskname = strrep(dd(ii).name,'T.png','.png');
        if exist(fullfile(dd(ii).folder,maskname),'file')
            img = imread(fullfile(dd(ii).folder,dd(ii).name));
            label = imread(fullfile(dd(ii).folder,maskname));
            if ~exist(strrep(dd(ii).folder,what,'check_for_correct_annotation_extraction2'),'dir')
                mkdir(strrep(dd(ii).folder,what,'check_for_correct_annotation_extraction2'))
            end
            savefigpath = fullfile(strrep(dd(ii).folder,what,'check_for_correct_annotation_extraction2'),maskname);
            traceBoundary(img,label,savefigpath)
        end
    end
end

%%
function traceBoundary(I,mask,address)
fig = figure;
BW1 = mask;
% BW2 = mask(mask==2);
[B1,~] = bwboundaries(BW1,'noholes');
% [B2,~] = bwboundaries(BW2,'noholes');
imshow(I)
hold on
for k = 1:length(B1)
    boundary = B1{k};
    plot(boundary(:,2), boundary(:,1), 'b', 'LineWidth', 1)
end
% clear boundary
% for k = 1:length(B2)
%     boundary = B2{k};
%     plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
% end
saveas(fig,address)
end
%%
       


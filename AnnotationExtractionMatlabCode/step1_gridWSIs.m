clc;clear;
root = '/home/azamhamidinekoo/Documents/dataset/';
savingPath = '/home/azamhamidinekoo/Documents/dataset/AnnotationExtractionMatlabCode/gridedImages/';

training_numbers = {'2831_RMS.czi', '2841_RMS.czi'};

for i = 1:length(training_numbers)
    tr_num = training_numbers{i};
    ImagePath  =[root,'RMS-dataset/raw/',strrep(tr_num,'_',' ')];
    step = 125;
    wsi = imread_wsi(ImagePath, 'ReductionLevel', 1);
    ImageSize = reshape(wsi_size(ImagePath), 1, [])*2.^(-1);
    wsi(1:step:size(wsi,1),:,:) = 0;
    wsi(:,1:step:size(wsi,2),:) = 0;
    %     figure;imshow(wsi);
    imwrite(wsi,[savingPath,strrep(tr_num,'.czi','.png')]);
end
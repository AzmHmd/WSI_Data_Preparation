clc;clear;
root = '/home/azamhamidinekoo/Documents/dataset/';
savingPath = '/home/azamhamidinekoo/Documents/dataset/AnnotationExtractionMatlabCode/gridedImages/';

% training_numbers = {'2250_RMS.czi','2390_RMS.czi','2400_RMS.czi','2403_RMS.czi'...
%     '2504_RMS.czi','2514_RMS.czi','2519_RMS.czi','2542_RMS.czi','3503_RMS.czi','3509_RMS.czi'};
% training_numbers = {'2517_RMS.czi','2216_RMS.czi','2401_RMS.czi','3498_RMS.czi','2841_RMS.czi','2832_RMS.czi','2523_RMS.czi','2831_RMS.czi'}
training_numbers = {'2247_RMS.czi'};

for i = 1:length(training_numbers)
    tr_num = training_numbers{i};
    ImagePath  =[root,'RMS-dataset/raw/',strrep(tr_num,'_',' ')];
    step = 125;
    wsi = imread_wsi(ImagePath, 'ReductionLevel', 5);
    wsi(1:step:size(wsi,1),:,:) = 0;
    wsi(:,1:step:size(wsi,2),:) = 0;
    %     figure;imshow(wsi);
    imwrite(wsi,[savingPath,strrep(tr_num,'.czi','.png')]);
end
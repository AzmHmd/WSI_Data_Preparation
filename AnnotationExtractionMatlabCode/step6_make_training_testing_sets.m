clear; close all; clc;
poolobj = gcp('nocreate');
delete(poolobj);
% parpool()

res = {'1x','10x','20x'};
for rr = 1:length(res)
    resolution = res{rr};
    savetest = 1;
    folds = {'fold1','fold2','fold3'};
    for ff = 1:length(folds)
        fold = folds{ff};
        categories = {'img_box_lumenORwall','img_box_lumenANDwall'};
        
        for cc = 1:length(categories)
            category = categories{cc};
            info = [fold,'_',resolution,'_',category];
            
            rootpath = ['/home/azamhamidinekoo/Documents/dataset/RMS-dataset/Annotations/vasculature/',resolution,'/'];
            savepath = ['/home/azamhamidinekoo/Documents/projects/HE_vasculature_pix2pixHD_Azam/datasets/',info,'/'];
            mkdir(fullfile(savepath,'train_A'))
            mkdir(fullfile(savepath,'train_B'))
            mkdir(fullfile(savepath,'test_A'))
            mkdir(fullfile(savepath,'test_B'))
            %%
            switch fold
                case 'fold1'
                    training_numbers = {'2514_RMS.czi','2250_RMS.czi','3503_RMS.czi', '2400_RMS.czi','3509_RMS.czi',...
                        '2519_RMS.czi','2403_RMS.czi', '2542_RMS.czi','2247_RMS.czi','2216_RMS.czi'};
                    testing_numbers = {'2832_RMS.czi','2517_RMS.czi','2401_RMS.czi','3498_RMS.czi','2504_RMS.czi'};
                    
                case 'fold2'
                    training_numbers = {'2514_RMS.czi','2250_RMS.czi','3503_RMS.czi', '2400_RMS.czi','3509_RMS.czi',...
                        '2832_RMS.czi','2517_RMS.czi','2401_RMS.czi','3498_RMS.czi','2504_RMS.czi'};
                    testing_numbers = {'2519_RMS.czi','2403_RMS.czi', '2542_RMS.czi','2247_RMS.czi','2216_RMS.czi'};
                    
                case 'fold3'
                    training_numbers = {'2519_RMS.czi','2403_RMS.czi', '2542_RMS.czi','2247_RMS.czi','2216_RMS.czi',...
                        '2832_RMS.czi','2517_RMS.czi','2401_RMS.czi','3498_RMS.czi','2504_RMS.czi'};
                    testing_numbers = {'2514_RMS.czi','2250_RMS.czi','3503_RMS.czi', '2400_RMS.czi','3509_RMS.czi'};
            end
            %%
            % save training samples
            samples = training_numbers;
            for i0 = 1:length(samples)
                tr_num = samples{i0};
                %     rms_dir = dir([rootpath,'*.czi']);
                % for i = 1:length(rms_dir)
                img_files = dir(fullfile(rootpath, tr_num,'/box/*T.png'));
                parfor j = 1:length(img_files)
                    if exist(strrep(strrep(fullfile(img_files(j).folder,img_files(j).name),'box',category),'T.png','.png'),'file')
                        img = imread(fullfile(img_files(j).folder,img_files(j).name));
                        label = imread(strrep(strrep(fullfile(img_files(j).folder,img_files(j).name),'box',category),'T.png','.png'));
                        if nnz(label)>0
                            imwrite(img, fullfile(savepath,'train_A',[tr_num,'_',info,'_',img_files(j).name]));
                            imwrite(label,fullfile(savepath,'train_B',[tr_num,'_',info,'_',img_files(j).name]));
                        end
                    end
                end
            end
            if savetest == 1
                % save testing samples
                clear samples
                samples = testing_numbers;
                parfor i0 = 1:length(samples)
                    tr_num = samples{i0};
                    img_files = dir(fullfile(rootpath, tr_num,'/box/*T.png'));
                    for j = 1:length(img_files)
                        if exist(strrep(strrep(fullfile(img_files(j).folder,img_files(j).name),'box',category),'T.png','.png'),'file')
                            img = imread(fullfile(img_files(j).folder,img_files(j).name));
                            label = imread(strrep(strrep(fullfile(img_files(j).folder,img_files(j).name),'box',category),'T.png','.png'));
                            if nnz(label)>0
                                imwrite(img, fullfile(savepath,'test_A',[tr_num,'_',info,'_',img_files(j).name]));
                                imwrite(label,fullfile(savepath,'test_B',[tr_num,'_',info,'_',img_files(j).name]));
                            end
                        end
                    end
                end
            end
        end
    end
end
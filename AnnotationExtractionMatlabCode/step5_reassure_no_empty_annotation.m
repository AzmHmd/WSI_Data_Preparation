clear
clc;
res = {'1x','10x','20x', '40x'};
folder ={'img_box_lumenORwall','img_box_lumenANdwall'};

parfor i0 = 1:length(res)
    for f = 1:length(folder)
        rootpath = ['/home/azamhamidinekoo/Documents/dataset/RMS-dataset/Annotations/vasculature/',res{i0},'/*'];
        rms_dir = dir(rootpath);
        for i = 1:length(rms_dir)
            if ~strcmp(rms_dir(i).name,'.') && ~strcmp(rms_dir(i).name,'..')
                d = dir(fullfile(rms_dir(i).folder,rms_dir(i).name,folder{f},'/*.png'))
                for k = 1:length(d)
                    I = imread(fullfile(d(k).folder,d(k).name));
                    x = max(I);
                    if x==0
                        disp(fullfile(d(k).folder,d(k).name))
                    end
                end
            end
        end
    end
end


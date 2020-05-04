clear; close all; clc;

res = {'1x','10x','20x', '40x'};

for i0 = 1:length(res)
    rootpath = ['/home/azamhamidinekoo/Documents/dataset/RMS-dataset/Annotations/vasculature/',res{i0},'/'];
    savepath = ['/home/azamhamidinekoo/Documents/dataset/projects/vasculature/sets_annotation/training/',res{i0},'/'];
    
    display = 0;
    rms_dir = dir(rootpath);
    
    for i = 1:length(rms_dir)
        if ~strcmp(rms_dir(i).name,'.') && ~strcmp(rms_dir(i).name,'..')
            sq_files = dir(fullfile(rms_dir(i).folder, rms_dir(i).name,'/box/*.png'));
            for i_sq = 1:length(sq_files)
                
                %read the square boxes
                if ~endsWith(sq_files(i_sq).name,'T.png')
                    img_binary_sq = imread(fullfile(sq_files(i_sq).folder, sq_files(i_sq).name));
                    img_raw = imread(strrep(fullfile(sq_files(i_sq).folder, sq_files(i_sq).name),'.png','T.png'));
                    img_size = size(img_binary_sq);
                    
                    %read the lumens
                    if exist(strrep(fullfile(sq_files(i_sq).folder, sq_files(i_sq).name),'box','lumen'))
                        img_binary_lumen = imread(strrep(fullfile(sq_files(i_sq).folder, sq_files(i_sq).name),'box','lumen'));
                    else
                        img_binary_lumen = uint8(255.*zeros(img_size));
                    end
                    
                    %read the walls
                    if exist(strrep(fullfile(sq_files(i_sq).folder, sq_files(i_sq).name),'box','wall'))
                        img_binary_wall = imread(strrep(fullfile(sq_files(i_sq).folder, sq_files(i_sq).name),'box','wall'));
                    else
                        img_binary_wall = uint8(255.*zeros(img_size));
                    end
                    
                    if nnz(img_binary_sq)>.98*size(img_binary_sq,1)*size(img_binary_sq,2)
                        imgbox = uint8(255.*im2double(img_raw).*im2double(repmat(img_binary_sq,[1 1 3])));
                        img_binary_sq_lumen = img_binary_sq.*img_binary_lumen;
                        img_binary_box_lumen = zeros(size(img_binary_sq_lumen));
                        img_binary_box_lumen(img_binary_sq_lumen>0) = 1;
                        img_binary_box_lumen = uint8(255.*img_binary_box_lumen);
                        
                        img_binary_sq_wall = img_binary_sq.*img_binary_wall;
                        img_binary_box_wall = zeros(size(img_binary_sq_wall));
                        img_binary_box_wall(img_binary_sq_wall>0) = 1;
                        img_binary_box_wall = uint8(255.*img_binary_box_wall);                        
                        
                        % calculated in uint8
                        img_binary_box_lumen_wall = img_binary_box_lumen/max(img_binary_box_lumen(:)) + img_binary_box_wall./max(img_binary_box_wall(:));
                        
                        if display == 1
                            % show the images in a figure
                            fig = figure(1);
                            subplot(231);imshow(img_raw);title('raw image')
                            subplot(232);imshow(imgbox);title('selected region box')
                            hold on
                            findboundaries(imgbox,img_binary_lumen,'g')
                            findboundaries(imgbox,img_binary_wall,'c')
                            subplot(233);imshow(img_binary_sq_lumen);title('lumen')
                            subplot(234);imshow(img_binary_sq_wall);title('wall')
                            subplot(235);imshow(img_binary_box_lumen_wall);title('lumen-wall')
                            
                            saveas(fig,['saving/',num2str(i0),'_',num2str(i),'_',num2str(i_sq),'.png'])
                            close all
                        end
                        % save the results (extracted annotations)
                        if nnz(img_binary_box_lumen_wall) > 0
                            savingpath = fullfile(rms_dir(i).folder, rms_dir(i).name);
                            if ~exist(fullfile(savingpath,'img_box'),'dir')
                                mkdir(fullfile(savingpath,'img_box'));
                                mkdir(fullfile(savingpath,'img_box_lumen'));
                                mkdir(fullfile(savingpath,'img_box_wall'));
                                mkdir(fullfile(savingpath,'img_box_lumen_wall'));
                            end
                            imwrite(imgbox,strrep(fullfile(sq_files(i_sq).folder, sq_files(i_sq).name),'box','img_box'));
                            imwrite(img_binary_sq_lumen,strrep(fullfile(sq_files(i_sq).folder, sq_files(i_sq).name),'box','img_box_lumen'));
                            imwrite(img_binary_sq_wall,strrep(fullfile(sq_files(i_sq).folder, sq_files(i_sq).name),'box','img_box_wall'));
                            imwrite(img_binary_box_lumen_wall,strrep(fullfile(sq_files(i_sq).folder, sq_files(i_sq).name),'box','img_box_lumen_wall'));
                        end
                        clear img_raw img_binary_sq img_binary_lumen img_binary_wall img_binary_sq_lumen img_binary_sq_wall img_binary_box_lumen_wall
                    end
                end
            end
        end
    end
end

function findboundaries(I,mask,colour)
BW = imbinarize(mask);
% figure;imshow(mask)
% Calculate boundaries of regions in image and overlay the boundaries on the image.
[B,~] = bwboundaries(BW,'noholes');
% imshow(I)
% hold on
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2), boundary(:,1), colour, 'LineWidth', 2)
end
end
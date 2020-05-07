% change folder names 
clear;clc;
res = {'1x','10x','20x', '40x'};
for i = 1:length(res)
path1 = ['/home/azamhamidinekoo/Documents/dataset/RMS-dataset/Annotations/vasculature/',res{i}];
path1_dir = dir(path1);
for j = 1:length(path1_dir)
    if ~strcmp(path1_dir(j).name,'.') && ~strcmp(path1_dir(j).name,'..')
      path2_dir = dir([path1_dir(j).folder,'/',path1_dir(j).name,'/box*']);
      if ~exist([path1_dir(j).folder,'/',path1_dir(j).name,'/box'],'dir')
      name1 = [path2_dir(1).folder,'/',path2_dir(1).name];
      name2 = [path1_dir(j).folder,'/',path1_dir(j).name,'/box'];
      system(['mv ',name1,' ', name2])
      end
    end
end
end



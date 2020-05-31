%% show the learning process
clear all;
rootprojects = dir('/home/azamhamidinekoo/Documents/projects/HE_vasculature_pix2pixHD_Azam/checkpoints/fold*');
for rp = 1:length(rootprojects)
    project = rootprojects(rp).name;
    f = fopen(fullfile(rootprojects(rp).folder,rootprojects(rp).name,'/loss_log.txt'),'r');
    fileline = fgetl(f);
    epoch_pre = 1;
    l = 0;
    x = 1;
    G_GAN = 0;
    G_GAN_Feat = 0;
    G_VGG = 0;
    D_real = 0;
    D_fake = 0;
    while fileline>0
        if contains(fileline,'epoch')
            elements = strsplit(fileline,' ');
            elements = elements(~cellfun(@isempty, elements));
            epoch = str2num(elements{2});
            if epoch_pre == epoch
                G_GAN = G_GAN + str2num(elements{end-8});
                G_GAN_Feat = G_GAN_Feat + str2num(elements{end-6});
                G_VGG = G_VGG + str2num(elements{end-4});
                D_real = D_real + str2num(elements{end-2});
                D_fake = D_fake + str2num(elements{end});
                l = l+1;
            else
                process(x,:) = [epoch,G_GAN/l,G_GAN_Feat/l,G_VGG/l,D_real/l,D_fake/l];
                epoch_pre = epoch;
                G_GAN = 0;
                G_GAN_Feat = 0;
                G_VGG = 0;
                D_real = 0;
                D_fake = 0;
                l = 0;
                x = x+1;
            end
        end
        fileline = fgetl(f);
    end
    figure;
    hold on;
    plot(process(:,1), process(:,2),'r')
    plot(process(:,1), process(:,3),'b')
    plot(process(:,1), process(:,4),'k')
    plot(process(:,1), process(:,5),'g')
    plot(process(:,1), process(:,6),'y')
    legend('G-GAN','G-GAN-Feat','G-VGG','D-real','D-fake')
    title(strrep(rootprojects(rp).name,'_','-'))
end

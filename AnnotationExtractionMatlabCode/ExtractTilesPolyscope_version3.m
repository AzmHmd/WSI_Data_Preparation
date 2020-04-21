function ExtractTilesPolyscope_version2(ImagePath, AnnotationPath, PatchPath, LabelMap, TileSize, Resolution, DaTile, CreateBlanks)
%EXTRACTPATCHESPOLYSCOPE Summary of this function goes here
%   Detailed explanation goes here

if nargin < 5
    TileSize = [2000 2000];
end

if nargin < 6
    Resolution = 1;
end

if nargin < 7
    DaTile = true;
end

if nargin < 8
    CreateBlanks = false;
end

ImageSize = reshape(wsi_size(ImagePath), 1, [])*2.^(-Resolution);

TileGrid = ceil(ImageSize./TileSize);

annotationText = fileread(AnnotationPath);
annotationText = regexprep(annotationText, '[\[()\]]', '');
lines = textscan(annotationText, '%s', 'Delimiter', '\n');

annotations = cellfun(@(x) split(x, ','), lines{1}, 'UniformOutput', false);
annotationTypes = cellfun(@(x) str2double(x(3)), annotations);
annotationActive = cellfun(@(x) str2double(x(1)), annotations);

% specify which type of annotations to be selected: free-hand and
% rectangles
annotations = annotations((annotationTypes==4 | annotationTypes==2) & annotationActive==1);
annotationTypes = annotationTypes((annotationTypes==4 | annotationTypes==2) & annotationActive==1);

annotationColour = cellfun(@(x) x(end-2), annotations);
colours = unique(annotationColour);

if nargin < 4
    LabelMap = containers.Map(colours, colours);
else
    isValidColour = isKey(LabelMap, colours);
    invalidColours = colours(~isValidColour);
    
    if ~isempty(invalidColours)
        warning('Warning: The following annotation colours are present in the annotation file, but are missing in the provided labelMap:\n%s\n%s', strjoin(invalidColours, ', '), 'Annotations with these colours will be skipped.');
        
        isValidAnnotation = isKey(LabelMap, annotationColour);
        %           annotations = annotations(isValidAnnotation);
        annotations = annotations(isValidAnnotation);
        annotationTypes = annotationTypes(isValidAnnotation);
        
        annotationColour = annotationColour(isValidAnnotation);
        colours = colours(isValidColour);
    end
end

labels = cellfun(@(x) LabelMap(x), colours, 'UniformOutput', false);

if CreateBlanks
    for i=1:length(colours)
        mkdir(fullfile(PatchPath, labels{i}));
        
        for x=0:(TileGrid(1)-1)
            for y=0:(TileGrid(2)-1)
                currentTileSize = min(TileSize([2 1]), ImageSize([2 1])-([y x].*TileSize([2 1])));
                
                if DaTile
                    imwrite(zeros(currentTileSize), fullfile(PatchPath, labels{i}, ['Da' num2str(x + (y*TileGrid(1))) '.png']));
                else
                    imwrite(zeros(currentTileSize), fullfile(PatchPath, labels{i}, [num2str(x) '_' num2str(y) '.png']));
                end
            end
        end
    end
end

coords = cellfun(@(x) reshape(str2double(x(4:end-3))*ImageSize(1), 2, [])', annotations, 'UniformOutput', false);
% this line is added to extract the rectangles
coords(annotationTypes==2) = cellfun(@(x) [x(1, 1) x(1, 2); x(1, 1) x(2, 2); x(2, 1) x(2, 2); x(2, 1) x(1, 2)], coords(annotationTypes==2), 'UniformOutput', false);
padding = [100 100 100 100];

for i=1:length(coords)
    bounds = {[floor(min(coords{i}(:, 2)))-padding(1) ceil(max(coords{i}(:, 2)))+padding(2)] [floor(min(coords{i}(:, 1)))-padding(3) ceil(max(coords{i}(:, 1)))+padding(4)]};
    
    shiftedCoords = [coords{i}(:, 1)-bounds{2}(1)+1 coords{i}(:, 2)-bounds{1}(1)+1];
    interpolatedCoords = round(pathLengthParameterisationSLAM(shiftedCoords, 'pathLength', 0.5));
    
    regionMask = false(bounds{1}(2)-bounds{1}(1)+1, bounds{2}(2)-bounds{2}(1)+1);
    regionMask(sub2ind(size(regionMask), interpolatedCoords(:, 2), interpolatedCoords(:, 1))) = true;
    regionMask = imfill(regionMask, 'holes');
    
    %if nnz(regionMask) > 10
    tileRangeX = max(min(floor(bounds{2}./TileSize(1)),TileGrid(1)), 0);
    %             tileRangeX = max(min(floor(bounds{2}./2000),TileGrid(1)), 0);
    tileRangeY = max(min(floor(bounds{1}./TileSize(1)),TileGrid(2)), 0);
    %             tileRangeY = max(min(floor(bounds{1}./2000),TileGrid(2)), 0);
    
    for u=tileRangeX(1):tileRangeX(2)
        for v=tileRangeY(1):tileRangeY(2)
            patchFolder = fullfile(PatchPath, LabelMap(annotationColour{i}));
            
            if ~isfolder(patchFolder)
                mkdir(patchFolder);
            end
            
            if DaTile
                maskPath = fullfile(patchFolder, ['Da' num2str(u + (v*TileGrid(1))) '.png']);
            else
                maskPath = fullfile(patchFolder, [num2str(u) '_' num2str(v) '.png']);
            end
            
            tilePosition = [v u].*TileSize([2 1]);
            currentTileSize = min(TileSize([2 1]), ImageSize([2 1])-([v u].*TileSize([2 1])));
            
            if DaTile
                imageTilePath = fullfile(patchFolder, ['Da' num2str(u + (v*TileGrid(1))) 'T.png']);
            else
                imageTilePath = fullfile(patchFolder, [num2str(u) '_' num2str(v) 'T.png']);
            end
            
%             close all;
            magnif = {'40x','20x','10x'};
            select = {[4,1],[2,2],[1,3]};
            for ip = 1:size(select,2)
                fac = select{ip}(1);
                rez = select{ip}(2);
                maskPath_p = strrep(maskPath,'10x',magnif{ip});
                imageTilePath_p = strrep(imageTilePath,'10x',magnif{ip});
                tile = imread_wsi(ImagePath, 'ReductionLevel', rez, 'PixelRegion', {[tilePosition(1)*fac+1 tilePosition(1)*fac+currentTileSize(1)*fac], [tilePosition(2)*fac+1 tilePosition(2)*fac+currentTileSize(2)*fac]});
                %                     tile = imread_wsi(ImagePath, 'ReductionLevel', Resolution, 'PixelRegion', {[tilePosition(1)+1 tilePosition(1)+currentTileSize(1)], [tilePosition(2)+1 tilePosition(2)+currentTileSize(2)]});
                %figure(ip);imshow(tile)
                if ~exist(strrep(patchFolder,'10x',magnif{ip}))
                    mkdir(strrep(patchFolder,'10x',magnif{ip}));
                end
                imwrite(tile, imageTilePath_p);
                
                annotationPosition = [[bounds{1}(1) bounds{2}(1)]-tilePosition+1; [bounds{1}(2) bounds{2}(2)]-tilePosition+1];
                annotationRegion = [max(1, 2-annotationPosition(1, :)); size(regionMask)-max(0, annotationPosition(2, :)-TileSize([2 1]))];
                annotationPosition = [max(1, annotationPosition(1, :)); min(TileSize([2 1]), annotationPosition(2, :))];
                
                subMask = regionMask(annotationRegion(1, 1):annotationRegion(2, 1), annotationRegion(1, 2):annotationRegion(2, 2));
                
                if nnz(subMask) > 0
                    if isfile(maskPath_p)
                        mask = im2double(imread(maskPath_p));
                    else
                        currentTileSize = min(TileSize([2 1]), ImageSize([2 1])-([v u].*TileSize([2 1])));
                        mask = zeros(fac*currentTileSize);
                    end
                    newsize = size(mask(fac*annotationPosition(1, 1):fac*annotationPosition(2, 1), fac*annotationPosition(1, 2):fac*annotationPosition(2, 2)));
                    mask(fac*annotationPosition(1, 1):fac*annotationPosition(2, 1), fac*annotationPosition(1, 2):fac*annotationPosition(2, 2)) = max(mask(fac*annotationPosition(1, 1):fac*annotationPosition(2, 1), fac*annotationPosition(1, 2):fac*annotationPosition(2, 2)), imresize(subMask,newsize));
                    imwrite(mask, maskPath_p);
                    %figure(5*ip);imshow(mask)
                else
                    zeromask = zeros(size(tile));
                    imwrite(zeromask,maskPath_p);
                end
                clear tile mask annotationPosition annotationRegion subMask
            end
            %me
            
        end
    end
    %end
end
end

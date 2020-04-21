function Size = wsi_size(imagePath, varargin)
%IMSIZE Summary of this function goes here
%   Detailed explanation goes here

    if ~isfile(imagePath)
        throw(MException('WSI:wsi_size:FileNotFound', ['The image file "' imagePath '" does not exist.']));
    end
        
    if length(varargin) >= 1
        Type = varargin{1};
    else
        Type = '';
    end
    
	switch Type
        case 'jp2'
            varargin = varargin(2:end);
        case 'openslideFormat'
            varargin = varargin(2:end);
        case 'czi'
            varargin = varargin(2:end);
        otherwise
            Type = DetectWSIType(imagePath);
	end
    
    Resolution = 0;
    
	for i=1:2:length(varargin)
        switch varargin{i}
            case 'ReductionLevel'
                Resolution = varargin{i+1};
            otherwise
        end
	end
            
	switch Type
        case 'jp2'
            Info = imfinfo(imagePath);
            Size = ceil([Info.Width Info.Height]/(2.^Resolution));
        case 'openslideFormat'
            slidePtr = openslide_open(imagePath);
            [~, ~, width, height, ~, scales, ~] = openslide_get_slide_properties(slidePtr);
            Size = floor(double([width, height])./scales(Resolution+1));
            openslide_close(slidePtr);
            clear slidePtr;
        case 'czi'
            CZIReader = czireader.CZIReader(imagePath);
            Size = double(CZIReader.getImageSize(Resolution));
            CZIReader.close();
        otherwise
            throw(MException('WSI:wsi_size:InvalidImageFormat', 'The image format supplied was not recognised.'));
    end
end


function Image = imread_wsi( Filename, varargin )
    if ~isfile(Filename)
        throw(MException('WSI:imread_wsi:FileNotFound', ['The image file "' Filename '" does not exist.']));
    end
    
    if length(varargin) >= 1
        Type = varargin{1};
    else
        Type = '';
    end

    switch Type
        case 'jp2'
            Image = imread(Filename, varargin{2:end});
        case 'openslideFormat'
            Image = imread_openslide(Filename, varargin{2:end});
        case 'czi'
            Image = imread_czi(Filename, varargin{2:end});
        otherwise
            Type = DetectWSIType(Filename);
            
            switch Type
                case 'jp2'
                    Image = imread(Filename, varargin{:});
                case 'openslideFormat'
                    Image = imread_openslide(Filename, varargin{:});
                case 'czi'
                    Image = imread_czi(Filename, varargin{:});
                otherwise
                    throw(MException('WSI:imread_wsi:InvalidImageFormat', 'The image format supplied was not recognised.'));
            end
    end
end

function Image = imread_openslide( Filename, varargin )
    Resolution = [];
    PixelRegion = [];

    for i=1:2:length(varargin)
        switch varargin{i}
            case 'ReductionLevel'
                Resolution = varargin{i+1};
            case 'PixelRegion'
                PixelRegion = varargin{i+1};
            otherwise
        end
    end
    
    slidePtr = openslide_open(Filename);
    
    if isempty(Resolution)
        Resolution = 0;
    end
    
    if isempty(PixelRegion)
        [~, ~, width, height, ~, scales, ~] = openslide_get_slide_properties(slidePtr);
        x = 0;
        y = 0;
        width = floor(double(width)/scales(Resolution+1));
        height = floor(double(height)/scales(Resolution+1));
    else
        x = PixelRegion{2}(1)-1;
        y = PixelRegion{1}(1)-1;
        width = floor(PixelRegion{2}(2) - PixelRegion{2}(1)) + 1;
        height = floor(PixelRegion{1}(2) - PixelRegion{1}(1)) + 1;
    end
    
    Image = openslide_read_region(slidePtr, x, y, width, height, 'level', Resolution);

    Image = Image(:,:,2:4);
    %{
    Image = im2double(Image);
    
    alpha = 0;
    beta = 1.1;
    gamma = 1.3;
    
    Image = Image + alpha;
    Image = Image.*beta;
    Image = Image.^(gamma);
    Image(Image<0) = 0;
    Image(Image>1) = 1;
    Image = uint8(255.*Image);
    %}
    openslide_close(slidePtr);
    clear slidePtr;
end

function Image = imread_czi( Filename, varargin )
    global CachedCZIReader;
    
    Resolution = [];
    PixelRegion = [];

    for i=1:2:length(varargin)
        switch varargin{i}
            case 'ReductionLevel'
                Resolution = varargin{i+1};
            case 'PixelRegion'
                PixelRegion = varargin{i+1};
            otherwise
        end
    end
    
    if ~isjava(CachedCZIReader) || ~any(cellfun(@(x) strcmp(x, 'FileName'), methods(CachedCZIReader)))
        CachedCZIReader = czireader.CZIReader(Filename);
    elseif ~strcmp(char(CachedCZIReader.FileName), Filename)
        CachedCZIReader.close();
        CachedCZIReader = czireader.CZIReader(Filename);
    end
    
    if isempty(Resolution)
        Resolution = 0;
    end
    
	Size = CachedCZIReader.getImageSize(Resolution);
    DownsampleFactor = CachedCZIReader.getDownsampleFactor();
        
    if isempty(PixelRegion)
        x = 0;
        y = 0;
        width = Size(1);
        height = Size(2);
    else
        x = PixelRegion{2}(1)-1;
        y = PixelRegion{1}(1)-1;
        width = floor(PixelRegion{2}(2) - PixelRegion{2}(1)) + 1;
        height = floor(PixelRegion{1}(2) - PixelRegion{1}(1)) + 1;
    end
    
    Image = typecast(CachedCZIReader.getImageRegion(Resolution, x, y, width, height), 'uint8');
    
    if (CachedCZIReader.imageBPP > 8)
        bytesPerPixel = ceil(CachedCZIReader.imageBPP/8);
        Image = reshape(Image, bytesPerPixel, []);
        M = 2.^(8*(0:bytesPerPixel-1)-CachedCZIReader.imageBPP);
        Image = M*double(Image);
    else
        Image = double(Image)/255;
    end
    
    Image = permute(reshape(Image, 3, width, height), [3 2 1]);

    %alpha = 0.15;
    %beta = 0.95;
    %gamma = 1.5;
    
    %alpha = 0.1;
    %beta = 1.35;
    %gamma = 1.5;
    
    alpha = 0;
    beta = 1;
    gamma = 1;
    
    Image = Image + alpha;
    Image = Image.*beta;
    Image = Image.^(gamma);
    Image(Image<0) = 0;
    Image(Image>1) = 1;
    Image = uint8(255.*Image);
    
    Image = imsharpen(Image, 'Radius', 5/(DownsampleFactor.^Resolution), 'Amount', 2);
end

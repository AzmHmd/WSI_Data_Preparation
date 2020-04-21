function Type = DetectWSIType(FileLocation)
    if exist('openslide_detect_vendor', 'file') == 2
        osVendor = openslide_detect_vendor(FileLocation);

        % Possible values for osVendor are (as of openslide 3.4.0):
        %
        % aperio
        % hamamatsu
        % generic-tiff
        % leica
        % mirax
        % sakura
        % tresle
        % ventana
        %
        % Currently we don't do anything with this value, we 
        % just check if it returns one of these or an empty string.
    else
        osVendor = '';
    end

    if isempty(osVendor)
        try
            imfinfo(FileLocation, 'JP2');
            Type = 'jp2';
        catch exception
            switch exception.identifier
                case 'MATLAB:imagesci:imfinfo:badFormat'
                    try 
                        test = czireader.CZIReader(FileLocation);
                        test.close();
                        Type = 'czi';
                    catch E
                        switch E.identifier
                            case 'MATLAB:Java:GenericException'
                                Type = '';
                            otherwise
                                rethrow(E);
                        end
                    end
                otherwise
                    rethrow(exception);
            end
        end
    else
       Type = 'openslideFormat';
    end
end
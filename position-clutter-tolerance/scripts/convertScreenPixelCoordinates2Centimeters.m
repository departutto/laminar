function convertScreenPixelCoordinates2Centimeters(xPixels, yPixels)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The origin (0, 0) corresponds to the right bottom corner of the screen.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    widthPixels  = 1278; % pixels
    heightPixels = 768;  % pixels
    
    widthCm      = 52;   % cm
    heightCm     = 32;   % cm
    
    xCm = (widthPixels  - xPixels + 1) / widthPixels  * widthCm;
    yCm = (heightPixels - yPixels + 1) / heightPixels * heightCm;

    fprintf('Coordinates: (%d, %d) pixels\n', xPixels, yPixels);
    fprintf('Coordinates: (%.3f, %.3f) cm\n', xCm, yCm);
    
end

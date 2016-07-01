function [pos1Hor, pos1Ver, pos2Hor, pos2Ver, sep] = stimulusSizeInDegrees(pos1Index, pos2Index, rightEdge, dist2Screen, height)
    
    % Screen dimensions in cm.
    screenHeightCm  = 32;
    screenWidthCm   = 52;

    % Screen dimensions in pixels.
    screenHeightPix = 768;
    screenWidthPix  = 1278;
    
    % Stimulus size (bounding box) in pixels.
    stimHeightPix   = 160;
    stimWidthPix    = 160;
    
    % Stimulus size (bounding box) in cm.
    stimHeigthCm    = stimHeightPix / screenHeightPix * screenHeightCm;
    stimWidthCm     = stimWidthPix  / screenWidthPix  * screenWidthCm;
    
    % Coordinates (X, Y) of the uppermost left corner of each position (in 
    % cm) relative to the origin (0, 0), which is assigned to the rightmost 
    % bottom corner of the screen.
    %                                      Y
    %                     top             /|
    %        ------------------------------|
    %        | 01 | 02 | 03 | 04 | 05 | 06 |        
    %        | 07 | 08 | 09 | 10 | 11 | 12 | 
    % left   | 13 | 14 | 15 | 16 | 17 | 18 | right
    %        | 19 | 20 | 21 | 22 | 23 | 24 |
    %     X <-----------------------------+ (0, 0) 
    %                   bottom        
    %
    coors = [ 52.000 32.000; ... % Position #01
              43.333 32.000; ... % Position #02
              34.667 32.000; ... % Position #03
              26.000 32.000; ... % Position #04
              17.333 32.000; ... % Position #05
               8.667 32.000; ... % Position #06
              52.000 24.000; ... % Position #07
              43.333 24.000; ... % Position #08
              34.667 24.000; ... % Position #09
              26.000 24.000; ... % Position #10
              17.333 24.000; ... % Position #11
               8.667 24.000; ... % Position #12
              52.000 16.000; ... % Position #13
              43.333 16.000; ... % Position #14
              34.667 16.000; ... % Position #15
              26.000 16.000; ... % Position #16
              17.333 16.000; ... % Position #17
               8.667 16.000; ... % Position #18
              52.000  8.000; ... % Position #19
              43.333  8.000; ... % Position #20
              34.667  8.000; ... % Position #21
              26.000  8.000; ... % Position #22
              17.333  8.000; ... % Position #23
               8.667  8.000; ... % Position #24
              17.333 24.000; ... % Position #25: [853 193]
                             ... % Position #26: [1066 40]
                             ... % Position #27: [407 385]
                             ... % Position #28: [590 385]
                             ... % Position #29: [10 193]
                             ... % Position #30: [200 193]
                             ... % Position #31: [660 560]
                             ... % Position #32: [853 400]
                             ... % Position #33: [870 370]
                             ... % Position #34: [1050 210]
                             ... % Position #35: [230 193]
                             ... % Position #36: [410 193]
                             ... % Position #37: [415 385]
                             ... % Position #38: [240 385]
                             ... % Position #39: [660 577]
                             ... % Position #40: [470 577]
                             ... % Position #41: [1 170]
                             ... % Position #42: [1 350]
                             ... % Position #43: [440 193]
                             ... % Position #44: [630 193]
               ];
 
    % Stimulus coordinates on the screen (in cm): 
    %          (X3, Y3)       
    %  coors -> ?----+
    %           | /\ |
    %           |/  \|
    %   (X1, Y1)|\  /|(X2, Y2)
    %           | \/ |
    %           +----+
    %          (X4, Y4)
            
    % [ X1 Y1 X2 Y2 ]
    horDim  = [coors(:, 1) coors(:, 2) - 0.5 * stimHeigthCm coors(:, 1) - stimWidthCm coors(:, 2) - 0.5 * stimHeigthCm];
    
    % [ X3 Y3 X4 Y4 ]
    verDim  = [coors(:, 1) - 0.5 * stimWidthCm coors(:, 2) coors(:, 1) - 0.5 * stimWidthCm coors(:, 2) - stimHeigthCm];   
    
    % Coordinates of the rat eye (in cm) relative to the origin (0, 0).
    xEye    = sqrt(rightEdge ^ 2 - dist2Screen ^ 2);
    yEye    = height;
    zEye    = dist2Screen;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Position #1.
    pos1Hor = computeAngle(horDim(pos1Index, 1), horDim(pos1Index, 2), 0, horDim(pos1Index, 3), horDim(pos1Index, 4), 0, xEye, yEye, zEye);
    pos1Ver = computeAngle(verDim(pos1Index, 1), verDim(pos1Index, 2), 0, verDim(pos1Index, 3), verDim(pos1Index, 4), 0, xEye, yEye, zEye);
    
    % Position #2.    
    pos2Hor = computeAngle(horDim(pos2Index, 1), horDim(pos2Index, 2), 0, horDim(pos2Index, 3), horDim(pos2Index, 4), 0, xEye, yEye, zEye);
    pos2Ver = computeAngle(verDim(pos2Index, 1), verDim(pos2Index, 2), 0, verDim(pos2Index, 3), verDim(pos2Index, 4), 0, xEye, yEye, zEye);
    
    fprintf('Stimulus size (horizontal x vertical):\n');
    fprintf('Position #1: %05.2f x %05.2f visual deg\n', pos1Hor, pos1Ver);
    fprintf('Position #2: %05.2f x %05.2f visual deg\n', pos2Hor, pos2Ver);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Coordinates of the stimulus center at position #1 (in cm) relative to
    % the origin (0, 0).
    pos1XCen = verDim(pos1Index, 1);
    pos1YCen = horDim(pos1Index, 2);
    
    % Coordinates of the stimulus center at position #2 (in cm) relative to
    % the origin (0, 0).
    pos2XCen = verDim(pos2Index, 1);
    pos2YCen = horDim(pos2Index, 2);
    
    % Point lying in the middle between the two stimuli.
    xCenter  = (pos1XCen + pos2XCen) / 2.0;
    yCenter  = (pos1YCen + pos2YCen) / 2.0;
    
    scale    = 0.5 * stimWidthCm / sqrt((xCenter - pos1XCen) ^ 2 + (yCenter - pos1YCen) ^ 2);
    
    xQ       = pos1XCen + scale * (xCenter - pos1XCen);
    yQ       = pos1YCen + scale * (yCenter - pos1YCen);
    zQ       = 0;
    
    xR       = pos2XCen + scale * (xCenter - pos2XCen);
    yR       = pos2YCen + scale * (yCenter - pos2YCen);
    zR       = 0;
    
    sep      = computeAngle(xQ, yQ, zQ, xR, yR, zR, xEye, yEye, zEye);
    fprintf('Min separation between the two positions: %05.2f visual deg\n', sep);
    
end

function angleDegree = computeAngle(xA, yA, zA, xB, yB, zB, xEye, yEye, zEye)

    % Calculation is carried out according to the law of cosines. 
    
    AB = sqrt((xA   - xB) ^ 2 + (yA   - yB) ^ 2 + (zA - zB)   ^ 2);
    EA = sqrt((xEye - xA) ^ 2 + (yEye - yA) ^ 2 + (zEye - zA) ^ 2);
    EB = sqrt((xEye - xB) ^ 2 + (yEye - yB) ^ 2 + (zEye - zB) ^ 2);
    
    angleCosine = (EA ^ 2 + EB ^ 2 - AB ^ 2) / (2 * EA * EB);
    angleDegree = 180.0 * acos(angleCosine) / pi;

end
    
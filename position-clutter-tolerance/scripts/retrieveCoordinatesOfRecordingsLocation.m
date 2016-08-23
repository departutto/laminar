% Conversion rate (coefficient) from units to mm.
k  = 35.524 / 1000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rat 68967; August 11, 2016.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          AP: 00.00 (mm)  LM: 00.00 (mm)  AP: 000 (units)  LM: 000 (units)
references = [ 12.10           26.35           231              639; ... % anterior reference point
               12.50           19.75           208              448; ... % medial reference point
               14.80           23.25           148              542; ... % posterior reference point
               12.30           22.75          -999             -999];    % penetration location
aprange    = [130 370];     % units 
lmrange    = [430 640];     % units
positions  = [0.0 0.0; ...  % AP/Y (mm) LM/X (mm)  
              0.0 0.5; ...  % +0.5 mm lateral
             -0.5 0.0];     % +0.5 mm anterior 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rat 68967; August 16, 2016.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          AP: 00.00 (mm)  LM: 00.00 (mm)  AP: 000 (units)  LM: 000 (units)
references = [ 13.22           26.98           231              639; ... % anterior reference point
               13.52           20.29           208              448; ... % medial reference point
               15.75           23.69           148              542; ... % posterior reference point
               13.42           22.80          -999             -999];    % penetration location
aprange    = [130 370];     % units 
lmrange    = [430 640];     % units
positions  = [0.0 0.0; ...  % AP/Y (mm) LM/X (mm)  
              0.0 0.5; ...  % +0.5 mm lateral
              0.0 1.0; ...  % +1.0 mm lateral
              0.0 1.5; ...  % +1.5 mm lateral
              0.0 2.0; ...  % +2.0 mm lateral
              0.0 2.5; ...  % +2.5 mm lateral
              0.7 2.5; ...  % +0.7 mm posterior, +2.5 mm lateral
              0.7 2.0; ...  % +0.7 mm posterior, +2.0 mm lateral
              0.7 1.0; ...  % +0.7 mm posterior, +1.0 mm lateral
              0.7 0.0];     % +0.7 mm posterior

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rat 68967; August 23, 2016.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          AP: 00.00 (mm)  LM: 00.00 (mm)  AP: 000 (units)  LM: 000 (units)
references = [  9.50           24.17           231              639; ... % anterior reference point
               10.03           17.45           208              448; ... % medial reference point
               12.30           20.99           148              542; ... % posterior reference point
               10.20           19.20          -999             -999];    % penetration location
aprange    = [130 370];     % units 
lmrange    = [430 640];     % units
positions  = [0.0 0.0; ...  % AP/Y (mm) LM/X (mm)
              0.0 0.5; ...  % +0.5 mm lateral, position #2
              0.0 1.0; ...  % +1.0 mm lateral, position #3
              0.7 1.0; ...  % +1.0 mm lateral, +0.7 mm posterior, position #4
              0.7 0.5; ...  % +0.5 mm lateral, +0.7 mm posterior, position #5
             -0.7 0.5; ...  % +0.5 mm lateral, +0.7 mm anterior, position #6
             -0.7 1.0; ...  % +1.0 mm lateral, +0.7 mm anterior, position #7
             -0.7 0.0];     % +0.7 mm anterior, position #8
          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x0 = references(4, 2);
y0 = references(4, 1);

for counter = 1:size(positions, 1)
    fprintf('Position #%d\n', counter);

    errors = [];
    xcurr  = x0 + positions(counter, 2);
    ycurr  = y0 + positions(counter, 1);
    
    desired1 = sqrt((references(1, 1) - ycurr) ^2 + (references(1, 2) - xcurr) ^ 2);
    desired2 = sqrt((references(2, 1) - ycurr) ^2 + (references(2, 2) - xcurr) ^ 2);
    desired3 = sqrt((references(3, 1) - ycurr) ^2 + (references(3, 2) - xcurr) ^ 2);    
    
    for x = lmrange(1):lmrange(2)
        for y = aprange(1):aprange(2)
            estimated1 = k * sqrt((references(1, 3) - y) ^ 2 + (references(1, 4) - x) ^ 2);
            estimated2 = k * sqrt((references(2, 3) - y) ^ 2 + (references(2, 4) - x) ^ 2);
            estimated3 = k * sqrt((references(3, 3) - y) ^ 2 + (references(3, 4) - x) ^ 2);
            errors(end + 1, :) = [x y ((estimated1 - desired1) ^ 2 + (estimated2 - desired2) ^ 2 + (estimated3 - desired3) ^ 2) / 3.0];
        end
    end
    
    [value, index] = min(errors(:, 3));
    fprintf('Estimated coordinates (X, Y) = (%d, %d)\n', errors(index, 1), errors(index, 2));
    
end

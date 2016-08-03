% Coordinates of the most anterior reference point.
xa = 564;  % units
za = 317;  % units

% Coordinates of the most medial reference point.
xb = 462;  % units
zb = 123;  % units

% Coordinates of the most posterior reference point.
xc = 577;  % units
zc = 58;   % units

% Distance from the reference points to the electrode penetration location.
la = 5.60; % mm
lb = 6.30; % mm
lc = 4.49; % mm

% Conversion rate from units to mm.
k  = 35.524 / 1000;

res = [];
for x = xb:730
    fprintf('%03d', x);
    for z = zc:za
        ta  = k * sqrt((xa - x) ^ 2 + (za - z) ^ 2);
        tb  = k * sqrt((xb - x) ^ 2 + (zb - z) ^ 2);
        tc  = k * sqrt((xc - x) ^ 2 + (zc - z) ^ 2);
        err = ((ta - la) ^ 2 + (tb - lb) ^ 2 + (tc - lc) ^ 2) / 3.0;
        res(end + 1, :) = [x z err];
    end
    fprintf('\b\b\b');
end

[value, index] = min(res(:, 3));
fprintf('\n[x, z] = [%d, %d]\n', res(index, 1), res(index, 2));

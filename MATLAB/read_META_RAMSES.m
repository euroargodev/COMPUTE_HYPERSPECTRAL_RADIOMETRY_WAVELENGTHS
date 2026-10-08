function META_RAMSES = read_META_RAMSES(filenc_meta)
% READ_META_RAMSES  Parse RAMSES wavelength polynomial coefficients from an
% Argo meta NetCDF file.
% MATLAB code based on Catherine Schmechtig's R code, translated with help
% from Claude, 8.10.2026
%
%   META_RAMSES = read_META_RAMSES('file_meta.nc')
%
% Returns a struct with fields c0s, c1s, c2s, c3s, c4s.

% Get the PARAMETER (char matrix: STRING64 x N_PARAM)
PARAMETER = ncread(filenc_meta, 'PARAMETER');

% Get the predeployment calibration coefficient (STRING4096 x N_PARAM)
PCC = ncread(filenc_meta, 'PREDEPLOYMENT_CALIB_COEFFICIENT');

% Convert to cell arrays of strings, one per parameter (transpose so
% each column of the char matrix becomes a row/string).
% strtrim also removes padding spaces and null characters.
PARAMETER = strtrim(cellstr(PARAMETER'));
PCC       = strtrim(cellstr(PCC'));

% Parameter string to look for (padding is handled by strtrim)
RAMSES_STRING = 'DOWN_IRRADIANCE_SPECTRUM';

% Find the entry containing DOWN_IRRADIANCE_SPECTRUM
index_ramses = find(strcmp(PARAMETER, RAMSES_STRING), 1);
if isempty(index_ramses)
    error('read_META_RAMSES:notFound', ...
        '%s not found in PARAMETER.', RAMSES_STRING);
end

PCC_RAMSES = PCC{index_ramses};

%% ---------------------------------------------------------------
%  PARSING the CALIBRATION (Coriolis parsing)
%  ---------------------------------------------------------------

% Split the PREDEPLOYMENT CALIB COEFFICIENT 
% Split on both ';' and ',' so it works whichever separator is used
RAMSES_PART = strtrim(strsplit(PCC_RAMSES, {';', ','}));

c0s = getcoef(RAMSES_PART, 'c0s=');
c1s = getcoef(RAMSES_PART, 'c1s=');
c2s = getcoef(RAMSES_PART, 'c2s=');
c3s = getcoef(RAMSES_PART, 'c3s=');
c4s = getcoef(RAMSES_PART, 'c4s=');

META_RAMSES = struct('c0s', c0s, 'c1s', c1s, 'c2s', c2s, ...
    'c3s', c3s, 'c4s', c4s);
end

function val = getcoef(parts, key)
% Find the element containing KEY, strip it, and convert to a number.
idx = find(contains(parts, key), 1);
if isempty(idx)
    val = NaN;
else
    val = str2double(erase(parts{idx}, key));
end
end
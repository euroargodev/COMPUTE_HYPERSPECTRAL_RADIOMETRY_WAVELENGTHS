function [waveb, WAVELENGTH] = compute_RAMSES_wavelengths(filenc_meta, META)
% COMPUTE_RAMSES_WAVELENGTHS  Wavelengths of the 255 pixels, and the
% binned wavelengths for the area of interest configured on the float.
% MATLAB code based on Catherine Schmechtig's R code, translated with help
% from Claude, 8.10.2026
%
%   [waveb, WAVELENGTH] = compute_RAMSES_wavelengths('file_meta.nc', META_RAMSES)

%% Wavelength computation
c0s = META.c0s;
c1s = META.c1s;
c2s = META.c2s;
c3s = META.c3s;
c4s = META.c4s;

% Wavelength 1 is associated to pixel number 0 in the documentation,
% hence the (i+1) in the polynomial (kept as in the R code)
i = (1:255)';
WAVELENGTH = c0s + c1s*(i+1) + c2s*(i+1).^2 + c3s*(i+1).^3 + c4s*(i+1).^4;

%% Area of interest configuration (sent by the float, can change over time)
names  = ncread(filenc_meta, 'LAUNCH_CONFIG_PARAMETER_NAME');
values = ncread(filenc_meta, 'LAUNCH_CONFIG_PARAMETER_VALUE');

% One string per parameter, with spaces and null characters removed
names = cellstr(names');
names = erase(names, ' ');
names = erase(names, char(0));

pixel_start_ACC = getconfig(names, values, 'CONFIG_RamsesAccOutputPixelBegin_NUMBER');
pixel_stop_ACC  = getconfig(names, values, 'CONFIG_RamsesAccOutputPixelEnd_NUMBER');
pixel_bin_ACC   = getconfig(names, values, 'CONFIG_RamsesAccOutputBinningSize_NUMBER');

Imin = pixel_start_ACC;
Imax = pixel_stop_ACC;
Nbin = pixel_bin_ACC;

N_VALUES = (Imax - Imin + 1) / Nbin;
if N_VALUES ~= fix(N_VALUES)
    warning('compute_RAMSES_wavelengths:binning', ...
        ['(Imax-Imin+1)/Nbin = %g is not an integer; ' ...
        'the last partial bin is dropped.'], N_VALUES);
    N_VALUES = floor(N_VALUES);
end

%% Binned wavelengths: mean of WAVELENGTH over each bin of Nbin pixels
waveb = zeros(N_VALUES, 1);
for ib = 1:N_VALUES
    idx = (Imin + (ib-1)*Nbin) : (Imin + ib*Nbin - 1);
    waveb(ib) = mean(WAVELENGTH(idx));
end

%disp(waveb)
end

function val = getconfig(names, values, key)
% Value of the launch config parameter whose (space-free) name equals KEY.
idx = find(strcmp(names, key), 1);
if isempty(idx)
    error('compute_RAMSES_wavelengths:notFound', ...
        '%s not found in LAUNCH_CONFIG_PARAMETER_NAME.', key);
end
val = double(values(idx));
end
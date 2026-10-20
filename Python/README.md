# Compute RAMSES hyperspectral wavelengths in Python

The Argopy library provides a Python implementation of the RAMSES hyperspectral wavelengths.

### High-level tool: 

For the end-user, the logic to access all the necessary information and orchestrate the wavelengths computation is provided through the ``ArgoFloat`` class, using the ``ramses`` extension.

It goes like this:

Create an ``ArgoFloat`` object with a WMO, including auxiliary data (use the ``aux=True`` argument)
```python
import argopy as ar

af = ArgoFloat(1902578, aux=True)  # mission-specific pixels
# af = ArgoFloat(3902759, aux=True)  # launch config pixels
```

You can then use any of the 3 possible methods to compute the most appropriate wavelength for your need:
```python
af.ramses.launch_wavelengths      # np.ndarray
af.ramses.wavelengths_by_cycle(3) # np.ndarray
af.ramses.wavelengths             # Dict[int, np.ndarray] 
```

You can also use some attributes to have more details about the computation:
```python
af.ramses.coefs          # Dict[str, float | List[float]]
af.ramses.binned_pixel   # Bool
af.ramses.cycle_strides  # Dict[int, Dict[str, int]]
```

### Low-level tools

Under the hood, the high-level methods above ultimately rely on 2 low-level methods than can be used by anyone:
1. one method reads the pre-deployment calibration string to retrieve coefficients for the down irradiance spectrum parameter of an Auxiliary metadata dataset: [argopy.utils.hyperspectral.read_coefs](https://github.com/euroargodev/argopy/blob/a2654026298b420a178622e170d07b48bdc6439b/argopy/utils/hyperspectral.py#L13)
1. one method computes the wavelengths array from coefficients and possibly pixel bin definition: [argopy.utils.hyperspectral.compute_ramses_wavelengths](https://github.com/euroargodev/argopy/blob/a2654026298b420a178622e170d07b48bdc6439b/argopy/utils/hyperspectral.py#L75)

From this repository sample data, these 2 functions can be used this way:

First we load the Auxiliary meta-data file:
```python
from argopy.utils import hyperspectral
import xarray as xr

meta_aux = xr.open_dataset('../3902759_meta_aux.nc', engine='argo')
```

Then we read calibration coefficients from the ``DOWN_IRRADIANCE_SPECTRUM`` parameter of ``PREDEPLOYMENT_CALIB_COEFFICIENT``:
```python
coefs = hyperspectral.read_coefs(meta_aux)
print(coefs.keys())
print(coefs['c0s'])
```
```
dict_keys(['c0s', 'c1s', 'c2s', 'c3s', 'c4s', 'CalAQ', 'Back1', 'Back2'])
299.824
```

Then, pixels bin can be read like this: 
```python
from argopy.utils.mappers import map_vars_to_dict

config = map_vars_to_dict(meta_aux, 'LAUNCH_CONFIG_PARAMETER_NAME', 'LAUNCH_CONFIG_PARAMETER_VALUE')
len(config.keys())  # A dictionary with 129 parameters

strides = {}
for pixel in ['PixelBegin', 'PixelEnd', 'BinningSize']:
    param = f"CONFIG_RamsesAccOutput{pixel}_NUMBER"
    print(f"{pixel:15s}: {config[param]}")
    strides[pixel] = int(config[param])
```

```python
{'PixelBegin': 5, 'PixelEnd': 144, 'BinningSize': 2}
```

And finally, wavelengths can be computed like this:
```python
wl = hyperspectral.compute_ramses_wavelengths(
    coefs["c0s"],
    coefs["c1s"],
    coefs["c2s"],
    coefs["c3s"],
    coefs["c4s"],
    strides["PixelBegin"],
    strides["PixelEnd"],
    strides["BinningSize"],
    strides["BinningSize"] != 1,
)
# len(wl) = 70
```
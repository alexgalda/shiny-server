# module for viewing the details of all available devices:
# https://github.com/Qiskit/qiskit-terra/blob/master/qiskit/tools/monitor/backend_overview.py

# Housekeeping: uncomment this to suppress deprecation warnings
import warnings
warnings.filterwarnings('ignore')
import qiskit
print(qiskit.__version__)

import numpy as np
import time
from qiskit import IBMQ
from qiskit import *
from qiskit.pulse import *
from qiskit.tools.monitor import job_monitor
from qiskit.visualization import plot_histogram
import qiskit.pulse.pulse_lib as pulse_lib
from qiskit.exceptions import QiskitError

IBMQ.save_account('e7b72db6919022a00d9a75557392311954b58280de131c451c9939ccb701b69a6d0d63e3fb912f086723d8cdcaf45c7f710d4c3ab1930c4df1a13768ad476202')
IBMQ.load_account()
from datetime import datetime

def get_unique_backends():
    """Gets the unique backends that are available.

    Returns:
        list: Unique available backends.

    Raises:
        QiskitError: No backends available.
        ImportError: If qiskit-ibmq-provider is not installed
    """
    try:
        from qiskit.providers.ibmq import IBMQ
    except ImportError:
        raise ImportError("The IBMQ provider is necessary for this function "
                          " to work. Please ensure it's installed before "
                          "using this function")
    backends = []
    for provider in IBMQ.providers():
        for backend in provider.backends():
            backends.append(backend)
    unique_hardware_backends = []
    unique_names = []
    for back in backends:
        if back.name() not in unique_names and not back.configuration().simulator:
            unique_hardware_backends.append(back)
            unique_names.append(back.name())
    if not unique_hardware_backends:
        raise QiskitError('No backends available.')
    return unique_names
    

def get_provider():
  return(IBMQ.get_provider(hub='ibm-q', group='open', project='main'))
  
def get_backend(provider, backend_name):
  return(provider.get_backend(backend_name))
  
def backend_config(backend):
  return(backend.configuration())
  
#def backend_defaults(backend):
#  return(backend.defaults())

def device_dt(backend_config):
  return(backend_config.dt)
  
def device_freq(backend_defaults):
  return(backend_defaults.qubit_freq_est[0])
  
def pending_jobs(backend):
  return(backend.status().pending_jobs)

def get_closest_multiple_of_16(num):
  return (int(num) - (int(num)%16))

def collect_channels(qubit):
  drive_chan = pulse.DriveChannel(qubit)
  meas_chan = pulse.MeasureChannel(qubit)
  acq_chan = pulse.AcquireChannel(qubit)
  return(drive_chan, meas_chan, acq_chan)

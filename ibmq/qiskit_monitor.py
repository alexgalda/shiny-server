# module for viewing the details of all available devices:
# https://github.com/Qiskit/qiskit-terra/blob/master/qiskit/tools/monitor/backend_overview.py

# Housekeeping: uncomment this to suppress deprecation warnings
import warnings
warnings.filterwarnings('ignore')
import qiskit
print(qiskit.__qiskit_version__['qiskit'])

from qiskit import IBMQ
from qiskit import *
from qiskit.tools.monitor import job_monitor

def qiskit_version():
  return(qiskit.__qiskit_version__['qiskit'])

IBMQ.save_account('e7b72db6919022a00d9a75557392311954b58280de131c451c9939ccb701b69a6d0d63e3fb912f086723d8cdcaf45c7f710d4c3ab1930c4df1a13768ad476202', overwrite=True) #UC
#IBMQ.save_account('f29271691284521bc15756ec20820f9d5f6ba807e83451ba3d45ee8f06bb44442aa5c39b04a7a6baf2c0efb606e988f6cac8c53b344bfcc4a8aa2f2ebde19c', overwrite=True) #YA
IBMQ.load_account()

def get_provider():
  return(IBMQ.get_provider(hub='ibm-q', group='open', project='main'))
  
def get_backend(provider, backend_name):
  return(provider.get_backend(backend_name))
  
def backend_config(backend):
  return(backend.configuration())
  
#def backend_defaults(backend):
#  return(backend.defaults())
  
# backend.status() ----------------------------------------

def backend_version(backend):                              # 24hr
  return(backend.status().backend_version)
  
def backend_pending_jobs(backend):               # 1hr               # 10min   value
  return(backend.status().pending_jobs)
  
def backend_operational(backend):                # 1hr                         TRUE/FALSE
  return(backend.status().operational)
  
def backend_status_msg(backend):                 # 1hr                         character
  return(backend.status().status_msg)
  
# backend.configuration() --------------------------------

def device_allow_object_storage(backend):                  # 24hr
  return(backend.configuration().allow_object_storage)
  
def device_allow_q_circuit(backend):                       # 24hr
  return(backend.configuration().allow_q_circuit)
  
def device_allow_q_object(backend):                        # 24hr
  return(backend.configuration().allow_q_object)
  
#def device_backend_version(backend):                       # 24hr
#  return(backend.configuration().backend_version)
  
def device_basis_gates(backend):                           # 24hr
  return(backend.configuration().basis_gates)
  
def device_conditional(backend):                           # 24hr
  return(backend.configuration().conditional)
  
def device_coupling_map(backend):                          # 24hr
  return(backend.configuration().coupling_map)
  
def device_credits_required(backend):                      # 24hr
  return(backend.configuration().credits_required)
  
def device_description(backend):                           # 24hr
  return(backend.configuration().description)
  
def device_gates(backend):                       #ignore?  # 24hr              definitions of single- and two-qubit gates (id, u1, u2, u3, cx) and their parameters
  return(backend.configuration().gates)
  
def device_local(backend):                                 # 24hr
  return(backend.configuration().local)
  
def device_max_experiments(backend):                       # 24hr
  return(backend.configuration().max_experiments)
  
def device_max_shots(backend):                             # 24hr
  return(backend.configuration().max_shots)
  
def device_memory(backend):                                # 24hr
  return(backend.configuration().memory)
  
def device_n_qubits(backend):                              # 24hr
  return(backend.configuration().n_qubits)
  
def device_n_registers(backend):                           # 24hr
  return(backend.configuration().n_registers)
  
def device_online_date(backend):                           # 24hr
  return(backend.configuration().online_date)
  
def device_open_pulse(backend):                            # 24hr
  return(backend.configuration().open_pulse)
  
def device_quantum_volume(backend):                        # 24hr
  return(backend.configuration().quantum_volume)
  
def device_sample_name(backend):                           # 24hr
  return(backend.configuration().sample_name)
  
def device_simulator(backend):                             # 24hr
  return(backend.configuration().simulator)
  
def device_url(backend):                                   # 24hr
  return(backend.configuration().url)
  
# backend_config -----------------------------------------
  
def device_dt(backend_config):                             # 24hr
  return(backend_config.dt)
  
def device_dtm(backend_config):                            # 24hr
  return(backend_config.dtm)
  
def device_acquisition_latency(backend_config):            # 24hr
  return(backend_config.acquisition_latency)
  
def device_conditional_latency(backend_config):            # 24hr
  return(backend_config.conditional_latency)
  
def device_discriminators(backend_config):                 # 24hr
  return(backend_config.discriminators)
  
def device_meas_kernels(backend_config):                   # 24hr
  return(backend_config.meas_kernels)
  
def device_meas_levels(backend_config):                    # 24hr
  return(backend_config.meas_levels)
  
def device_meas_lo_range(backend_config):                  # 24hr
  return(backend_config.meas_lo_range)
  
def device_meas_map(backend_config):                       # 24hr
  return(backend_config.meas_map)
  
def device_n_uchannels(backend_config):                    # 24hr
  return(backend_config.n_uchannels)
  
def device_qubit_lo_range(backend_config):                 # 24hr
  return(backend_config.qubit_lo_range)
  
def device_rep_times(backend_config):                      # 24hr
  return(backend_config.rep_times)
  
def device_u_channel_lo(backend_config):                   # 24hr
  return(backend_config.u_channel_lo)
  
def device_uchannels_enabled(backend_config):              # 24hr
  return(backend_config.uchannels_enabled)
  
# backend_defaults ---------------------------------------

def backend_meas_freq_est(backend):              # 1hr CALIBRATION             value
  if hasattr(backend.defaults(), 'meas_freq_est'):
    return(backend.defaults().meas_freq_est[0])
  else:
    return(0)

def backend_qubit_freq_est(backend):             # 1hr CALIBRATION             value
  if hasattr(backend.defaults(), 'qubit_freq_est'):
    return(backend.defaults().qubit_freq_est[0])
  else:
    return(0)

def backend_buffer(backend):                               # 24hr              0
  return(backend.defaults().buffer)

def backend_cmd_def(backend):                    #ignore?  # 24hr              list of basis gates
  return(backend.defaults().cmd_def)

def backend_pulse_library(backend):              # 1hr CALIBRATION             list of all basis gate pulses as separate pulses | to file when different
  if hasattr(backend.defaults(), 'pulse_library'):
    pulse_array = []
    for i in range(len(backend.defaults().pulse_library)):
      pulse_array.append(backend.defaults().pulse_library[i].to_dict())
    return(pulse_array)
  else:
    return([])

# backend.properties() -----------------------------------

def backend_last_update_date(backend):           # 1hr CALIBRATION             character (timestamp of last calibration)
  return(backend.properties().last_update_date)

def backend_qubits(backend):                     # 1hr CALIBRATION             list of qubit calibration properties
    return(backend.properties().qubits)

def backend_gates(backend):                      # 1hr CALIBRATION             list of single- and two-qubit gate calibration properties
  return(backend.properties().gates)

def backend_general(backend):                              # 24hr              empty list
  return(backend.properties().general)
  
  


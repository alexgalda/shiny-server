# -*- coding: utf-8 -*-

# This code is part of Qiskit.
#
# (C) Copyright IBM 2017, 2018.
#
# This code is licensed under the Apache License, Version 2.0. You may
# obtain a copy of this license in the LICENSE.txt file in the root directory
# of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
#
# Any modifications or derivative works of this code must retain this
# copyright notice, and modified files need to carry a notice indicating
# that they have been altered from the originals.
# pylint: disable=invalid-name


import math
from qiskit.exceptions import QiskitError

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
    return unique_hardware_backends
    
def backend_calibration_full(backend):
    try:
        # pylint: disable=import-error,no-name-in-module
        from qiskit.providers.ibmq import IBMQBackend
    except ImportError:
        raise ImportError("The IBMQ provider is necessary for this function "
                          " to work. Please ensure it's installed before "
                          "using this function")

    if not isinstance(backend, IBMQBackend):
        raise QiskitError('Input variable is not of type IBMQBackend.')
    config = backend.configuration().to_dict()
    status = backend.status().to_dict()
    config_dict = {**status, **config}
    if not config['simulator']:
        props = backend.properties().to_dict()
        
    # Stop here if simulator
    if config['simulator']:
        return
        
    return(props['qubits'], props['gates'])
    

def backend_calibration(backend):
    try:
        # pylint: disable=import-error,no-name-in-module
        from qiskit.providers.ibmq import IBMQBackend
    except ImportError:
        raise ImportError("The IBMQ provider is necessary for this function "
                          " to work. Please ensure it's installed before "
                          "using this function")

    if not isinstance(backend, IBMQBackend):
        raise QiskitError('Input variable is not of type IBMQBackend.')
    config = backend.configuration().to_dict()
    status = backend.status().to_dict()
    config_dict = {**status, **config}
    if not config['simulator']:
        props = backend.properties().to_dict()
        
    # Stop here if simulator
    if config['simulator']:
        return
    
    qubit_calib_data = []
    gate_err_data = []
    gate_dur_data = []
    for i in range(len(props['qubits'])):
        field = []
        for j in range(len(props['qubits'])):
            x = 0
            field.append(x)
        gate_err_data.append(field)
    for i in range(len(props['qubits'])):
        field = []
        for j in range(len(props['qubits'])):
            x = 0
            field.append(x)
        gate_dur_data.append(field)
        
    for qub in range(len(props['qubits'])):
        name = 'Q%s' % qub
        qubit_data = props['qubits'][qub]
        gate_data = [g for g in props['gates'] if g['qubits'] == [qub]]
        t1_info = qubit_data[0]
        t2_info = qubit_data[1]
        freq_info = qubit_data[2]
        readout_info = qubit_data[3]

        freq = freq_info['value']
        T1 = t1_info['value']
        T2 = t2_info['value']
        for gd in gate_data:
            if gd['gate'] == 'u1':
                U1 = gd['parameters'][0]['value']
                break
        for gd in gate_data:
            if gd['gate'] == 'u2':
                U2 = gd['parameters'][0]['value']
                break
        for gd in gate_data:
            if gd['gate'] == 'u3':
                U3 = gd['parameters'][0]['value']
                break
        readout_error = readout_info['value']
        qubit_calib_data.append([name, freq, T1, T2, U1, U2, U3, readout_error])
        
    multi_qubit_gates = [g for g in props['gates'] if len(g['qubits']) > 1]
    for pair in range(len(multi_qubit_gates)):
        q1 = multi_qubit_gates[pair]['qubits'][0]
        q2 = multi_qubit_gates[pair]['qubits'][1]
        gate_err_data[q1][q2] = multi_qubit_gates[pair]['parameters'][0]['value']
        gate_dur_data[q1][q2] = multi_qubit_gates[pair]['parameters'][1]['value']
    return(qubit_calib_data, gate_err_data, gate_dur_data)

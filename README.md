# Differentiable Quantum Programming Language with Unbounded Loops #

Implementation and experiment codes for
*Differentiable quantum programming language with unbounded loops*

This repository contains two parts:
- A Python package `pqwhile` for generating Q# programs from parameterized quantum-while programs.
- Experiment codes of case studies in the paper *Differentiable quantum programming language with unbounded loops*

## Requirements ##

* [Microsoft Quantum Development Kit: IQ# Kernel](https://github.com/microsoft/iqsharp), which provides Q# backend used by the Python client.

* [Python3](https://www.python.org/).

## Installation ##

This repository provides a [Dockerfile]() that includes IQ# Kernel and installation for `pqwhile`.
The user can directly built a docker image from this Dockerfile and use it.
In addition, user can also manually install IQ# kernel and `pqwhile`.

### Install as a Container ###

1. Clone this repository and cd to the root directory.
    ```bash
    git clone https://github.com/njuwfang/DifferentiableQPL && cd DifferentiableQPL
    ```
2. Build docker image.
    ```bash
    docker build -t differentiableqpl .
    ```
3. Run the built image.
    ```bash
    docker run -t -i differentiableqpl /bin/bash
    ```

### Manually install ###

1. Follow the instructions of [Set up a Q# and Python environment](https://docs.microsoft.com/en-us/azure/quantum/install-python-qdk) to configure a Python development environment for calling Q# operations.
2. Clone this repository and cd to the root directory.
    ```bash
    git clone https://github.com/njuwfang/DifferentiableQPL && cd DifferentiableQPL
    ```
3. Install the Python package `pqwhile` *(In step 1, the user should already have `pip` available)*.
    ```bash
    pip install dist/pqwhile-0.1.0.tar.gz
    ```

## Differentiating Parameterized Quantum While-Programs ##

The Python package `qpwhile` provide a command `pqwhile` to generate Q# programs that are consistent with the behavior of parameterized quantum-while programs and their differential programs.

The user can run `pqwhile -h` in terminal for usage.

For the simplest usage, run `pqwhile a.qprog` for a text file `a.qprog`, which contains a parameterized quantum while-program, can generate a Q# file `Operation.qs`. 

The output Q# file includes the original program, Q# operation `sample_qprog`, and differential programs, Q# operation `sample_dqprog_*`. It also provides a Q# operation, `gradient_qprog`, for evaluating gradient. They all provide the same interface.
```python
import qsharp
from Gradient import gradient_qprog

sample_num = ... # integer number
parameters = ... # (number_of_params,)-numpy array
observable = ... # (dimension_of_state,)-numpy array 

# evaluate gradient
gradient = gradient_qprog(SAMPLE_NUM=sample_num, PARAMETERS=parameters, OBSERVABLE=observable)
```

## Experiments (Artifact Evaluations) ##

Since `pqwhile` generate Q# programs for evaluating gradients of parameterized quantum-programs, we can train a parameterized quantum-program with the help of the IQ# kernel.

The following part present the case studies in the paper *Differentiable quantum programming language with unbounded loops*.

All experiment codes are placed in the directory `experiments`, where we provide a python script `FindParams.py` for facilitating the user to demonstrate the experiments.

With the help of `FindParams.py`, we have a unified process for each experiment.
1. First, cd to `experiments`. For one of the experiments, e.g., *Quantum Walk with Parameterized Shift Operator*, copy the `Operation.qs` file and `config.py` file in `QuantumWalk` directory to current directory.
    ```bash
    cd experiments && cp QuantumWalk/Operation.qs QuantumWalk/config.py ./
    ```
    We provide `Operation.qs` for each experiment, while the user can use `pqwhile` to generate `Operation.qs` from the original parameterized quantum while-program file with suffix `.qprog`, e.g., run `pqwhile QuantumWalk/walk.qprog -d 2`. 
2. Run the script `FindParams.py`.
    ```bash
    python FindParams.py
    ``` 

### Parameterized Amplitude Amplification ###

For the experiment of *Parameterized Amplitude Amplification*, there is an additional parameter that needs to be given for determining the probability `p` in the paper.

To see the training process, cd to `experiments` and copy the `Operation.qs` file and `config.py` file to current directory.
```bash
cd experiments && cp ParameterizedAA/Operation.qs ParameterizedAA/config.py ./
```
Or, the user can run `pqwhile ParameterizedAA/grover.py -d 1` (1 parameter needed to be optimize) to generate `Operation.qs`.

Then, run the script `FindParams.py` with an integer number `n` for probability `1/n^2`, e.g.,
```bash
python FindParams.py 10
```

For Table 1 in the paper, the user need to run the script `experiment/ParameterizedAA/PrintResult.py` for `p = 1/10^2, 1/15^2, ..., 1/30^2` with the parameters listed below.


|Probability |Ours| B | C|
|---|---|---|---|
|1/10^2| 2.8684| 1.2870| 3.3568|
|1/15^2| 2.3079| 1.0446| 2.7980|
|1/20^2| 1.9617| 0.9021| 2.4488|
|1/25^2| 1.9205| 0.8054| 2.2043|
|1/30^2| 1.6814| 0.7344| 2.0209|

For example, the following command
```bash
python experiment/ParameterizedAA/PrintResult.py 10 2.8684 1.2870 3.3568
```
will evaluate the first row of Table 1.

### Quantum Walk with Parameterized Shift Operator ###

To see the training process, cd to `experiments` and copy the `Operation.qs` file and `config.py` file to current directory.
```bash
cd experiments && cp QuantumWalk/Operation.qs QuantumWalk/config.py ./
```
Or, the user can run `pqwhile QuantumWalk/walk.py -d 2` (2 parameter needed to be optimized) to generate `Operation.qs`.

Then, run the script `FindParams.py`.
```bash
python FindParams.py
```

For Figure 6 in the paper, script `FindParams.py` will save the training log in a file `training_log.npy`. The user can use this log file to evaluate the MSE distance mentioned in the paper to see wether it matches the figure.

(We also provide a script `PrintMSE.py` in `experiments` for the user, just run `python PrintMSE.py`)

### Repeat-Until-Success Unitary Implementation ###

To see the training process, cd to `experiments` and copy the `Operation.qs` file and `config.py` file to current directory.
```bash
cd experiments && cp RUSUnitary/Operation.qs RUSUnitary/config.py ./
```
Or, the user can run `pqwhile RUSUnitary/rus.py -d 3` (3 parameter needed to be optimized) to generate `Operation.qs`.

Then, run the script `FindParams.py`.
```bash
python FindParams.py
```
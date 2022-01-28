import numpy as np
import random

print('\nFinding the optimal parameter for RUS')
print('=====================================')

GSAMPLE_NUM = 15300
SAMPLE_NUM = GSAMPLE_NUM * 2
MAX_STEPS = 100
PARAMS_NUM = 3
PARAMS_SCALE = 1
INPUT_NUM = 8

# Observable on qubit variables
OO = [0.] * (2**2)
#for j in range(2**1):
for k in range(2**1):
    OO[k*2 + 0] = 1. 

# params of 4 states, information-complete basis
is1 = [0., 0.5*np.pi, np.pi, 0.]
is2 = [0., 0., 0., 0.5*np.pi]

# parameters for U1, U2, randomly generated
random_params = np.array([random.random() * np.pi * 2 for j in range(6)])

INIT_PARAMS = np.array([random.random() * np.pi * 2 for j in range(3)])


# Setting of Adam
BETA1=0.9
BETA2=0.999
ALPHA=0.2
SIGN=-1

def loss(f, df, x):
    n = len(is1)
    fs = np.zeros([n])
    dfs = np.zeros([n, PARAMS_NUM])
    for j in range(n):
        fs[j] = f(np.block([x, random_params, np.array(is1[j], is2[j])]))
        dfs[j] = df(np.block([x, random_params, np.array(is1[j], is2[j])]))[0:PARAMS_NUM]
    return np.sum((fs - 1) * (fs - 1)) / n, (fs - 1) @ dfs * 2./n
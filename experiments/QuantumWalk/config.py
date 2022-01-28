import numpy as np
import random

print('\nFinding the optimal parameter for quantum walk')
print('==============================================')

SAMPLE_NUM = 20000
MAX_STEPS = 100
PARAMS_NUM = 2
PARAMS_SCALE = 1
INPUT_NUM = 1
n = 4

# Observable on qubit variables
OO = [1. / 4] * (2**6)

INIT_PARAMS = np.array([(0.8 * random.random()+0.1) * np.pi * 2 for j in range(2)])

# Setting of Adam
BETA1=0.9
BETA2=0.999
ALPHA=0.1
SIGN=-1

def loss(f, df, x):
    x = np.block([x, np.array([n])])
    return f(x), df(x)[0:PARAMS_NUM]
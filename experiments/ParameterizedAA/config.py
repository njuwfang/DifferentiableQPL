import sys
import numpy as np
import random
import math

N = float(sys.argv[1])
a = 2. * math.asin(1./N)
n = 4 * N
t = 2 * math.acos((1-math.sin(a))/(1+math.sin(a)))

print('\nFinding the optimal AA parameter for p = 1/%d^2'%(N))
print('===============================================')

GSAMPLE_NUM = 5000 * N
SAMPLE_NUM = GSAMPLE_NUM / 2
MAX_STEPS = 100
PARAMS_NUM = 1
PARAMS_SCALE = 2
INPUT_NUM = 2

# Observable on qubit variables
OO = [0.] * (2**2)
for j in range(2**2):
    OO[j] = 1./n

INIT_PARAMS = np.array([t])

# Setting of Adam
BETA1=0.9
BETA2=0.99
ALPHA=0.1
SIGN=-1

def loss(f, df, x):
    x = np.block([x, np.array([a, n])])
    return f(x), df(x)[0:PARAMS_NUM]
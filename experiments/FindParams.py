import time
import Adam
import numpy as np

import qsharp
from Gradient import gradient_qprog, sample_qprog

from config import *

step = -1
params = INIT_PARAMS
opt = Adam.Adam(beta1=BETA1, beta2=BETA2, alpha=ALPHA, sign=SIGN)
log = np.zeros([1 + PARAMS_NUM, MAX_STEPS])

def f(x):
    return np.array(sample_qprog(SAMPLE_NUM=SAMPLE_NUM, PARAMETERS=x, OBSERVABLE=OO))

def df(x):
    return np.array(gradient_qprog(SAMPLE_NUM=GSAMPLE_NUM, PARAMETERS=x, OBSERVABLE=OO))


while step < MAX_STEPS - 1:
    tstart = time.time()

    if step >= 0:
        params = params + opt(gradient)
    
    if step > 0:
        if (SIGN == -1 and opt_obj > obj) or (SIGN == 1 and opt_obj < obj):
            opt_obj = obj
            opt_params = params
    elif step == 0:
        opt_obj = obj
        opt_params = params


    step += 1
    print('------------')
    print('Iteration %d'%(step))

    obj, gradient = loss(f, df, params)
    log[0, step] = obj
    for j in range(PARAMS_NUM):
        log[j+1, step] = params[j]

    print(f'parameters = {PARAMS_SCALE * params}')
    print(f'obj = {obj}')
    print(f'gradient = {gradient / PARAMS_SCALE}')
    print(f'elapsed time: {time.time() - tstart:.2f}s')

    if np.sqrt(sum(gradient * gradient)) < 1e-4:
        break

print(f'optimal params:{PARAMS_SCALE * opt_params}\noptimal obj:{opt_obj}')
np.save('training_log', log[:,0:step+1])
print('The log of training is saved in training_log.npy')
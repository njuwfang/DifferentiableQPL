import numpy as np

log = np.load('training_log.npy')
log = np.power(log[1:] - np.pi, 2)

mse = (log[0] + log[1]) / 2

print(mse)
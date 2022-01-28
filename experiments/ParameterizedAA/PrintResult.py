import qsharp
import math
import numpy as np
from Gradient import sample_qprog, sample2_qprog
import sys

# parameter:
# p Ours B C
# 1/10^2 2.8684 1.2870 3.3568
# 1/15^2 2.3079 1.0446 2.7980
# 1/20^2 1.9617 0.9021 2.4488
# 1/25^2 1.9205 0.8054 2.2043
# 1/30^2 1.6814 0.7344 2.0209

N = int(sys.argv[1])
t = map(lambda x:float(x)/2., sys.argv[2:])

print(f'Evaluate 4<O_1> and Var(O_1) with probability p = 1/{N}^2')

# Observable O
O = [0.] * (2**2)
for j in range(2**1):
    O[2 + j] = (1./N/4)

SAMPLE_NUM = 10000

a = 2. * math.asin(1./N)
n = N * 4

for tt in t:
    obj = np.array(sample_qprog(SAMPLE_NUM=SAMPLE_NUM, PARAMETERS=np.array([tt,a,n]), OBSERVABLE=np.array(O)))

    obj2 = np.array(sample2_qprog(SAMPLE_NUM=SAMPLE_NUM, PARAMETERS=np.array([tt,a,n]), OBSERVABLE=np.power(np.array(O), 2)))

    print(f'When parameter t = {2 * tt:.4f}, 4<O_1> = {4 * obj:.5f}, Var(O_1) = {obj2 - obj**2:.5f}')
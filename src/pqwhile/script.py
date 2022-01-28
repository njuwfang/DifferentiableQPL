from ast import arg
from pqwhile import parse2qsharp
import argparse

def main():
    parser = argparse.ArgumentParser(description='A parser for parameterized quantum while-language.')
    parser.add_argument(
        'pqwhile_file',
        type=str,
        help='Parameterized quantum while-program file to read.'
    )
    parser.add_argument(
        '--outfile', '-o',
        type=str,
        default='Operation.qs',
        help='Output Q# file to write.\nDefault: Operation.qs'
    )
    parser.add_argument(
        '--name', '-n',
        type=str,
        default='qprog',
        help='Name for operation in output Q# file. Default: qprog'
    )
    parser.add_argument(
        '--method', '-m',
        type=str,
        default='commutator',
        help='Differentiation method for Single-Occurrence of Parameter.\nDefault: commutator'
    )
    parser.add_argument(
        '--para_mu', '-p',
        type=float,
        default=0.25,
        help='Parameter for distribution. Default: 0.25'
    )
    parser.add_argument(
        '--diff_num', '-d',
        type=int,
        default='-1',
        help='Specify the first DIFF_NUM paramters to perform differentiation. Default: -1, for all parameters'
    )
    args = parser.parse_args()
    with open(args.pqwhile_file, 'r') as qprog_file:
        qprog = qprog_file.read()
        parse2qsharp(qprog, args.outfile, args.name, args.method, args.para_mu, args.diff_num)
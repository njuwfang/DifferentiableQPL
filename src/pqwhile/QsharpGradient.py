from .OriginalParser import parser as originalparser
from .DifferentialParser import parser as differentialparser

def parse(qprog, qsharpstr='Operation.qs', namestr='qprog', method='commutator', diff_num=-1):
    with open(qsharpstr, 'w') as qsharp_file:
        preamble_code = 'namespace Gradient {\n'
        preamble_code += '  open Microsoft.Quantum.Canon;\n'
        preamble_code += '  open Microsoft.Quantum.Intrinsic;\n'
        preamble_code += '  open Microsoft.Quantum.Math;\n'
        preamble_code += '  open Microsoft.Quantum.Convert;\n'
        preamble_code += '  open Microsoft.Quantum.Measurement;\n'
        preamble_code += '  open Microsoft.Quantum.Arrays;\n'

        print(preamble_code, file = qsharp_file)
        a = originalparser(namestr)
        (original_code, params) = a.parse(qprog)

        print('  %s'%(original_code.replace('\n', '\n  ')), file = qsharp_file)

        if diff_num < 0:
            diff_num = len(params)
        diff_num = min(diff_num, len(params))

        for j in range(diff_num):
            b = differentialparser(params[j], 'pd%s_%s'%(namestr, params[j]), method)
            print('\n  %s'%(b.parse(qprog).replace('\n', '\n  ')), file = qsharp_file)
    
        gradient_code = '\n  operation gradient_%s(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double[] {\n'%(namestr)
        gradient_code += '    mutable g = new Double[%s];\n'%(len(params))

        for j in range(diff_num):
            gradient_code += '    set g w/= %s <- sample_pd%s_%s(SAMPLE_NUM, PARAMETERS, OBSERVABLE);\n'%(j, namestr, params[j])
        gradient_code += '    for j in %s..%s {\n      set g w/= j <- 0.;\n    }\n'%(diff_num, len(params)-1)
        gradient_code += '    return g;\n  }'

        print(gradient_code, file = qsharp_file)
        print('}', file = qsharp_file)
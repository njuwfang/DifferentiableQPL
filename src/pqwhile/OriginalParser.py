import ply.yacc as yacc

def parser(namestr='qprog'):
    from .QwhileLexer import tokens

    precedence = (
        ('left', 'AND', 'OR', 'CMA', 'SCN'),
    )

    def p_qsharp(p):
        'qsharp : qprog'
        
        # qsharp operation for pqwhile program
        pqwhile_prog = 'operation %s(PARAMETERS: Double[]): (Result[], Double[]) {\n  %s\n}'%(
            namestr, p[1][0].replace('\n', '\n  ')
        )

        # qsharp operation for sampling pqwhile program
        sample_body = 'mutable sum = 0.;\nfor j in 1..SAMPLE_NUM {\n'
        sample_body += '  let (temp, c) = %s(PARAMETERS);\n'%(namestr)
        sample_body += '  set sum += c[0] * OBSERVABLE[ResultArrayAsInt(temp)];\n}\n' # there we only use c[0]
        sample_body += 'return sum / IntAsDouble(SAMPLE_NUM);'
        sample_prog = 'operation sample_%s(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {\n  %s\n}'%(
            namestr, sample_body.replace('\n', '\n  ')
        )

        p[0] = ('%s\n\n%s'%(pqwhile_prog, sample_prog), p[1][1])

    def p_qprog(p):
        '''qprog    : qenv program
                    | qenv penv program
                    | qenv penv cenv program'''
        p[0] = ''

        # Bind parameters
        if len(p) > 3:
            for j in range(len(p[2])):
                p[0] += 'let %s = PARAMETERS[%d];\n'%(p[2][j], j)
        
        # Bind qubit variables
        p[0] += 'use qubits = Qubit[%d] {\n'%(len(p[1]))
        for j in range(len(p[1])):
            p[0] += '  let %s = qubits[%d];\n'%(p[1][j], j)

        # Initialize counting variables
        if len(p) > 4:
            for j in range(len(p[3])):
                p[0] += '  mutable %s = 0.;\n'%(p[3][j])

        # Add program body
        p[0] += '  %s'%(p[len(p)-1].replace('\n', '\n  '))

        # Outcomes of measurement
        p[0] += '\n  let all_result = MultiM(qubits);\n  ResetAll(qubits);\n'
        # Outcomes of counting variables
        if len(p) > 4:
            p[0] += '  let all_count = [%s%s];\n'%(
                p[3][0], ''.join(map(lambda x: ', %s'%(x), p[3][1:]))
            )
        else:
            p[0] += '  let all_count = [1.];\n'

        p[0] += '  return (all_result, all_count);\n}'

        # Return program body and all differentiable parameters
        if len(p) > 3:
            p[0] = (p[0], p[2])
        else:
            p[0] = (p[0], [])

    # variables for counting
    def p_cenv(p):
        '''cenv : COUNT COLON QID
                | cenv CMA QID'''
        if p[2] == ':':
            p[0] = [p[3]]
        else:
            p[0] = p[1] + [p[3]]

    # qubit variables
    def p_qenv(p):
        '''qenv : QUBIT COLON QID
                | qenv CMA QID'''
        if p[2] == ':':
            p[0] = [p[3]]
        else:
            p[0] = p[1] + [p[3]]

    # parameters
    def p_penv(p):
        '''penv : PARA COLON QID
                | penv CMA QID'''
        if p[2] == ':':
            p[0] = [p[3]]
        else:
            p[0] = p[1] + [p[3]]

    # Syntax for pqwhile
    def p_program(p):
        '''program  : SK
                    | IN
                    | UT
                    | UTP
                    | SC
                    | IFm
                    | LP
                    | CPLUS'''
        p[0] = p[1]

    # Skip, skip
    def p_SK(p):
        'SK : SKIP'
        p[0] = ''

    # Initialize, q := |0>
    def p_IN(p):
        'IN : QID ASS KET0'
        p[0] = 'if (M(%s) == One) { X(%s);}'%(p[1], p[1])

    # Unitary transformation, U[q1,q2,...,qn], C_U[q1,...,qn][r1,...,rm]
    def p_UT(p):
        '''UT   : ut0 qvar
                | utc qvar qvar'''
        if len(p) == 3:
            p[0] = '%s(%s);'%(p[1], p[2])
        else:
            p[0] = '%s([%s], %s);'%(p[1], p[2], p[3])

    # Parameterized unitary transformation, U(t)[q1,...,qn], C_U(t)[q1,...,qn][r1,...,rm]
    def p_UTP(p):
        '''UTP  : utp0 LBC QID RBC qvar
                | utpc LBC QID RBC qvar qvar'''
        if len(p) == 6:
            p[0] = '%s(%s, %s);'%(p[1], p[3], p[5])
        else:
            p[0] = '%s([%s], (%s, %s));'%(p[1], p[5], p[3], p[6])

    # Sequence, P1;P2
    def p_SC(p):
        'SC : program SCN program'
        p[0] = '%s\n%s'%(p[1], p[3])

    # (Measurement) if, if B then P1 else P2 fi
    def p_IFm(p):
        'IFm : IF bool THEN program ELSE program FI'
        p[0] = 'if (%s) {\n  %s\n} else {\n  %s\n}'%(
            p[2], p[4].replace('\n', '\n  '), p[6].replace('\n', '\n  ')
        )

    # (Measurement) while, while B do P od
    def p_LP(p):
        'LP : WHILE bool DO program OD'
        p[0] = 'repeat {}\nuntil (not %s)\nfixup {\n  %s\n}'%(
            p[2], p[4].replace('\n', '\n  ')
        )

    # +1 for counting variables, c++
    def p_CPLUS(p):
        'CPLUS : QID PLUS'
        p[0] = 'set %s += 1.;'%(p[1])

    def p_bool(p):
        '''bool : MEAS LB QID RB EQS ZERO
                | MEAS LB QID RB EQS ONE
                | QID LEQ QID
                | QID LE QID
                | bool AND bool
                | bool OR bool'''
        if p[1] == 'M':
            p[0] = '(M(%s) == %s)'%(p[3], 'Zero' if p[6] == 0 else 'One')
        else:
            p[0] = '(%s %s %s)'%(p[1], p[2], p[3])

    # Unitary
    def p_ut0(p):
        '''ut0  : H
                | CNOT
                | X
                | Y
                | Z'''
        p[0] = p[1]

    # Controlled unitary
    def p_utc(p):
        'utc : CONTROLLED ut0'
        p[0] = 'Controlled %s'%(p[2])

    # Parameterized unitary
    def p_utp0(p):
        '''utp0 : RX
                | RY
                | RZ'''
        p[0] = p[1]

    # Controlled parameterized unitary
    def p_utpc(p):
        'utpc : CONTROLLED utp0'
        p[0] = 'Controlled %s'%(p[2])

    # Qubit variables
    def p_qvar(p):
        'qvar : LB QIDS RB'
        p[0] = p[2]

    def p_qids(p):
        '''QIDS : QID
                | QIDS CMA QID'''
        if len(p) == 2:
            p[0] = p[1]
        else:
            p[0] = p[1] + p[2] + p[3]

    # Handle Syntax Error
    def p_error(p):
        if p:
            print("Syntax error at Line", p.lineno)
        else:
            print("Syntax error at EOF")


    return yacc.yacc()

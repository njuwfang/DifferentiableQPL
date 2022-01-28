import ply.yacc as yacc
import mpmath as mp

def parser(pvar, namestr='dqprog', method='commutator', mu_para=0.25):
    from .QwhileLexer import tokens

    mu = lambda x: 1./x/mp.log(x+mp.exp(1))**(1+mu_para)
    mu_sum = mp.nsum(mu, [1, mp.inf]) * 1.01
    alpha = 'PI() / 4.'

    precedence = (
        ('left', 'SCN', 'AND', 'OR', 'CMA'),
    )

    def p_qsharp(p):
        'qsharp : qprog'
        
        # qsharp operation for differential pqwhile program
        pqwhile_prog = 'operation %s(PARAMETERS: Double[]): (Result[], Double[], Double) {\n  %s\n}'%(
            namestr, p[1].replace('\n', '\n  ')
        )

        # qsharp operation for sampling differential pqwhile program
        sample_body = 'mutable sum = 0.;\nfor j in 1..SAMPLE_NUM {\n'
        sample_body += '  let (temp, c, frac) = %s(PARAMETERS);\n'%(namestr)
        sample_body += '  set sum += c[0] * frac * OBSERVABLE[ResultArrayAsInt(temp)];\n}\n' # there we only use c[0]
        sample_body += 'return sum / IntAsDouble(SAMPLE_NUM);'
        sample_prog = 'operation sample_%s(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {\n  %s\n}'%(
            namestr, sample_body.replace('\n', '\n  ')
        )

        p[0] = '%s\n\n%s'%(pqwhile_prog, sample_prog)

    def p_qprog(p):
        '''qprog    : qenv program
                    | qenv penv program
                    | qenv penv cenv program'''
        p[0] = ''

        # Introduce extra variables for differetial program
        qa = '%s_qa'%(pvar)
        q1 = '%s_q1'%(pvar)
        q2 = '%s_q2'%(pvar)
        qac = '%s_qac'%(pvar)
        qalpha = '%s_alpha'%(pvar)
        qnum = len(p[1])
        if method == 'commutator':
            p[1] += [qa, q1, q2, qac]
        elif method == 'phaseshift':
            p[1] += [q1, q2]
        else:
            raise Exception('unsupported method %s'%(method))

        # Bind parameters
        if len(p) > 3:
            for j in range(len(p[2])):
                p[0] += 'let %s = PARAMETERS[%d];\n'%(p[2][j], j)
            if method == 'commutator':
                p[0] += 'mutable %s = %s;\n'%(qalpha, alpha)
        
        # Bind qubit variables
        p[0] += 'use qubits = Qubit[%d] {\n'%(len(p[1]))
        for j in range(len(p[1])):
            p[0] += '  let %s = qubits[%d];\n'%(p[1][j], j)

        # Initialize counting variables
        if len(p) > 4:
            for j in range(len(p[3])):
                p[0] += '  mutable %s = 0.;\n'%(p[3][j])

        # Initialize extra variables
        if method == 'commutator':
            p[0] += '  if (M(%s) == One) { X(%s);}\n'%(qa, qa)
        p[0] += '  if (M(%s) == One) { X(%s);}\n'%(q1, q1)
        p[0] += '  if (M(%s) == One) { X(%s);}\n'%(q2, q2)
        c = pvar + '_c'
        ps = pvar + '_ps'
        s = pvar + '_s'
        a = pvar + '_a'
        flag = pvar + '_flag'
        m = pvar + '_m'
        p[0] += '  mutable %s = 1.;\n'%(flag)
        p[0] += '  mutable %s = 1.;\n'%(c)
        p[0] += '  mutable %s = 0.;\n'%(ps)
        p[0] += '  let %s = %f;\n'%(s, mu_sum)
        p[0] += '  let %s = %f;\n'%(m, mu_para)
        p[0] += '  mutable %s = 2. * ArcSin(Sqrt(1. / (%s - %s) / %s / PowD(Log(%s+E()), 1.+%s)));\n'%(
            a, s, ps, c, c, m
        )
        p[0] += '  Ry(%s, %s);\n'%(a, q2)

        # Add program body
        p[0] += '  %s'%(p[len(p)-1].replace('\n', '\n  '))

        # Outcomes of measurement
        p[0] += '\n  let result_%s = M(%s);'%(q1, q1) # whether the differentiation is performed
        p[0] += '\n  let all_result = MultiM(qubits[...%d]);\n  ResetAll(qubits);\n'%(qnum-1)
        # Outcomes of counting variables
        if len(p) > 4:
            p[0] += '  let all_count = [%s%s];\n'%(
                p[3][0], ''.join(map(lambda x: ', %s'%(x), p[3][1:]))
            )
        else:
            p[0] += '  let all_count = [1.];\n'

        p[0] += '  if (result_%s == One) {\n'%(q1) # # whether the differentiation is performed
        p[0] += '    return (all_result, all_count,'
        p[0] += ' %s * %s * PowD(Log(%s+E()), 1.+%s) * %s);\n  } else {\n'%(
            flag, c, c, m, s
        )
        p[0] += '    return (all_result, all_count, 0.);\n  }\n}'

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
        p[0] = ''
        # Apply code transformation for AD
        if p[3] == pvar:
            q1 = '%s_q1'%(pvar)
            q2 = '%s_q2'%(pvar)
            qa = '%s_qa'%(pvar)
            qac = '%s_qac'%(pvar)
            qalpha = '%s_alpha'%(pvar)
            c = '%s_c'%(pvar)
            ps = '%s_ps'%(pvar)
            s = '%s_s'%(pvar)
            a = '%s_a'%(pvar)
            flag = '%s_flag'%(pvar)
            m = '%s_m'%(pvar)
            p[0] += 'if (M(%s) == Zero) {\n  if (M(%s) == Zero) {\n'%(q1, q2)
            p[0] += '    set %s += 1. / %s / PowD(Log(%s+E()), 1.+%s);\n'%(ps, c, c, m)
            p[0] += '    set %s += 1.;\n'%(c)
            p[0] += '    set %s = 2. * ArcSin(Sqrt(1. / (%s - %s) / %s / PowD(Log(%s+E()), 1.+%s)));\n'%(a, s, ps, c, c, m)
            p[0] += '    Ry(%s, %s);\n  } else {\n'%(a, q2)
            p[0] += '    X(%s);\n'%(q1)
            if method == 'commutator':
                p[0] += '    set %s = 2. / Sin(2. * %s);\n'%(flag, qalpha)
                p[0] += '    H(%s);\n'%(q2)
                p[0] += '    if (M(%s) == One) { set  %s = -%s; set %s = -%s; X(%s);}\n'%(q2, qalpha, qalpha, flag, flag, q2)
                p[0] += '    if (M(%s) == One) { X(%s);}\n'%(qa, qa)
                if len(p) == 6:
                    if p[1] == 'Rx':
                        p[0] += '    H(%s);\n'%(qa)
                    elif p[1] == 'Ry':
                        p[0] += '    H(%s);\nS(%s);\n'%(qa, qa)
                    p[0] += '    CNOT(%s, %s);\n'%(p[5], qa)
                    p[0] += '    Controlled H([%s], %s);\n'%(qa, p[5])
                    p[0] += '    Controlled Rz([%s, %s], (-4. * %s, %s));\n'%(p[5], qa, qalpha, qac)
                    p[0] += '    Controlled H([%s], %s);\n'%(qa, p[5])
                    p[0] += '    CNOT(%s, %s);\n'%(p[5], qa)
                else:
                    if p[1] == 'Controlled Rx':
                        p[0] += '    H(%s);\n'%(q2)
                        p[0] += '    if (M(%s) == Zero) { H(%s);if (M(%s) == Zero) {}}\n'%(q2, qa, qa)
                        p[0] += '    else { H(%s);}\n'%(qa)
                    elif p[1] == 'Controlled Ry':
                        p[0] += '    H(%s);\n'%(q2)
                        p[0] += '    if (M(%s) == Zero) { H(%s);if (M(%s) == Zero) {}}\n'%(q2, qa, qa)
                        p[0] += '    else { H(%s);S(%s);}\n'%(qa, qa)
                    elif p[1] == 'Controlled Rz':
                        p[0] += '    H(%s);\n'%(q2)
                        p[0] += '    if (M(%s) == Zero) { H(%s);if (M(%s) == Zero) {}}\n'%(q2, qa, qa)
                    p[0] += '    CNOT(%s, %s);\n'%(p[5], q2)
                    p[0] += '    CNOT(%s, %s);\n'%(p[6], qa)
                    p[0] += '    Controlled H([%s], %s);\n'%(q2, p[5])
                    p[0] += '    Controlled H([%s], %s);\n'%(qa, p[6])
                    p[0] += '    X(%s);X(%s);\n'%(p[5], q2)
                    p[0] += '    Controlled Rz([%s,%s, %s, %s], (-4. * %s, %s));\n'%(p[5], q2, p[6], qa, qalpha, qac)
                    p[0] += '    X(%s);\n'%(p[5])
                    p[0] += '    Controlled Rz([%s,%s, %s, %s], (-4. * %s, %s));\n'%(p[5], q2, p[6], qa, qalpha, qac)
                    p[0] += '    X(%s);X(%s);\n'%(q2, p[5])
                    p[0] += '    Controlled Rz([%s,%s, %s, %s], (-4. * %s, %s));\n'%(p[5], q2, p[6], qa, qalpha, qac)
                    p[0] += '    X(%s);X(%s);X(%s);\n'%(p[5], p[6], qa)
                    p[0] += '    Controlled Rz([%s,%s, %s, %s], (-4. * %s, %s));\n'%(p[5], q2, p[6], qa, qalpha, qac)
                    p[0] += '    X(%s);\n'%(p[6])
                    p[0] += '    Controlled Rz([%s,%s, %s, %s], (-4. * %s, %s));\n'%(p[5], q2, p[6], qa, qalpha, qac)
                    p[0] += '    X(%s);X(%s);\n'%(qa, p[6])
                    p[0] += '    Controlled Rz([%s,%s, %s, %s], (-4. * %s, %s));\n'%(p[5], q2, p[6], qa, qalpha, qac)
                    p[0] += '    X(%s);\n'%(p[6])
                    p[0] += '    Controlled H([%s], %s);\n'%(qa, p[6])
                    p[0] += '    Controlled H([%s], %s);\n'%(q2, p[5])
                    p[0] += '    CNOT(%s, %s);\n'%(p[6], qa)
                    p[0] += '    CNOT(%s, %s);\n'%(p[5], q2)
                    p[0] += '    set %s = 2. * %s;\n'%(flag, flag)
            elif method == 'phaseshift':
                p[0] += '    H(%s);\n'%(q2)
                if len(p) == 6:
                    p[0] += '    if (M(%s) == Zero) { %s(PI() / 2., %s);}\n'%(q2, p[1], p[5])
                    p[0] += '    else { %s(-PI() / 2., %s); set %s = -1.;}\n'%(p[1], p[5], flag)
                else:
                    p[0] += '    if (M(%s) == Zero) {\n'%(q2)
                    p[0] += '      H(%s);\n'%(q2)
                    p[0] += '      if (M(%s) == Zero) { %s([%s], (PI() / 2., %s)); set %s = 2.;}\n'%(q2, p[1], p[5], p[6], flag)
                    p[0] += '      else { %s([%s], (-PI() / 2., %s)); set %s = -2.;}\n'%(p[1], p[5], p[6], flag)
                    p[0] += '    } else {\n'
                    p[0] += '      H(%s);\n'%(q2)
                    p[0] += '      if (M(%s) == Zero) { %s([%s], (PI(), %s)); set %s = 1.0-1.0*Sqrt(2.);}\n'%(q2, p[1], p[5], p[6], flag)
                    p[0] += '      else { %s([%s], (-PI(), %s)); set %s = 1.0*Sqrt(2.)-1.0;}\n    }\n'%(p[1], p[5], p[6], flag)
            else:
                raise Exception('unsupported method %s'%(method))
            p[0] += '  }\n}\n'
        # Append the original operation
        if len(p) == 6:
            p[0] += '%s(%s, %s);'%(p[1], p[3], p[5])
        else:
            p[0] += '%s([%s], (%s, %s));'%(p[1], p[5], p[3], p[6])

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
            p[0] = '(M(%s) == %s)'%(p[3], 'Zero' if p[6] == '0' else 'One')
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

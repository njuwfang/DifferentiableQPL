import ply.lex as lex

### Reserved words
reserved = {
    ### Preamble
    # classical integer variables, which are only used for counting
    'count': 'COUNT',
    # quantum qubit variables
    'qubit': 'QUBIT',
    # parameters
    'para': 'PARA',

    ### Statement 
    'skip': 'SKIP',
    'M': 'MEAS',
    'if': 'IF',
    'then': 'THEN',
    'else': 'ELSE',
    'fi': 'FI',
    'while': 'WHILE',
    'do': 'DO',
    'od': 'OD',

    ### Reserved gates
    # Fixed gates
    'H': 'H',
    'CNOT': 'CNOT',
    'X': 'X',
    'Y': 'Y',
    'Z': 'Z',
    # parameterized gates, Pauli rotations
    'Rx': 'RX',
    'Ry': 'RY',
    'Rz': 'RZ',
    
    ### Controlled-gate
    'C_': 'CONTROLLED',

    ### Logical connectives
    'and': 'AND',
    'or': 'OR',
}

### Tokens
tokens = [
    'LEQ',
    'LE',
    'PLUS',
    'COLON',
    'LBC',
    'RBC',
    'LB',
    'RB',
    'ASS',
    'EQS',
    'KET0',
    'CMA',
    'SCN',
    'ZERO',
    'ONE',
    'QID',
] + list(reserved.values())

### Rules for tokens
t_LEQ = r'\<='
t_LE = r'\<'
t_PLUS = r'\+\+'
t_COLON = r':'
t_LBC = r'\('
t_RBC = r'\)'
t_LB = r'\['
t_RB = r'\]'
t_ASS = r':='
t_EQS = r'='
t_KET0 = r'\|0>'
t_CMA = r','
t_SCN = r';'
t_ZERO = r'0'
t_ONE = r'1'
def t_QID(t):
    r'C_|[a-zA-Z\-_][a-zA-Z0-9_]*'
    t.type = reserved.get(t.value, 'QID')
    return t

t_ignore = ' \t'
t_ignore_COMMENT = r'\#.*'

### Track line numbers
def t_newline(t):
    r'\n'
    t.lexer.lineno += len(t.value)

### Handle lexing errors for illegal characters
def t_error(t):
    print("Illegal character '%s'" % t.value[0])
    t.lexer.skip(1)

lexer = lex.lex()

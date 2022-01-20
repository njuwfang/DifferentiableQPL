from setuptools import setup, find_packages

setup(
    name = 'pqwhile',
    version = '0.1.0',
    description = 'A parser for parameterized quantum while-language',
    author = 'Wang Fang',
    author_email = 'fangw@ios.ac.cn',
    url = '',
    license = '',
    package_dir={'': 'src'},
    packages = find_packages(where='src'),
    entry_points={
        'console_scripts': [
            'pqwhile=pqwhile.script:main',
        ],
    },
    install_requires = [
        'numpy',
        'ply',
        'mpmath',
    ],
)

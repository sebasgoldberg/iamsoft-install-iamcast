#! /usr/bin/python
from distutils.sysconfig import get_python_lib
"""
@todo Ojo NO se está devolviendo la ruta donde está instalado django!!!
"""
print get_python_lib()

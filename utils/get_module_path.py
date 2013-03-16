#! /usr/bin/python
# coding=utf-8
import os
import importlib
import sys

if len(sys.argv)!=2:
  raise Exception("Se debe pasar como argumento el nombre del módulo del cual se desea obtener el path")

module_name = sys.argv[1]
module = importlib.import_module(module_name)
print os.path.dirname(module.__file__)

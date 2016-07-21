# # import sys
# # import numpy
# #
# # def configuration(parent_package='', top_path=None):
# #     from numpy.distutils.misc_util import Configuration
# #
# #     config = Configuration('randomkit', parent_package, top_path)
# #     libs = []
# #     if sys.platform == 'win32':
# #         libs.append('Advapi32')
# #
# #
# #     config.add_extension('random_fast',
# #          sources=['random_fast.cpp', 'randomkit.c'],
# #          libraries=libs,
# #          include_dirs=[numpy.get_include()]
# #          )
# #
# #     config.add_subpackage('tests')
# #     config.add_data_files('random_fast.pxd')
# #     config.add_data_files('randomkit.h')
# #
# #     return configcd
# #
# # if __name__ == '__main__':
# #     from numpy.distutils.core import setup
# #     setup(**configuration(top_path='').todict())
#
#
# from distutils.core import setup
# from Cython.Build import cythonize
# import numpy as np
# from setuptools.extension import Extension
#
# extensions = [Extension("randomkit.random_fast", ["random_fast.pyx","randomkit.c"])]
# # Use cythonize on the extension object.
# setup(name="randomkit",
#       packages=["randomkit"],
#       ext_modules=cythonize(extensions),
#       include_dirs=[np.get_include()])
#

#! /usr/bin/env python
#
# Copyright (C) 2012 Mathieu Blondel

import sys
import os
import setuptools
from numpy.distutils.core import setup
from distutils.core import setup
from Cython.Build import cythonize
import numpy as np
from setuptools.extension import Extension

DISTNAME = 'sklearn-contrib-lightning'
DESCRIPTION = "Large-scale sparse linear classification, " + \
              "regression and ranking in Python"
LONG_DESCRIPTION = open('README.rst').read()
MAINTAINER = 'Mathieu Blondel'
MAINTAINER_EMAIL = 'mathieu@mblondel.org'
URL = 'https://github.com/scikit-learn-contrib/lightning'
LICENSE = 'new BSD'
DOWNLOAD_URL = 'https://github.com/scikit-learn-contrib/lightning'
VERSION = '0.4.dev0'

extensions = [
    Extension("lightning.impl.adagrad_fast", sources = ["lightning/impl/adagrad_fast.pyx"], language = "c++"),
    Extension("lightning.impl.dataset_fast", sources =["lightning/impl/dataset_fast.pyx"], language = "c++"),
    Extension("lightning.impl.dual_cd_fast", sources =["lightning/impl/dual_cd_fast.pyx"], language = "c++"),
    Extension("lightning.impl.loss_fast", sources =["lightning/impl/loss_fast.pyx"], language = "c++"),
    Extension("lightning.impl.prank_fast", sources =["lightning/impl/prank_fast.pyx"], language = "c++"),
    Extension("lightning.impl.primal_cd_fast", sources =["lightning/impl/primal_cd_fast.pyx"], language = "c++"),
    Extension("lightning.impl.prox_fast", sources =["lightning/impl/prox_fast.pyx"], language = "c++"),
    Extension("lightning.impl.sag_fast", sources =["lightning/impl/sag_fast.pyx"], language = "c++"),
    Extension("lightning.impl.sdca_fast", sources =["lightning/impl/sdca_fast.pyx"], language = "c++"),
    Extension("lightning.impl.sgd_fast", sources =["lightning/impl/sgd_fast.pyx"], language = "c++"),
    Extension("lightning.impl.svrg_fast", sources =["lightning/impl/svrg_fast.pyx"], language = "c++"),
    Extension("lightning.impl.randomkit.random_fast", sources =["lightning/impl/randomkit/random_fast.pyx",
                                                       "lightning/impl/randomkit/randomkit.c"], language = "c++")
    ]





# config.add_subpackage('datasets')
# config.add_subpackage('randomkit')
# config.add_subpackage('tests')




# config.add_extension('adagrad_fast',
#                      sources=['adagrad_fast.cpp'],
#                      include_dirs=[numpy.get_include(), randomdir])
#
# config.add_extension('dataset_fast',
#                      sources=['dataset_fast.cpp'],
#                      include_dirs=[numpy.get_include(), randomdir])

# config.add_extension('dual_cd_fast',
#                      sources=['dual_cd_fast.cpp'],
#                      include_dirs=[numpy.get_include(), randomdir])
#
# config.add_extension('loss_fast',
#                      sources=['loss_fast.cpp'],
#                      include_dirs=[numpy.get_include(), randomdir])

# config.add_extension('prank_fast',
#                      sources=['prank_fast.cpp'],
#                      include_dirs=[numpy.get_include(), randomdir])
#
# config.add_extension('primal_cd_fast',
#                      sources=['primal_cd_fast.cpp'],
#                      include_dirs=[numpy.get_include(), randomdir])
#
# config.add_extension('prox_fast',
#                      sources=['prox_fast.cpp'],
#                      include_dirs=[numpy.get_include(), randomdir])
#
# config.add_extension('sag_fast',
#                      sources=['sag_fast.cpp'],
#                      include_dirs=[numpy.get_include(), randomdir])
#
# config.add_extension('sdca_fast',
#                      sources=['sdca_fast.cpp'],
#                      include_dirs=[numpy.get_include(), randomdir])
#
# config.add_extension('sgd_fast',
#                      sources=['sgd_fast.cpp'],
#                      include_dirs=[numpy.get_include(), randomdir])
#
# config.add_extension('svrg_fast',
#                      sources=['svrg_fast.cpp'],
#                      include_dirs=[numpy.get_include(), randomdir])

# config.add_subpackage('datasets')
# config.add_subpackage('randomkit')
# config.add_subpackage('tests')
#
# # add .pxd files to be re-used by third party software
# config.add_data_files('sag_fast.pxd', 'dataset_fast.pxd',
#                       'sgd_fast.pxd', 'prox_fast.pxd')
#




























def configuration(parent_package='', top_path=None):
    if os.path.exists('MANIFEST'):
        os.remove('MANIFEST')

    from numpy.distutils.misc_util import Configuration
    config = Configuration(None, parent_package, top_path)

    config.add_subpackage('lightning')

    return config

if __name__ == "__main__":

    old_path = os.getcwd()
    local_path = os.path.dirname(os.path.abspath(sys.argv[0]))

    os.chdir(local_path)
    sys.path.insert(0, local_path)
    #
    # setup(name="lightning",
    #       packages=["lightning", "lightning.impl", "lightning.impl.randomkit", "lightning.impl.tests",
    #                 "lightning.impl.tests"],
    #       ext_modules=cythonize(extensions),
    #       include_dirs=[np.get_include()])
    print old_path+r"\lightning\impl\randomkit"

    setup(
          name=DISTNAME,
          maintainer=MAINTAINER,
          # include_package_data=True,
          scripts=["bin/lightning_train",
                   "bin/lightning_predict"],
          packages=["lightning", "lightning.impl", "lightning.impl.randomkit", "lightning.impl.tests",
                    "lightning.impl.tests"],
          ext_modules=cythonize(extensions),
          include_dirs=[np.get_include(),old_path+r"lightning/impl/randomkit"],
          maintainer_email=MAINTAINER_EMAIL,
          description=DESCRIPTION,
          license=LICENSE,
          url=URL,
          version=VERSION,
          download_url=DOWNLOAD_URL,
          long_description=LONG_DESCRIPTION,
          zip_safe=False,  # the package can run out of an .egg file
          classifiers=[
              'Intended Audience :: Science/Research',
              'Intended Audience :: Developers',
              'License :: OSI Approved',
              'Programming Language :: C',
              'Programming Language :: Python',
              'Topic :: Software Development',
              'Topic :: Scientific/Engineering',
              'Operating System :: Microsoft :: Windows',
              'Operating System :: POSIX',
              'Operating System :: Unix',
              'Operating System :: MacOS'
             ]
          )

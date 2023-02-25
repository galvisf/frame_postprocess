from setuptools import setup, find_packages

setup(name='frame_postprocess',
      version='0.2',
      url='https://github.com/galvisf/frame_postprocess',
      license='MIT License',
      author='Francisco Galvis',
      author_email='galvisf@alumni.stanford.edu',
      long_description='frame_postprocess is an open-source python package that facilitates the postprocessing of seismic nonlinear response history analyses (NLRHA) of 2D OpenSees models of moment frames.',
      long_description_content_type = 'text/markdown',
      packages=find_packages(),
      include_package_data=True,
      platforms='any',
      install_requires=[
             'numpy',
             'pandas',
             'h5py',
             'matplotlib',
             'scipy',
      ],
      classifiers = [
             'Programming Language :: Python',
             'Natural Language :: English',
             'Intended Audience :: Education',
             'Intended Audience :: Science/Research',
             'License :: OSI Approved :: MIT License',
             'Topic :: Scientific/Engineering',
      ],
)
# encoding: utf-8
# cython: cdivision=True
# cython: boundscheck=False
# cython: wraparound=False
#
# Author: Mathieu Blondel
# License: BSD

from libc cimport stdlib

import numpy as np
cimport numpy as np
np.import_array()

import scipy.sparse as sp

cdef class Dataset:

    cpdef int get_n_samples(self):
        return self.n_samples

    cpdef int get_n_features(self):
        return self.n_features


cdef class RowDataset(Dataset):

    cdef void get_row_ptr(self,
                          int i,
                          int** indices,
                          double** data,
                          int* n_nz) nogil:
        pass

    cpdef get_row(self, int i):
        cdef double* data
        cdef int* indices
        cdef int n_nz
        cdef np.npy_intp shape[1]

        self.get_row_ptr(i, &indices, &data, &n_nz)

        shape[0] = <np.npy_intp> self.n_features
        indices_ = np.PyArray_SimpleNewFromData(1, shape, np.NPY_INT, indices)
        data_ = np.PyArray_SimpleNewFromData(1, shape, np.NPY_DOUBLE, data)

        return indices_, data_, n_nz


cdef class ColumnDataset(Dataset):

    cdef void get_column_ptr(self,
                             int j,
                             int** indices,
                             double** data,
                             int* n_nz) nogil:
        pass

    cpdef get_column(self, int j):
        cdef double* data
        cdef int* indices
        cdef int n_nz
        cdef np.npy_intp shape[1]

        self.get_column_ptr(j, &indices, &data, &n_nz)

        shape[0] = <np.npy_intp> self.n_samples
        indices_ = np.PyArray_SimpleNewFromData(1, shape, np.NPY_INT, indices)
        data_ = np.PyArray_SimpleNewFromData(1, shape, np.NPY_DOUBLE, data)

        return indices_, data_, n_nz


cdef class ContiguousDataset(RowDataset):

    def __init__(self, np.ndarray[double, ndim=2, mode='c'] X):
        self.n_samples = X.shape[0]
        self.n_features = X.shape[1]
        self.data = <double*> X.data
        self.X = X

    def __cinit__(self, np.ndarray[double, ndim=2, mode='c'] X):
        cdef int i
        cdef int n_features = X.shape[1]
        self.indices = <int*> stdlib.malloc(sizeof(int) * n_features)
        for j in xrange(n_features):
            self.indices[j] = j

    def __dealloc__(self):
        stdlib.free(self.indices)

    # This is used to reconstruct the object in order to make it picklable.
    def __reduce__(self):
        return (ContiguousDataset, (self.X, ))

    cdef void get_row_ptr(self,
                          int i,
                          int** indices,
                          double** data,
                          int* n_nz) nogil:
        indices[0] = self.indices
        data[0] = self.data + i * self.n_features
        n_nz[0] = self.n_features


cdef class FortranDataset(ColumnDataset):

    def __init__(self, np.ndarray[double, ndim=2, mode='fortran'] X):
        self.n_samples = X.shape[0]
        self.n_features = X.shape[1]
        self.data = <double*> X.data
        self.X = X

    def __cinit__(self, np.ndarray[double, ndim=2, mode='fortran'] X):
        cdef int i
        cdef int n_samples = X.shape[0]
        self.indices = <int*> stdlib.malloc(sizeof(int) * n_samples)
        for i in xrange(n_samples):
            self.indices[i] = i

    def __dealloc__(self):
        stdlib.free(self.indices)

    # This is used to reconstruct the object in order to make it picklable.
    def __reduce__(self):
        return (FortranDataset, (self.X, ))

    cdef void get_column_ptr(self,
                             int j,
                             int** indices,
                             double** data,
                             int* n_nz) nogil:
        indices[0] = self.indices
        data[0] = self.data + j * self.n_samples
        n_nz[0] = self.n_samples


cdef class CSRDataset(RowDataset):

    def __init__(self, X):
        cdef np.ndarray[double, ndim=1, mode='c'] X_data = X.data
        cdef np.ndarray[int, ndim=1, mode='c'] X_indices = X.indices
        cdef np.ndarray[int, ndim=1, mode='c'] X_indptr = X.indptr

        self.n_samples = X.shape[0]
        self.n_features = X.shape[1]
        self.data = <double*> X_data.data
        self.indices = <int*> X_indices.data
        self.indptr = <int*> X_indptr.data

        self.X = X

    # This is used to reconstruct the object in order to make it picklable.
    def __reduce__(self):
        return (CSRDataset, (self.X, ))

    cdef void get_row_ptr(self,
                          int i,
                          int** indices,
                          double** data,
                          int* n_nz) nogil:
        indices[0] = self.indices + self.indptr[i]
        data[0] = self.data + self.indptr[i]
        n_nz[0] = self.indptr[i + 1] - self.indptr[i]


cdef class CSCDataset(ColumnDataset):

    def __init__(self, X):
        cdef np.ndarray[double, ndim=1, mode='c'] X_data = X.data
        cdef np.ndarray[int, ndim=1, mode='c'] X_indices = X.indices
        cdef np.ndarray[int, ndim=1, mode='c'] X_indptr = X.indptr

        self.n_samples = X.shape[0]
        self.n_features = X.shape[1]
        self.data = <double*> X_data.data
        self.indices = <int*> X_indices.data
        self.indptr = <int*> X_indptr.data

        self.X = X

    # This is used to reconstruct the object in order to make it picklable.
    def __reduce__(self):
        return (CSCDataset, (self.X, ))

    cdef void get_column_ptr(self,
                             int j,
                             int** indices,
                             double** data,
                             int* n_nz) nogil:
        indices[0] = self.indices + self.indptr[j]
        data[0] = self.data + self.indptr[j]
        n_nz[0] = self.indptr[j + 1] - self.indptr[j]




cdef class EncodedDataset(RowDataset):
    # TODO: add checks for sub_indexes. Add default values for sub_indexes
    def __init__(self,
                 np.ndarray[int, ndim=2, mode='c'] X,
                 np.ndarray[int, ndim = 1, mode = 'c'] sub_indexes ):
        self.n_samples = sub_indexes.shape[0]
        self.n_nz = X.shape[1]
        self.indices = <int*> X.data
        # self.sub_indexes_ptr = <int*> sub_indexes.data
        # TODO: clean this
        # +1 since the first value is set to zero.
        self.n_features = <int> np.max(X) + 1
        self.X = X


        print "n_samples",self.n_samples,"n_nz", self.n_nz,"n_features", self.n_features

    def __cinit__(self, np.ndarray[int, ndim=2, mode='c'] X,
                    np.ndarray[int, ndim = 1, mode = 'c'] sub_indexes ):
        cdef int j
        # cdef np.ndarray[int, ndim = 1, mode = 'c'] sub_indexes
        cdef int n_nz = X.shape[1]
        cdef int n_indexes = sub_indexes.shape[0]
        cdef int* indexes_ptr
        indexes_ptr = <int*> sub_indexes.data

        self.data = <double*> stdlib.malloc(sizeof(double) * n_nz)
        self.sub_indexes_ptr = <int*> stdlib.malloc(sizeof(int) * n_indexes)
        for j in xrange(n_nz):
            self.data[j] = 1.
        for j in xrange(n_indexes):
            self.sub_indexes_ptr[j] = indexes_ptr[j]

    def __dealloc__(self):
        stdlib.free(self.data)
        stdlib.free(self.sub_indexes_ptr)


    # This is used to reconstruct the object in order to make it picklable.
    def __reduce__(self):
        return (EncodedDataset, (self.X, ))

    cdef void get_row_ptr(self,
                          int i,
                          int** indices,
                          double** data,
                          int* n_nz) nogil:
        cdef int real_i
        real_i = self.sub_indexes_ptr[i]
        indices[0] = self.indices + real_i * self.n_nz
        data[0] = self.data
        n_nz[0] = self.n_nz

    def dot(self, np.ndarray[double, ndim = 1, mode = 'c'] coef):
        cdef double* coef_ptr, results_ptr
        cdef np.ndarray result
        cdef int n_obs

        coef_ptr = <double*> coef.data
        if coef.shape[0]!= self.n_features:
            raise ValueError("coef and dataset have different shapes")
        result = np.empty(self.n_samples)
        result_ptr = <double*> result.data
        self.inplace_dot(coef_ptr,result_ptr, self.n_samples)
        return result

    def get_data(self):
        return self.X
    
    cpdef get_indexes(self):
        cdef np.npy_intp shape[1]
        shape[0] = <np.npy_intp> self.n_samples
        sub_indexes = np.PyArray_SimpleNewFromData(1,shape,np.NPY_INT,self.sub_indexes_ptr)

        return sub_indexes

    cdef void inplace_dot(self,
                          double* coef_ptr,
                          double* result_ptr,
                          int n_obs) nogil:
        cdef int i, j, jj
        cdef double tmp
        cdef double* data
        cdef int* indices
        cdef int n_nz

        for i in xrange(n_obs):
            tmp = 0
            self.get_row_ptr(i, &indices, &data, &n_nz)
            for jj in xrange(n_nz):
                j = indices[jj]
                tmp += coef_ptr[j]
            result_ptr[i] = tmp



def get_dataset(X, order="c"):
    if isinstance(X, Dataset):
        return X

    if sp.isspmatrix(X):
        if order == "fortran":
            X = X.tocsc()
            ds = CSCDataset(X)
        else:
            X = X.tocsr()
            ds = CSRDataset(X)
    else:
        if order == "fortran":
            X = np.asfortranarray(X, dtype=np.float64)
            ds = FortranDataset(X)
        else:
            X = np.ascontiguousarray(X, dtype=np.float64)
            ds = ContiguousDataset(X)
    return ds

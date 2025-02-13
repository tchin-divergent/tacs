#  This file is part of TACS: The Toolkit for the Analysis of Composite
#  Structures, a parallel finite-element code for structural and
#  multidisciplinary design optimization.
#
#  Copyright (C) 2014 Georgia Tech Research Corporation
#
#  TACS is licensed under the Apache License, Version 2.0 (the
#  "License"); you may not use this software except in compliance with
#  the License.  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0

#distutils: language=c++

# For the use of MPI
from mpi4py.libmpi cimport *
cimport mpi4py.MPI as MPI

# Import numpy
import numpy as np
cimport numpy as np

# Ensure that numpy is initialized
np.import_array()

# Import the definition required for const strings
from libc.string cimport const_char
from libc.stdlib cimport malloc, free

# Import C methods for python
from cpython cimport PyObject, Py_INCREF

# Import the definitions
from TACS cimport *
from functions cimport *

# Include the definitions
include "TacsDefs.pxi"

# Include the mpi4py header
cdef extern from "mpi-compat.h":
    pass

cdef class StructuralMass(Function):
    def __cinit__(self, Assembler assembler):
        """
        Wrap the function StructuralMass
        """
        self.ptr = new TACSStructuralMass(assembler.ptr)
        self.ptr.incref()
        return

cdef class Compliance(Function):
    cdef TACSCompliance *cptr
    def __cinit__(self, Assembler assembler):
        """
        Wrap the function Compliance
        """
        self.cptr = new TACSCompliance(assembler.ptr)
        self.ptr = self.cptr
        self.ptr.incref()
        return

    def setComplianceType(self, int compliance_type):
        """
        Set the type of compliance value to use
        """
        self.cptr.setComplianceType(compliance_type)
        return

cdef class AverageTemperature(Function):
    def __cinit__(self, Assembler assembler, **kwargs):
        """
        Wrap the function AverageTemperature
        """
        cdef double volume = 1.0

        if 'volume' in kwargs:
            volume = kwargs['volume']

        self.ptr = new TACSAverageTemperature(assembler.ptr, volume)
        self.ptr.incref()
        return

cdef class KSTemperature(Function):
    cdef TACSKSTemperature *kstptr
    def __cinit__(self, Assembler assembler, **kwargs):
        """
        Wrap the function KSTemperature
        """
        cdef double ksWeight = 80.0
        cdef double alpha = 1.0

        if 'ksWeight' in kwargs:
            ksWeight = kwargs['ksWeight']

        if 'alpha' in kwargs:
            alpha = kwargs['alpha']

        self.kstptr = new TACSKSTemperature(assembler.ptr, ksWeight, alpha)
        self.ptr = self.kstptr
        self.ptr.incref()
        return

    def setKSTemperatureType(self, ftype='discrete'):
        if ftype == 'discrete':
            self.kstptr.setKSTemperatureType(KS_TEMPERATURE_DISCRETE)
        elif ftype == 'continuous':
            self.kstptr.setKSTemperatureType(KS_TEMPERATURE_CONTINUOUS)
        elif ftype == 'pnorm-discrete':
            self.kstptr.setKSTemperatureType(PNORM_TEMPERATURE_DISCRETE)
        elif ftype == 'pnorm-continuous':
            self.kstptr.setKSTemperatureType(PNORM_TEMPERATURE_CONTINUOUS)
        return

    def setLoadFactor(self, TacsScalar loadFactor):
        self.ksptr.setLoadFactor(loadFactor)

    def setParameter(self, double ksparam):
        self.kstptr.setParameter(ksparam)

cdef class KSFailure(Function):
    cdef TACSKSFailure *ksptr
    def __cinit__(self, Assembler assembler, **kwargs):
        """
        Wrap the function KSFailure
        """
        cdef double ksWeight = 80.0
        cdef double alpha = 1.0
        cdef double safetyFactor = 1.0

        if 'ksWeight' in kwargs:
            ksWeight = kwargs['ksWeight']

        if 'alpha' in kwargs:
            alpha = kwargs['alpha']

        if 'safetyFactor' in kwargs:
            safetyFactor = kwargs['safetyFactor']

        self.ksptr = new TACSKSFailure(assembler.ptr, ksWeight, alpha, safetyFactor)
        self.ptr = self.ksptr
        self.ptr.incref()
        return

    def setKSFailureType(self, ftype='discrete'):
        if ftype == 'discrete':
            self.ksptr.setKSFailureType(KS_FAILURE_DISCRETE)
        elif ftype == 'continuous':
            self.ksptr.setKSFailureType(KS_FAILURE_CONTINUOUS)
        elif ftype == 'pnorm-discrete':
            self.ksptr.setKSFailureType(PNORM_FAILURE_DISCRETE)
        elif ftype == 'pnorm-continuous':
            self.ksptr.setKSFailureType(PNORM_FAILURE_CONTINUOUS)
        return

    def setParameter(self, double ksparam):
        self.ksptr.setParameter(ksparam)

cdef class KSDisplacement(Function):
    cdef TACSKSDisplacement *ksptr
    def __cinit__(self, Assembler assembler, **kwargs):
        """
        Wrap the function KSDisplacement
        """
        cdef double ksWeight = 80.0
        cdef double alpha = 1.0
        cdef double d[3]

        if 'ksWeight' in kwargs:
            ksWeight = kwargs['ksWeight']

        if 'alpha' in kwargs:
            alpha = kwargs['alpha']

        if 'direction' in kwargs:
            dir = kwargs['direction']
            # Check if dir is a list or numpy array
            if isinstance(dir, list) or isinstance(dir, np.ndarray):
                dim = min(3, len(dir))
                for i in range(dim):
                    d[i] = dir[i]
            else:
                d[0] = d[1] = d[2] = 0.0

        self.ksptr = new TACSKSDisplacement(assembler.ptr, ksWeight, d, alpha)
        self.ptr = self.ksptr
        self.ptr.incref()
        return

    def setKSDisplacementType(self, ftype='discrete'):
        if ftype == 'discrete':
            self.ksptr.setKSDisplacementType(KS_DISPLACEMENT_DISCRETE)
        elif ftype == 'continuous':
            self.ksptr.setKSDisplacementType(KS_DISPLACEMENT_CONTINUOUS)
        elif ftype == 'pnorm-discrete':
            self.ksptr.setKSDisplacementType(PNORM_DISPLACEMENT_DISCRETE)
        elif ftype == 'pnorm-continuous':
            self.ksptr.setKSDisplacementType(PNORM_DISPLACEMENT_CONTINUOUS)
        return

    def setParameter(self, double ksparam):
        self.ksptr.setParameter(ksparam)

# cdef class InducedFailure(Function):
#     cdef TACSInducedFailure *iptr
#     def __cinit__(self, Assembler assembler, double P):
#         """
#         Wrap the function InducedFailure
#         """
#         self.iptr = new TACSInducedFailure(assembler.ptr, P)
#         self.ptr = self.iptr
#         self.ptr.incref()
#         return

#     def setInducedType(self, ftype='exponential'):
#         if ftype == 'exponential':
#             self.iptr.setInducedType(INDUCED_EXPONENTIAL)
#         elif ftype == 'power':
#             self.iptr.setInducedType(INDUCED_POWER)
#         elif ftype == 'exponential-squared':
#             self.iptr.setInducedType(INDUCED_EXPONENTIAL_SQUARED)
#         elif ftype == 'power-squared':
#             self.iptr.setInducedType(INDUCED_POWER_SQUARED)
#         elif ftype == 'discrete-exponential':
#             self.iptr.setInducedType(INDUCED_DISCRETE_EXPONENTIAL)
#         elif ftype == 'discrete-power':
#             self.iptr.setInducedType(INDUCED_DISCRETE_POWER)
#         elif ftype == 'discrete-exponential-squared':
#             self.iptr.setInducedType(INDUCED_DISCRETE_EXPONENTIAL_SQUARED)
#         elif ftype == 'discrete-power-squared':
#             self.iptr.setInducedType(INDUCED_DISCRETE_POWER_SQUARED)

#     def setParameter(self, double param):
#         self.iptr.setParameter(param)

cdef class HeatFlux(Function):
    cdef TACSHeatFlux *hptr
    def __cinit__(self, Assembler assembler, list elem_index,
                  list surfaces):
        cdef int num_elems = len(elem_index)
        cdef int *elem_ind = NULL
        cdef int *surf = NULL

        elem_ind = <int*>malloc(num_elems*sizeof(int));
        surf = <int*>malloc(num_elems*sizeof(int));

        for i in range(num_elems):
            elem_ind[i] = <int>elem_index[i]
            surf[i] = <int>surfaces[i]
        self.hptr = new TACSHeatFlux(assembler.ptr, elem_ind, surf,
                                     num_elems)
        self.ptr = self.hptr
        self.ptr.incref()

        free(elem_ind)
        free(surf)
        return

# cdef class DisplacementIntegral(Function):
#     cdef TACSDisplacementIntegral *dptr
#     def __cinit__(self, Assembler assembler, dirs):
#         """
#         Wrap the function KSFailure
#         """
#         cdef TacsScalar _dirs[3]
#         _dirs[0] = dirs[0]
#         _dirs[1] = dirs[1]
#         _dirs[2] = dirs[2]
#         self.dptr = new TACSDisplacementIntegral(assembler.ptr, _dirs)
#         self.ptr = self.dptr
#         self.ptr.incref()
#         return

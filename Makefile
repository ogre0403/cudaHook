# Copyright 2020 Hung-Hsin Chen, LSA Lab, National Tsing Hua University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# path to CUDA installation
CUDA_PATH ?= /usr/local/cuda-10.0
PWD := $(shell pwd)
PREFIX ?= $(PWD)/..

SMS ?= 30 35 37 50 52 60 61 70
GENCODE_FLAGS += $(foreach sm,$(SMS),-gencode arch=compute_$(sm),code=sm_$(sm))

CXX ?= g++
NVCC ?= $(CUDA_PATH)/bin/nvcc -ccbin $(CXX)

CUDA_LDFLAGS += -lcuda -L$(CUDA_PATH)/lib64 -L$(CUDA_PATH)/lib64/stubs
LDFLAGS += -ldl -lrt

CXXFLAGS += -std=c++11 -fPIC

ifeq ($(DEBUG),1)
CXXFLAGS += -g -D_DEBUG -Wall
else
CXXFLAGS += -O2
endif

# Target rules
all: libcuhook.so.1 cuHook




libcuhook.o: libcuhook.cpp libcuhook.h
	$(NVCC) -m64 --compiler-options "$(CXXFLAGS)" $(GENCODE_FLAGS) -o $@ -c $<

libcuhook.so.1: libcuhook.o
	$(EXEC) $(NVCC) -shared -m64 $(GENCODE_FLAGS) -o $@ $+ $(CUDA_LDFLAGS) $(LDFLAGS)


cuHook.o: cuHook.cpp 
	$(NVCC) -m64 --compiler-options "$(CXXFLAGS)" $(GENCODE_FLAGS) -o $@ -c $<


cuHook: cuHook.o
	$(EXEC) $(NVCC) $(ALL_LDFLAGS) $(GENCODE_FLAGS) -o $@ $+ $(CUDA_LDFLAGS)




clean:
	rm -f *.o
	rm -f *.so.1
	rm -f *.so
	rm -f cuHook

from ctypes import *

handle=CDLL('./libICTCLAS50.so')

handle.ICTCLAS_Init(char_p("./"))



from libc.stdio cimport fopen,fclose,fwrite,FILE,fread
from libc.stdlib cimport malloc,free

DEF STEP=20


cdef struct HI: 
    int left    #左侧范围
    int right   #右侧范围


###################### init_hashIndex  from  Thesaurus.pyx  #################

cdef class init_hashIndex:
    '''
    init he hash index
    '''
    #define the hash index 

    cdef HI hi[STEP]


####################################################################


#定义 hashIndex 结构
cdef struct HI: #hashIndex 结构
    int left    #左侧范围
    int right   #右侧范围
    

cdef class Init_thesaurus:
    '''
    初始化词库
    '''
    #使用动态分配内存方式  
    #分配词库内存空间
    cdef char **word_list
    #一级hash 参考表 初始化
    cdef init_hashIndex hashIndex
    #词库长度 由 delloc 调用
    cdef int length

    cdef double v(self,data):
        '''
        将元素比较的属性取出
        '''
        return hash(data)

    def show(self):
       


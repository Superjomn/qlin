
cdef class query:
    '''
    查询库
    输入一段 句子 返回 最终查询的 docID
    并且进行排序

    此为单线程
    '''
    cdef int *docids

    def __cinit__(self):
        '''
        init 
        词库
        索引库
        '''
        pass

    cdef gro_words(self):
        '''
        将words进行分组
        增加查询效率
        被 uni_docids 引用
        '''
        pass

    cdef int *uni_docids(self):
        '''
        输入词组
        返回查询的所有命中 且不重复的docID
        '''
        pass

    cdef 


    cdef value(self):
        '''
        对每个docid
        计算其文档主题相关度
        '''
        pass

    cdef val_sort(self):
        '''
        对权值进行排序
        '''
        pass






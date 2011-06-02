###############################
#  需要 初始化一块 wordid hash表
#
###############################

from libc.stdlib cimport malloc,free,realloc

#记录的hit结构
cdef struct Whit:
    int docid
    int score



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

    def find_words(self,para):

        '''
        将词汇分词
        并且进行插曲
        '''
        words = wordsplit(para)

        #对word进行分组
        group_words()

        #对每个word进行处理
        for word in words:
            #进行查取
            #同时自动收录value
            hit_find(word) 





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




def class query:

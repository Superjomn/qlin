from parser.Init_Thes import 


#记录的hit结构
cdef struct Whit:
    int docid
    int score

from libc.stdlib cimport malloc,free,realloc

cdef class Hit_find:

    '''
    从hit中查取相应内容
    '''
    #whit 存储目录
    cdef char *fdir

    def __cinit__(self,char *fdir):
        '''
        init
        '''
        self.fdir=fdir

    def pos_word_file(self,word):
        '''
        对word区分范围
        找到相关hit文件
        '''
        pass

    def get_doc_ids(self,word):
        '''
        返回找到的docids
        并且划分一定内存 
        记录相关hit
        '''
        '''
        算法：
            定位到 wordid
            返回每个docid的第一个记录
            
            再查找第二个词及以上时
            直接在wordid中扫描原有docid
            如果存在 加上score 否则 将原有记录刷新为0（表示放弃此docid)
            
            一直到最后 整理结果
            进行排序
            返回结果
        '''






cdef class Init_Thes:
    
    '''
    初始化词库
    通过使用 c 动态分配内存
    '''
    cdef:
        int length


    def __cinit__(self,char *ph):

        '''
        init
        '''
        cdef:
            int i
        
        f=open(ph)
        words=f.read().split()
        f.close()
        
        #词的数量 
        self.length=len(words)
        print 'get the words length is',self.length

        for i,w in enumerate(words):
            print i,w




thes=Init_Thes('../store/wordBar')

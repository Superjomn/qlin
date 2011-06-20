cdef class path:

    '''
    路径管理
    '''

    cdef:
        char *site

    def __cinit__(self,int iid):
        '''
        init
        '''
        cdef:
            object iiid

        iiid = 'store/sites/'+str(iid)+'/'
        self.site = iiid


    def g_hash_index(self):
        '''
        index_hash.b
        '''
        return self.site + 'index_hash.b'

    def g_word_wide(self):
        '''
        word_wide.txt
        '''
        return self.site + 'word_wide.txt'

    def g_wordbar(self):
        '''
        wordBar
        '''
        return self.site + 'wordBar'

    def g_hit_size(self):
        '''
        hit_size
        '''
        return self.site + 'hit_size.txt'

    def g_hit(self,id):
        '''
        hits
        '''
        return self.site + 'hits/'+str(id) +'.hit'







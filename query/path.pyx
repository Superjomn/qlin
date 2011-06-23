cdef class path:

    '''
    路径管理
    '''

    cdef:
        char *site
        object iiid

    def __cinit__(self,int iid):
        '''
        init
        '''
        self.iiid = 'store/sites/'+str(iid)+'/'
        self.site = self.iiid
        print 'in init self.site',self.site


    def g_chun_sqlite(self):
        '''
        内容数据库
        chun.sqlite
        '''
        return self.site + 'chun.sqlite'


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
        print 'self.site:',self.site
        return self.site + 'wordBar'

    def g_hit_size(self):
        '''
        hit_size
        '''
        return self.site + 'hits/hit_size.txt'


    def g_hits(self):
        '''
        store/hits
        '''
        return self.site + 'hits'


    def g_hit(self,id):
        '''
        hits
        '''
        return self.site + 'hits/'+str(id) +'.hit'







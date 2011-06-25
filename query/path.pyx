import os
import shutil

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
        if iid >0:
            self.iiid = 'store/sites/'+str(iid)+'/'
            self.site = self.iiid
        else:
            #当id为0时 默认为主站
            self.iiid = 'store/'
            self.site = self.iiid

        print 'in init self.site',self.site
    
    def g_site(self):
        '''
        取得 本站点目录
        '''
        return self.site

    def g_document(self):
        '''
        document
        '''
        return self.site + 'document'


    def g_wordsplit(self):
        '''
        wordsplit
        '''
        return self.site + 'wordsplit'


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

    def g_urltest(self):
        '''
        爬虫下载url
        '''
        return self.site + 'urltest.txt'

    def g_sorted_url(self):
        '''
        sorted_url
        '''
        return self.site + 'sorted_url.txt'


    ###########################################################################
    #
    #       站点目录管理
    #
    ###########################################################################

    def clean_dir(self,char *pa):
        '''
        对目录进行刷新
        适合于文件夹 及 相关文件
        '''
        print 'clean dir'
        if os.path.exists(pa):
            #需要先删除每个文件
            for i in os.listdir(pa):
                os.remove( os.path.join(pa,i) )
        else:
            os.mkdir(pa)



    def mk_dir(self,char *pa):
        '''
        建立目录
        '''
        if not os.path.exists(pa):
            os.mkdir(pa)

    def rm_file(self,char *pa):
        '''
        删除文件
        '''
        if os.path.exists(pa):
            os.remove(pa)

    def cp_chun(self):
        '''
        将空数据库文件进行复制
        到指定文件夹中
        '''
        if not os.path.exists(self.g_chun_sqlite()):
            shutil.copyfile('store/backup/chun.sqlite',self.g_chun_sqlite())
    






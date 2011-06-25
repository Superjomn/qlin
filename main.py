# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')


from index.indexer import Sort_hits

from parser.UrlTransID import UrlTransDir

from Parser import Parser

from Title_des_sqlite import Title_des_sqlite 

from parser.UrlTransID import UrlTransID

from index.indexer import Indexer

#路径管理
from query.path import path


class main:
    
    def __init__(self):
        '''
        init
        '''
        self.p = 0

        self.site_id = 1


    def run(self,site_id):
        '''
        综合路径管理
        '''
        self.site_id = site_id

        path = path(site_id)

        #分词
        self.p=Parser(path.g_document(),path.g_wordsplit(),path.g_wordbar())

        self.url_sort(path.g_urltest(), path.g_sorted_url())

        self.parser()
        #修尬文件名称
        self.url_trans_dir(path.g_sorted_url(), path.g_document(), path.g_wordsplit())
        #index
        self.p.transWbar()

        #数据库处理
        self.title_des(path.g_sorted_url())
    
        self.index(path.g_wordbar(), path.g_wordsplit() ,path.g_hits())
        #进行排序
        self.sort_hit( path.g_hit_size(),path.g_hits()+'/' )


    def sort_hit(self,p1,p2):
        '''
        hit 排序
        '''
        hit_sort=Sort_hits(p1)

        for i in range(20):
            hit_sort.sort_wid(p2,i)
            hit_sort.save(p2,i)
        
    
    def url_trans_dir(self,p1,p2,p3):
        '''
        重新命名
        '''
        urlTransDir = UrlTransDir(p1)

        urlTransDir.renameDoc(p2)

        urlTransDir.renameDoc(p3)



    def url_sort(self,p1,p2):
        '''
        对url进行排序及存储
        '''
        
        sort = UrlTransID(p1)
        sort.sort()

        sort.save(p2)



    def index(self,p1,p2,p3):
        '''
        '''
        
        index=Indexer(self.site_id,p1,p2,p3)
        index.run()

    
    def parser(self):
        self.p.splitWord()


    def title_des(self,p1):
        '''
        '''
        
        doc = Title_des_sqlite()
        doc.run()
        doc.add_url(p1)
        doc.split_des()
        doc.intro_split_des_title()
        doc.cx.commit()


if __name__ == '__main__':
    run = main()
    run.run()




















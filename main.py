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


class main:
    
    def __init__(self):
        self.p=Parser('store/document','store/wordsplit','store/wordBar')

    def run(self):
        '''
        '''
        #分词
        #self.url_sort()
        #self.parser()
        #修尬文件名称
        #self.url_trans_dir()
        #index
        #self.p.transWbar()

        #数据库处理
        #self.title_des()
    
        #self.index()
        #进行排序
        self.sort_hit()


    def sort_hit(self):
        '''
        hit 排序
        '''
        hit_sort=Sort_hits('store/hits/hit_size.txt')
        for i in range(20):
            hit_sort.sort_wid('store/hits/',i)
            hit_sort.save('store/hits/',i)
        
    
    def url_trans_dir(self):
        '''
        重新命名
        '''
        urlTransDir = UrlTransDir('store/sorted_url.txt')

        urlTransDir.renameDoc('store/document')

        urlTransDir.renameDoc('store/wordsplit')



    def url_sort(self):
        '''
        对url进行排序及存储
        '''
        sort = UrlTransID('store/urltest.txt')
        sort.sort()

        sort.save('store/sorted_url.txt')



    def index(self):
        '''
        '''
        index=Indexer('store/wordBar','store/wordsplit','store/hits')
        index.run()

    
    def parser(self):
        self.p.splitWord()


    def title_des(self):
        '''
        '''
        doc = Title_des_sqlite()
        doc.run()
        doc.add_url('store/sorted_url.txt')
        
run = main()
run.run()




















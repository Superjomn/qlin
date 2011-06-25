# -*- coding: utf-8 -*-
import os
import shutil

from query.path import path

from Parser import Parser

from parser.UrlTransID import UrlTransID,UrlTransDir

from Title_des_sqlite import Title_des_sqlite 

from index.indexer import Indexer,Sort_hits

class Main:
    '''
    后期运行主程序
    '''
    def __init__(self):
        '''
        init
        '''
        pass


    def main(self):
        '''
        主站 前期处理程序
        对于index 已经利用STEP
        统一了划分index的快数目
        基本思想：
            将 所有站点信息融合到一起 最后进行处理
        必须在 子站之前进行
        '''
        p = path(0)
        
        ###################################################################
        #   初始化路径
        #
        ###################################################################
        #清空document 为复制其余document作准备
        p.clean_dir(p.g_document())

        ###################################################################
        #   复制document
        #
        ###################################################################
        for li in os.listdir('store/sites'):
            print li
            site_document = os.path.join('store/sites',li,'document')
            print site_document
            
            #print site_path
            for f in os.listdir( site_document):
                #开始将每个文件复制到document中
                file_path = os.path.join(site_document,f)
                shutil.copyfile( file_path,'store/document/'+f)
                print 'successfully copy %s to document'%os.path.join(site_document,f)

        ###################################################################
        #   复制urltest
        #
        ###################################################################
        #现清空urltest
        p.rm_file( p.g_urltest() )
        
        u_file = open( p.g_urltest() , 'a+')
        
        for site_dir in os.listdir( 'store/sites/'):
            url_ph = os.path.join('store/sites',site_dir,'urltest.txt')
            f = open(url_ph)
            c = f.read()
            f.close()
            #附加到u_file后
            u_file.write(c)

        u_file.close()

        p.clean_dir(p.g_wordsplit())

        #清空hits
        p.clean_dir(p.g_hits())
        #初始化数据库
        p.cp_chun()
        
        ###################################################################
        #   复制urltest
        #
        ###################################################################
        #对总站点进行处理
        self.run(0)



    def run(self,site_id):
        '''
        运行主程序
        '''
        p = path(site_id)
        #初始化目录
        #清空wordsplit
        p.clean_dir(p.g_wordsplit())
        #清空hits
        p.clean_dir(p.g_hits())
        #初始化数据库
        p.cp_chun()

        ###################################################################
        #   解析  parser
        #
        ###################################################################
        parser = Parser(site_id)
        
        ###################################################################
        #   url处理 url_sort
        #
        ###################################################################
        url_trans = UrlTransID(p.g_urltest())
        #将url进行排序
        url_trans.sort()
        #存储为　sorted_url.txt
        url_trans.save(p.g_sorted_url())

        ###################################################################
        #   parser 进行分词
        #
        ###################################################################
        parser.splitWord()
        
        ###################################################################
        #  根据　docID 修改文件名
        #
        ###################################################################
        url_trans_dir = UrlTransDir(p.g_sorted_url())
        #对document进行重命名
        url_trans_dir.renameDoc( p.g_document() )
        #对wrdsplit进行重命名
        url_trans_dir.renameDoc( p.g_wordsplit() )
        
        ###################################################################
        #   parser 产生词库　wordbar
        #
        ###################################################################
        parser.transWbar()
        
        ###################################################################
        #   title_处理
        #
        ###################################################################
        title_des_sqlite = Title_des_sqlite(site_id)
        #对原始数据进行刷新
        title_des_sqlite.clear()
        title_des_sqlite.run()
        title_des_sqlite.add_url()
        title_des_sqlite.intro_split_des_title()
        title_des_sqlite.cx.commit()

        ###################################################################
        #   index 索引操作
        #
        ###################################################################
        index = Indexer(site_id)
        index.run()

        ###################################################################
        #   index 对hits进行排序
        #
        ###################################################################
        hit_sort = Sort_hits(p.g_hit_size())
        for i in range(20):
            hit_sort.sort_wid(p.g_hits()+'/',i)
            hit_sort.save(p.g_hits()+'/',i)
        
    



if __name__ == '__main__':
    main = Main()
    for i in range(1,3):
        main.run(i)

    #main.run(1)
    #main.main()
        










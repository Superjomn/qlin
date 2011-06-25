# -*- coding: utf-8 -*-
import sqlite3 as sq

class Site:
    '''
    取得site的一些信息
    便于爬虫等前台处理
    '''
    def __init__(self):
        '''
        init
        '''
        self.cx = sq.connect('store/site.sqlite')
        self.cu = self.cx.cursor()


    def gets(self,site_id):
        '''
        一次性取得所有信息
        '''
        strr = "select * from site where id=%d"%site_id
        self.cu.execute(strr)
        return self.cu.fetchone()
        
if __name__=='__main__':
    s = site()
    print s.gets(1)







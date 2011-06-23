# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import sqlite3 as sq

class site_infor:
    '''
    取得站点的相关信息
    '''
    def __init__(self):
        self.cx = sq.connect('store/site.sqlite')
        self.cu = self.cx.cursor()

    def get_title(self,site_id):
        '''
        取得title
        在搜索中使用
        '''
        strr = "select title from site where id = %d"%site_id
        self.cu.execute(strr)
        return  self.cu.fetchone()[0]

    def get_sites(self):
        '''
        从数据库中取得所有站点信息
        '''
        strr = 'select * from site'
        self.cu.execute(strr)
        return  self.cu.fetchall()

    ###############################################################
    #       主动控制
    ###############################################################
    def add_site(self,site):
        '''
        添加一个站点
        '''
        strr = "insert into site values();"
    



if __name__== '__main__' :
    site = site_infor()
    #print site.get_title(1)
    print site.get_sites()

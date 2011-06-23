# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import sqlite3 as sq
import os
import zipfile as zp

'''
数据库结构：
    站点收录管理：
        site:
            id  title  start_url home_urls head 前缀    
        infor:
            id  page_num 收录页面数目
'''

def cpr_dir(dir_name,zip_name):
    '''
    将目录进行压缩
    '''
    zf=zp.ZipFile(zip_name)
    #add file
    pathfile = os.listdir(dir_name)
    for tar in pathfile:
        zf.write(tar)
    zf.close()





class Ctrl:
    '''
    相关控制方法
    '''
    def __init__(self):
        '''
        格式：
            id  title  start_url home_urls head 前缀
        '''
        self.id = 0
        self.cx = sq.connect('store/chun.sqlite')
        self.cu = self.cx.cursor()

    def set_id(self,id):
        self.id = id


    def set_head(self,head):
        '''
        从head 设置 id
        '''
        strr = "select id from site where head = '%s'"%head 
        self.cu.execute(strr)
        self.id = self.cu.fetchone()


    def add_site(self,head,title,start_url,home_urls):
        '''
        添加site
        id,start_url,home_urls
        '''
        strr = "insert into sites values(NULL,'%s','%s','%s','%s')"%(head,title,start_url,home_urls)
        self.cu.execute(strr)


    def g_start_url(self):
        '''
        start_url
        '''
        self.cu.execute("select start_url from lib where id = %d"%self.id)
        return self.cu.fetchone()


    def g_home_urls(self):
        '''
        home_urls
        '''
        self.cu.execute("select start_url from lib where id = %d"%self.id)
        urls = self.cu.fetchone()
        return urls.split()


    def g_title(self):
        '''
        取得title
        '''
        self.cu.execute("select title from site where id = %d"%self.id)
        return self.cu.fetchone()


    def get_all(self):
        '''
        取得all
        '''
        self.cu.execute("select * from site where id = %d"%self.id)
        return self.cu.fetchone()








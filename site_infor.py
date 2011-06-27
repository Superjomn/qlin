# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import sqlite3 as sq

class site_infor:
    '''
    取得站点的相关信息
    id  title  start_url  home_urls  head  max_page_num  
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

    def get_titles(self):
        '''
        取得站点title
        '''
        strr = 'select title from site'
        self.cu.execute(strr)
        return self.cu.fetchall()



    ###############################################################
    #       主动控制
    ###############################################################

    def add_site(self,site):
        '''
        添加一个站点
        映入 site (title,start_url,home_urls,head,max_page_num)
        之使用site条目
        去除infor
        '''
        print 'add a site'
        #strr = "insert into site values(NULL,'%s','%s','%s','%s',%d,%d)"%site
        strr = "insert into site values(NULL,'','','','',2000,0)"
        print strr
        self.cu.execute(strr)
        self.cx.commit()
    

    def update_site(self,site):
        '''
        刷新一个站点信息
        '''
        '''strr = 'select title from site'
        self.cu.execute(strr)
        return self.cu.fetchall()
        '''
        strr = "update site set title='%s', start_url='%s',home_urls='%s',\
                head='%s',max_page_num=%d where id =%d"%site
        print 'update a site'
        print strr
        self.cu.execute(strr)
        self.cx.commit()


    def delete_site(self,site_id):
        '''
        删除一个站点
        直使用一个条目 不需要site_infor
        '''
        strr="delete from site where id=%d"%site_id
        print 'delete a site'
        print strr
        self.cu.execute(strr)
        self.cx.commit()
    
    ####################### 词库操作 ##############################
    def get_word(self):
        '''
        取得词库西信息
        '''
        strr ="select word from wordbar"
        self.cu.execute(strr)
        return  self.cu.fetchall()
                



    def update_word(self,words):
        '''
        更新词库信息
        '''
        print words
        strr = ''
        for i in words:
            strr="update wordbar set word='%s' where id=%d"%i
            print strr
            self.cu.execute(strr)
        self.cx.commit()


    
if __name__== '__main__' :
    site = site_infor()
    #print site.get_title(1)

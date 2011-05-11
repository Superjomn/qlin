# -*- coding: utf-8 -*-
'''
Created on 2011-5-8

@author: chunwei
'''
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import sqlite3

class Urltest:
    '''
    对url进行处理及判断
    如 是否为父地址的子页面
    转化为绝对地址等
    '''
    def __init__(self):
        self.home_urls=[]
        #self.sqlite=sqlite3.connect('../../store/qlin.db')
        #self.cs = self.sqlite.cursor( )
        self.__initHomeUrls()
    
    def __initHomeUrls(self):
        '''
        初始化 父地址列表
        '''
        #self.home_urls=self.cs.execute('select * from home_urls').fetchall()
        self.home_urls=['http://www.cau.edu.cn']
        
    def absUrl(self,homeurl,url):
        '''
        对已已经确定的相对地址 转化为绝对地址
        对相对地址的处理 如果其首部包含类似../的地址 
        转为绝对地址
        '''
        #计算homeurl的层次 url的层次
        #print homeurl
        #print url
        if homeurl[-1]!='/':
            homeurl+='/'
        level=[]
        length=len(homeurl)
        level2=0
        if homeurl.find('water///')>-1:
            return False
        for i in range(length):
            l=length-i#倒序
            if homeurl[l-1]=='/':
                level.append(l)
        for i in range(5):
            #print url[level2*3 : (level2+1)*3]
            if url[level2*3 : (level2+1)*3]=='../':
                level2+=1
            else:
                break
        if level2>=len(level):
            #url不合法 出现 cau.edu.cn/   ../index.php
            return False
        baseurl=homeurl[0:level[level2]]
        #print baseurl
        apdurl=url[3*level2:]
        #print apdurl
        newurl=baseurl+apdurl
        if self.type_test(newurl):
            return newurl.replace('./','')
        else:
            return False

    def type_test(self,url):
        '''
        对 绝对url 的合法性判断
        如 文件类型不能为 doc exe 等
        '''
        rightlist=('cn','com','php','asp','jsp','html','htm')
        
        length=len(url)
        if url.find('///')>-1:
            return False
        if url.find('mailto:')>-1:
            return False

        for i in range(len(url)):
            index=length-i-1
            if url[index]=='.':
                break
            if url[index]=='/':
                return True 
        end=url[index+1:]
        #print end
        for li in rightlist:
            if li==end:
                return True
        return False

    def abs_url_trans(self,tem_home,url):
        '''
        检测url是否满足条件
        将 url 通过局部父地址转化为绝对地址
        如果其不满足特定条件，返回 False 否则 返回绝对地址
        '''
        print 'the home url',self.home_urls
        #基础格式整形
        if (url== None)or(len(url)<3):   
            return False
        if url[0:4] == '\r\n':   
            url= url[4:]   
        if url[-1] == '/':   
            url= url[:-1]   
        #绝对地址判断 
        
        if len(url) >= len('http://') and url[0:7] == 'http://':
            print 'it is a absolute url'
            for homeurl in self.home_urls:
                home_length=len(homeurl)
                if len(url) >= home_length and url[0:home_length] == homeurl:
                    return url
            return False
        
        if url[0:5] == '/java' or url[0:4] == 'java':
            return False
        
        else:
            #有意义的相对地址
            return self.absUrl(tem_home, url)
        
    def tem_home(self,url):
        '''
        提取出 url 中的相对 父地址
        如： http://www.cau.edu.cn/hsz/index.php  => http://www.cau.edu.cn/hsz
        '''
        #the situations:
        #hsz/index.php   can.edu.cn  cn/hsz   cn/hsz/
        #the most import thing is the last . and / pos
        askpos=self.__backFind(url,'?')
        
        if askpos:  #if ? exists
            url=url[:askpos]
        right_end=['cn','com','org']
        pos1=self.__backFind(url,'/') # pos of last /
        pos2=self.__backFind(url,'.') # pos of last .
        length=len(url)         #length of url
        #start to judge
        if pos1 and pos2:
            if pos1>pos2:
                #cn/hsz cn/hsz/
                print 'length is',length
                print 'pos1 is ',pos1
                if pos1==length-1:
                    return url[:-1]
            return url
        #cau.edu.cn   hsz.php
        end=url[pos2+1:]
        print 'ping: cau.edu.cn\n the end is:',end
        for i in right_end:
            if end==i: #like: cau.edu.cn
                return url
        #like cau.edu.cn/index.php
        pos2=self.__backFind(url[:pos2],'/')
        return url[:pos2]
       


    def __backFind(self,home,s):
        '''
        返回倒序查找的第一个s的位置
        '''
        thome=home[::-1] #反向字符串
        i=thome.find(s)
        return len(home)-i-1
    
    

if __name__=='__main__':
    urltest=Urltest()
    urls=['../chunwei/qiaolin','./bbs/././chunwei.php','index.doc','http://www.cau.edu.cn','http://www.cau.edu.cn/tyjxb']
    homeurl='http://www.cau.edu.cn'
    for url in urls:
        print url,homeurl,urltest.abs_url_trans(homeurl, url)
        print '----------------------------------------'
            
        
    
        
        
        
        

# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import threading  
import time  
import urllib2  
import StringIO  
import gzip  
import string  

from reptile.Urlist import Urlist
#对html内容的提取
from parser.HtmlParser import Collector
#对url的处理库
from reptile.Urltest import Urltest
#sqlite数据库
#import sqlite3

from parser.collector import collector


class reptile(threading.Thread):  

#全局值 
    # queue     : the runtime url bar ( the repile pop a new url from it each time)
    # name      : repile 进程的名称
    # Flcok     : 对文件操作的琐
    # num       : repile进程下载页面个数
    # list      : Urlist对象 运行时url参考 以判断页面是否下载过
    # homelist  : 父目录参考(模拟垂直下载)
    # maxnum    : 设定repile进程下载页面数上限
#局部：
    #raw_url    : 存储每次下载页面中的未经过处理的url 
    #inque      : queue的继承 运行时绝对url参考  
    
    def __init__(self, Name, runtime_queue, list, per_max_num ,Flcok):  
        threading.Thread.__init__(self, name = Name )  
        self.runtime_queue = runtime_queue  
        #self.result = result  
        self.num = 0          
        self.maxnum = per_max_num
        self.list=list
        self.Flcok=Flcok
        #self.sqlite=sqlite3.connect('store/qlin.db')
        
        self.urltest=Urltest()
        self.htmlparser=Collector()
        self.collector=collector()
        #初始化home_list
        self.home_urls=[]
        self.inqueue = Queue()
    
    def init_home_urls(self):
        '''
        得到父地址 作为接口可以被重载
        '''
        #self.home_urls=self.sqlite.execute('select * from home_urls')
	self.home_url="http://www.cau.edu.cn"
    
    def add_runtime_urls(self,docname,url):
        self.Flcok.acquire()  
        confile = open('store/urltest.txt', 'a+')  
        confile.write( docname+' '+url+'\n')  
        confile.close()  
        self.Flcok.release()  
        
        
    def run(self):  
        '''
        运行主程序
        '''
        opener = urllib2.build_opener()     

        while True:  
            print 'queue size:',self.runtime_queue.qsize()
            if self.runtime_queue.qsize()==0:
                print 'the queue is empty break the while'
                break
            #单次运行时url
            url = self.runtime_queue.get()          
            print 'get a url from runtime',url
            
            if url == None:                 
                break
            
            print 'get the url from runtime',url
            
            #parser = Basegeturls()         
            request = urllib2.Request(url) 
            request.add_header('Accept-encoding', 'gzip')
            #局部未处理url存储
            raw_url=[]
                
            try:            
                page = opener.open(request,timeout=2) #设置超时为2s
                
                if page.code == 200:      
                    predata = page.read()
                    pdata = StringIO.StringIO(predata)
                    gzipper = gzip.GzipFile(fileobj = pdata)  
                    
                    try:  
                        data = gzipper.read()  
                    except(IOError):  
                        data = predata
                        
                    try:  
                        if len(data)<300:
                            continue
                        #begain to parse the page
                        self.htmlparser.init(data)
                        self.collector.init(data)
                    except:  
                        print 'not a useful page'
                    #获取页面中url 加入到inqueue 和 Urlist中    
                    
                    for item in self.htmlparser.get_url():
                        if item.find('#')<0:
                            raw_url.append(item)
                            
                    self.num += 1 
                    #将已经下载html的url进行存储
                    docname=self.getName()+str(self.num) 
                    
                    
                    #将链接进行存储e
                    print 'begain add_runtime_urls'
                    self.add_runtime_urls(docname, url)
                    print 'succeed add runtime_urls'
                    
                page.close()  
                if self.num >= self.maxnum:
                    break  
            except:  
                print 'end error'  

            temHomeUrl=self.urltest.tem_home(url)
            print 'begain trans_d'
            self.trans_d(temHomeUrl,raw_url)
            #将信息进行储存
            self.save_doc_content(docname,temHomeUrl)
            
            if self.num>self.maxnum:
                for i in self.list:
                    print i
                break
                return True
        
    def trans_d(self,tem_home,rawurls):
        '''
        对地址的处理：
            包括 判断url是否为父地址的子页面
            将 相对url 转化为 相对url
        '''
        print 'get tem_home',tem_home
        print 'get rawurls',rawurls
        while True:
            if len(rawurls)>0:
                url=rawurls.pop()
                
            else:
                return False
            
            newurl=self.urltest.abs_url_trans(tem_home, url)
            if newurl and self.list.find(newurl) == False:
                print 'input a url into runtime_queue',newurl
                self.runtime_queue.put(newurl) 
         
    def save_doc_content(self,docname,tem_home):
        '''
        将各个节点的内容存入数据库中
        '''
        print 'begain save_doc_content'
        
        title=self.htmlparser.get_nodes('title')
        h1=self.htmlparser.get_nodes('h1')
        h2=self.htmlparser.get_nodes('h2')
        h3=self.htmlparser.get_nodes('h3')
        b=self.htmlparser.get_nodes('b')
        a=self.htmlparser.get_as()
        content=self.htmlparser.get_content()
        
        f=open('store/document/'+self.name+str(self.num),'w')
        try:
            f.write(self.collector.xml(tem_home).toxml())
        except:
            print 'write the data wrong'
    
        print 'begain to save content in file'
        #text=docname+'@chunwei@'+title+'@chunwei@'+a[0]+'@chunwei@'+a[1]+'@chunwei@'+h1+'@chunwei@'+h2+'@chunwei@'+h3+'@chunwei@'+b+'@chunwei@'+content

    def __backFind(self,home,s):
        thome=home[::-1] 
        i=thome.find(s)
        if i>-1:
            return len(home)-i-1
        else:
            return False



from Queue import Queue  
import threading  

class Reptile_run:
    '''
    爬虫运行控制程序
    主程序
    '''
    def __init__(self,thread_num,per_max_num):
        '''
        thread_num    : 线程数目
        per_max_num   : 每一个线程下载的最大页面数目
        '''
        self.thread_num=thread_num
        self.per_max_num=per_max_num
        #num=20
        #pnum=100
        self.runtime_queue=Queue()
        self.list=Urlist()
        
        self.Flock = threading.RLock()  
        
        self.thlist = []  
    
    def run(self):
        '''
        运行主程序
        '''
        startpage='http://www.cau.edu.cn'
        
        for i in range(self.thread_num):  
            th = reptile('s' + str(i), self.runtime_queue,self.list,self.per_max_num ,self.Flock)
            self.thlist.append(th)  
            
        for i in self.thlist:  
            i.start()  
        self.runtime_queue.put(startpage)  
        
if __name__=='__main__':
    rep=Reptile_run(20,2000)
    rep.run()
    
        


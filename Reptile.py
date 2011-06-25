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

from parser.collector import collector
#导入 site从数据库中查找信息
import Site

from query.path import path 



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
    
    def __init__(self,site_id, Name, runtime_queue, list, per_max_num ,Flcok,home_urls):  
        '''
        site_id:
            获得相应的目录
        '''

        threading.Thread.__init__(self, name = Name )  
        self.runtime_queue = runtime_queue  
        #self.result = result  
        #路径管理
        self.path = path(site_id)

        self.num = 0          
        self.maxnum = per_max_num
        self.list=list
        self.Flcok=Flcok
        #self.sqlite=sqlite3.connect('store/qlin.db')
         
        self.urltest=Urltest(home_urls)
        self.htmlparser=Collector()
        self.collector=collector(home_urls)
        #初始化home_list
        self.home_urls=home_urls
        self.inqueue = Queue()
        
        #开始对原始目录进行清扫
        #建立站点
        self.path.mk_dir( self.path.g_site() )
        #urltest
        self.path.rm_file( self.path.g_urltest() )
        #晴空document
        self.path.clean_dir( self.path.g_document() )

    
    def add_runtime_urls(self,docname,url):
        self.Flcok.acquire()  
        confile = open(self.path.g_urltest(), 'a+')  
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
            
            if url == None:                 
                break
            
            print 'get from runtime',url
            
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
                    #print 'docname',docname
                    
                    
                    #将链接进行存储e
                    #print 'begain add_runtime_urls'
                    self.add_runtime_urls(docname, url)
                    #print 'succeed add runtime_urls'
                    
                page.close()  

                if self.num >= self.maxnum:
                    break  
            except:  
                print 'end error'  

            temHomeUrl=self.urltest.tem_home(url)
            #print 'begain trans_d'
            self.trans_d(temHomeUrl,raw_url)
            #将信息进行储存
            self.save_doc_content(docname,temHomeUrl)
            
            if self.num>self.maxnum:

                '''for i in self.list:
                    ###print i
                break'''

                return True

        
    def trans_d(self,tem_home,rawurls):
        '''
        对地址的处理：
            包括 判断url是否为父地址的子页面
            将 相对url 转化为 相对url
        '''
        #print 'get tem_home',tem_home
        #print 'get rawurls',rawurls

        while True:
            if len(rawurls)>0:
                url=rawurls.pop()
                
            else:
                return False

            #print 'tem_home>',tem_home 
            #print 'begin abs_url_trans'
            newurl=self.urltest.abs_url_trans(tem_home, url)
            #print 'newurl'+'-'*50
            #print 'get new>',newurl

            if newurl and self.list.find(newurl) == False:
                #print 'input>',newurl
                self.runtime_queue.put(newurl) 
         
    def save_doc_content(self,docname,tem_home):
        '''
        将各个节点的内容存入数据库中
        '''
        #print 'begain save_doc_content'
        
        title=self.htmlparser.get_nodes('title')
        h1=self.htmlparser.get_nodes('h1')
        h2=self.htmlparser.get_nodes('h2')
        h3=self.htmlparser.get_nodes('h3')
        b=self.htmlparser.get_nodes('b')
        a=self.htmlparser.get_as()
        content=self.htmlparser.get_content()
        
        f=open(self.path.g_document()+'/'+self.name+str(self.num),'w')
        try:
            f.write(self.collector.xml(tem_home).toxml())
        except:
            print 'write the data wrong'
            pass
        #f.write(self.collector.xml(tem_home).toxml())



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
    def __init__(self):
        '''
        thread_num    : 线程数目
        per_max_num   : 每一个线程下载的最大页面数目
        '''
        self.thread_num=3
        #num=20
        #pnum=100
        '''
        self.runtime_queue=Queue()
        self.list=Urlist()
        
        self.Flock = threading.RLock()  
        
        self.thlist = []  
        '''

        self.site = Site.Site()
    

    def run(self,site_id):
        '''
        运行主程序
        与数据库配合 载入site_id 将相关信息载入
        '''
        runtime_queue = Queue() 
        list = Urlist()
        Flock = threading.RLock()  
        thlist = []

        site_infor = self.site.gets(site_id)
        startpage= site_infor[2]
        #尝试添加home_urls
        home_urls = site_infor[3].split('\r\n')
        head = site_infor[4]
        per_max_num = site_infor[5]

        for i in range(self.thread_num):  
            #此处前缀也需要变化
            #修改  根据站点前缀命名爬虫
            th = reptile(site_id,head + str(i), runtime_queue,list,per_max_num ,Flock,home_urls)
            thlist.append(th)  
            
        for i in thlist:  

            i.start()  

        runtime_queue.put(startpage)  
        

if __name__=='__main__':
    rep=Reptile_run()
    rep.run(2)
    
        


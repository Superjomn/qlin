# -*- coding:utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
#需要提前导入SortFind库
from SortFind import SortFind 

class urlbar(SortFind):

    '''
    url库查询
    '''
    def __init__(self,sortedurlph):

        '''
        初始化url库
        '''
        f=open(sortedurlph)
        c=f.readlines()
        f.close()

        self.urlbar=[]

        for l in c:
            #先默认所欲的url的hash值均不重复
            self.urlbar.append(hash(l.split()[1])) 
            #此处可以优化   若hashvalue均不重复 则可以直接存储hashvalue
            #url库直接作为hashvalue

        SortFind.__init__(self,self.urlbar)
        

    def gvalue(self,url):

        return hash(url)
	    

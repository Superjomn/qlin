# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import parser.sorter as sorter

class UrlTransID:
    def __init__(self,fp):
        '''
		将urllist转化为docid
		通过根据hash排序的方法
        '''
        self.urls=[]
        f=open(fp)
        lines=f.readlines()
        f.close()
        for l in lines:
            self.urls.append(l.split())
    
    def sort(self):
        '''
		开始进行排序 使用cython进行优化
        '''
        sort=sorter.Sorter(self.urls)
        sort.quicksort(0,len(self.urls)-1)
    
    def show(self):
        for i in self.urls:
            print hash(i[1])


if __name__=='__main__':
    sort=UrlTransID('../../store/urltest.txt')
    sort.show()
    sort.sort()
    sort.show()
        
        
            
            
            
        

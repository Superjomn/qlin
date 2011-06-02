# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import os

import UrlSorter


class UrlTransID:

    def __init__(self,url_ph):

        '''
		将urllist转化为docid
		通过根据hash排序的方法
        '''
        self.urls=[]
        f=open(url_ph)
        lines=f.readlines()
        f.close()

        for l in lines:
            self.urls.append(l.split())

        self.trans_ph=url_ph
    

    def sort(self):

        '''
		开始进行排序 使用cython进行优化
        '''
        sort=UrlSorter.UrlSorter(self.urls)
        sort.quicksort(0,len(self.urls)-1)


    def save(self,ph):

        '''
        将排序结果进行保存
        '''

        print 'begin to save the sorted url list'
        strr=''
        for i in self.urls:
            strr+= i[0]+' '+i[1]+'\n'
        f=open(ph,'w')
        f.write(strr)
        f.close()
    

    def show(self):
        for i in self.urls:
            print hash(i[1])



class UrlTransDir:

    '''
    将 doc 重新民明
    '''
    def __init__(self,urlph):

        '''
        init 
        '''
        self.urls=[]
        f=open(urlph)
        lines=f.readlines()
        f.close()

        for doc in lines:
            self.urls.append(doc.split())


    def renameDoc(self,ph):

        '''
        将文件rename
        '''

        print 'begin to rename doc'
        for i,li in enumerate(self.urls):
            docname = li[0]
            print 'the doc is',
            print docname
            print 'the ph is',ph+'/'+docname
            try:
                os.rename(ph + '/' + docname,ph + '/'+str(i))
            except:
                print 'no such file'







if __name__=='__main__':
    sort=UrlTransID('../store/urltest.txt')
    sort.show()
    sort.sort()
    sort.save('../store/sorted_url.txt')
    sort.show()
        
        
            
            
            
        

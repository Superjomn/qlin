# -*- coding:utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
import os
import chardet
#载入词库
from indexer import wordbar
from indexer import sorter

#为了便于测试和性能的保证
#将文件每100个保存到一个文件中 分开储存
#需要 在docID排序的基础上 再根据wordID进行排序
#在docID排序时，并不需要重新进行排序（只要保证docID已经排序便可)
#排序顺序必须为： docID > wordID

class Indexer:
    '''
    索引器:
        将分词文件及wordbar统一起来
        生成hit  
        新添特性：
        1 将最终hits进行分块        以满足控制内存占用
        2 使用struct数组及C二进制保存   为了直接用C进行管理
        3 使用优化的优化快速排序 还是需要一个C版本的排序器  采用timer技术
        看到底会占用多少
    '''
    #hits的结构  hitlist=[wordid,docid,score,pos]
    def __init__(self,docph,wbpath,topath):
        '''
        初始化各种地址
        '''
        #分词xml所在文件夹
        self.docph=docph  

        #需要保存到的地址  
        self.topath=topath  

        #此处需要 将wordbar单独作为一个库
        #wordbar应该与query相通
        #词库地址
        self.wbpath=wbpath  

        self.hitlist=[]     
        #每一百个储存到一个文件中
        self.each=100       
        #直接处理的文件数目
        self.num=0          
        self.htmlph='../store/html' #解决bug 
        #权值 根据 id 从0开始排起  最终通过pagerank进行处理

        #开始初始化 词库
        self.wb=wordbar.Wordbar(self.wbpath)
        
    def run(self):
        '方法运行'
        findWI=self.findWordId
        li=os.listdir(self.htmlph)   #取得分词xml地址
        #!!!!!!!!!!!!!!此处原先有bug  wordsplit中的文件比html少很多  为了保持完备性，应该以html中文件数目为原型进行遍历
        length=len(li)
        for doc in range(length):
            print doc
            #对每个文件进行处理
            #print self.docph+doc
            try:
                f=open(self.docph+'/'+str(doc))
                c=f.read()
                f.close()
            except:
                print 'no file',doc
                continue
            tags=c.split('@chunwei@')
            #print 'the tags is'
            #print tags
            abspos=0           #对于每个标签的增值
            for scoid,tag in enumerate(tags):
                #开始分别对每个标签进行处理
                words=tag.split() #取得每个词汇
                for pos,word in enumerate(words):
                    wid=findWI(word)
                    if wid: #保证只有词库中的词才能够被收录
                        self.hitlist.append([wid,doc,scoid,abspos+pos])

    def sortDoc(self):
        '对hit 根据docID进行排序'
        print 'sortDoc'
        #sort=sorter.hitDocSort(self.hitlist)
        #sort.run()

    def sortWid(self):
        '对hit 根据wordID进行排序'
        print 'wortWid'
        sort=sorter.hitWidSort(self.hitlist) #初始化
        sort.run()
        print 'succeed sorted wid'


    def __saveCHits(self):
        self.savehits(self.topath)

    def savehits(self,path):
        '保存hits'
        strr=''
        print 'length of hislist',len(self.hitlist)
        #print self.hitlist
        for i in self.hitlist:
            strr+=str(i[0])+' '+str(i[1])+' '+str(i[2])+' '+str(i[3])+'\n'
        f=open(path,'w')
        f.write(strr)
        f.close()

    def findWordId(self,word):
        '返回词汇的hash值'
        return self.wb.find(word)

if __name__=='__main__':
    index=Indexer('../store/wordsplit','../store/wordbar','../store/hits')
    index.run()

    #根据docID进行排序
    index.sortDoc()
    index.savehits('../store/sorteddochits')

    #根据wordID进行排序
    '''index.sortWid()
    index.savehits('../store/sortedwidhits')'''
    #index.savehits()

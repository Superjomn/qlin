# -*- coding:utf-8 -*-
import sys
import chardet
reload(sys)
sys.setdefaultencoding('utf-8')

#bug：vote2 应该为 vote1 因此应该使用两个vote列表

#rank 和 rank1 交替使用

class Pageranker:

    '''
    pagerank计算
    '''
    #需要生成特定的表

    def __init__(self,sortedurlph,votetoph,votefrph):
        
        '''
        init
        '''
        #得到ruanks的长度
        f=open(sortedurlph)
        lines=f.readlines()
        f.close()

        self.ranklength=len(lines)
        print 'get ranklength',self.ranklength

        #初始化votelist列表
        f=open(votetoph)
        c=f.readlines()
        f.close()

        self.voteTo=[]
        self.voteFr=[]

        self.outnum={} #!!!!!!!!将来需要用数组优化  此处为数组

        for l in c:
            self.voteTo.append(l.split())

        f=open(votefrph)
        c=f.readlines()
        f.close()

        for l in c:
            self.voteFr.append(l.split())

        self.votelen=len(self.voteFr)  #vote的长度

        #page值
        self.ranks=[]
        self.ranks1=[]
        initrank=float(1)/len(self.voteTo)

        #初始设为1/s
        for i in range(self.ranklength):
            self.ranks.append(initrank)
            self.ranks1.append(initrank) #rank1为rank副本

        #初始化每个voter的outN
        self.initN()

    def run(self,num): #无法判断误差  直接使用循环数        

        '''
        计算pagerank主程序 循环一定次数
        '''
        index=0

        while index<num:
            print 'the',index,'run'
            self.percal()
            index+=1


    def percal(self):

        '''
        一次计算
        '''
        #从to入手 遍历每一个记录
        print 'run now'
        last=0

        for i,vote in enumerate(self.voteTo):
            #print i
            last=int(vote[1])#记录本次处理过的记录 防止重复
            v=[]
            v.append(vote[0])
            j=i+1
            #遍历产生投票数列

            while j<self.votelen and self.voteTo[j][1]==last:
                v.append(self.voteTo[j][0])
                j+=1

            #开始计算rank
            sumvote=0

            for vote in v:
                #计算其他网页投票的rank
                sumvote+=self.ranks[int(vote)]/self.outnum[int(vote)]

            self.ranks1[last]=self.ranks[last]+sumvote

        #rank总和恢复1
        ranksum=0

        for rank in self.ranks1:
            ranksum+=rank

        print 'the sum is',ranksum

        for i,rank in enumerate(self.ranks1):
            self.ranks1[i]=rank/ranksum
            
        #将rank1更新为ranks1
        self.prequal()
    
    def initN(self):
        '计算投票的page外出链接的数目'
        #与voteFr有关
        #考虑到顺次遍历 将生成初始表
        print 'init N'
        self.outnum={}
        length=len(self.voteFr)
        hasvoted='-1' #初始 已经处理的为-1

        for i,vote in enumerate(self.voteTo):
            #bug? 重复计算了
            #如果已经处理过 跳过

            if hasvoted==vote[0]:
                continue

            #print 'vote ...',vote[0]
            last=int(vote[0]) #from 记录本次投票方 防止重复
            outlinknum=1
            j=i+1

            while j<length and self.voteFr[j][0]==last:
                outlinknum+=1
                j+=1

            self.outnum.setdefault(last,outlinknum)  #!!!!!!!!此处将来需要用数组进行优化
            hasvoted=vote[0]



    def prequal(self):

        '''
        将两个ranks 更新为 ranks1
        '''

        for i,vote in enumerate(self.ranks1):
            self.ranks[i]=vote



    def save(self,ph):

        '''
        save
        '''

        print 'start to save'
        print 'get length',len(self.ranks)
        strr=''

        for rank in self.ranks:
            strr+=str(rank)+'\n'

        f=open(ph,'w')
        f.write(strr)
        f.close()



if __name__=='__main__':
    ranker=Pageranker('../store/sortedurls.txt','../store/votetolist','../store/voteflist')
    ranker.run(58)
    ranker.save('../store/pageranker')


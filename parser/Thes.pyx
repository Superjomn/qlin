'''
Created on May 19, STEP11

@author: chunwei
'''
#需要添加进动态内存管理
#但似乎动态管理不可能--词库中char长度不一
#需要提前知道词库大小(可以保存到sqlite)
#本文件包含两个库 建立词库  及新建词库

# *******相关函数可以考虑写为   inline   提供必要接口

#hashIndex 结构

from libc.stdio cimport fopen,fclose,fwrite,FILE,fread

DEF STEP=20

cdef struct HI: 
    int left    #左侧范围
    int right   #右侧范围


cdef class Create_hashIndex:
    '''
    建立一级hash参考表
    使用较复杂的中分法 单独作为一类
    传入 划分数目：  step
    结果将会把完整hash划分为step步
    '''
    cdef: 
        object wlist
        double left     #左侧最小hash
        double right    #右侧最大hash
        int step
        int cur_step
        

    def __cinit__(self,li):
        '''
        init
        '''
        self.wlist=li

    def show(self):

        for d in self.wlist:
            print hash(d),d

    cdef int find(self,double data):
        '''
        具体查取值 
        '''
        #使用更加常规的方式
        cdef:
            int i

        for i,w in enumerate(self.wlist):
            if hash(w)>data:
                return i-1
        #最后一个词汇 
        return len(self.wlist)-1






cdef class init_hashIndex:
    '''
    init he hash index
    '''
    #define the hash index 

    cdef HI hi[STEP]
    cdef:
        #hash的左边界
        double left
        #hash的右边界
        double right

    def __cinit__(self,char *ph,char *wide_ph):
        '''
        init
        '''
        #取得hash边界
        self.get_wide(wide_ph)

        cdef FILE *fp=<FILE *>fopen(ph,"rb")
        fread(self.hi,sizeof(HI),STEP,fp)
        fclose(fp)

    def show(self):

        '''
        显示
        '''
        cdef:
            int i
        for i in range(STEP):
            print self.hi[i].left
            print self.hi[i].right
            print '-'*50

    cdef void get_wide(self,char *ph):
        '''
        取得hash的左右边界
        '''
        f=open(ph)
        c=f.read()
        f.close()
        self.left = float(c.split()[0])
        self.right = float(c.split()[1])

    def pos(self,long hashvalue):
        '''
        pos the word by hashvalue 
        if the word is beyond hash return -1
        else return the pos
        
       '''
        cdef int cur=-1
        
        cdef double step=<double>( (self.right-self.left)/STEP )
        
        return <int>int((hashvalue-self.left)/step)
        





cdef class Create_Thesaurus:
    '''
    新建词库
    '''
    #此处字符串传入方式需要确定

    cdef: 
        char* ph        #词库的存储目录
        #char* widph     #范围的存储目录 
        object li
        #hash参考index的范围定义
        double left
        double right


    def __cinit__(self,char* ph):
        '''
        传入文件目录
        '''
        print 'begin init'

        self.ph=ph
        print 'get ph is',self.ph
        #空词库list
        self.li=[]
    
    def get_words(self):
        '''
        返回 词库 字符串
        '''
        strr = ''
        for i in self.li:
            strr+=i+' '
        return strr
            

    def find(self,word):
        '''
        在list中查找word
        如果查找到 返回True
        如果没有找到 返回False
        '''
        print 'begin find()',word

        #定义变量
        cdef:
            int l
            int first
            int end
            int mid
            int num

        #初始值
        l=len(self.li)
        first=0
        end=l-1
        mid=0
        num=hash(word)

        #print 'the hash of',word,"is",
        #print num
        #print 'the len of self.li is',l
        
        if l==0:
            print 'the list is empty'
            self.li.insert(0,word)
            return False
        
        while first<end:
            mid=(first+end)/2

            if num>hash(self.li[mid]):
                first=mid+1

            elif num<hash(self.li[mid]):
                end=mid-1

            else:
               first=mid
               end=mid

               while hash(self.li[first])==num and first>=0:
                   
                    if self.li[first]==word:
                        return True
                    first-=1

               while hash(self.li[end])==num and end<l:
                   
                    if self.li[end]==word:
                        return True 
                    end=end+1

               self.li.insert(mid+1,word)

               return False
            
        if first==end:
            if hash(self.li[first])>num:
                self.li.insert(first,word)
                return False

            elif hash(self.li[first])<num:
                self.li.insert(first+1,word)
                return False

            else:
                
                if self.li[first]==word:
                    return True

                else:
                    self.li.insert(first+1,word)
                    return False

        elif first>end:
            self.li.insert(first,word)
            return False

        else:
            return True

    def show(self):
        '''
        展示词库
        '''
        for i in self.li:
            print i

    cdef char *get_str(self):
        '''
        保存时使用字符串直接保存
        将self.li转化为str进行保存
        '''
        print 'begin get_str()'
        
        cdef char *str

        strr=''
        for i in self.li:
            strr+=i+' '

        return strr

    def save(self):
        '''
        保存词库
        格式： 直接采用的字符串空格
        '''
        print 'begin to save all the words!'
        print 'the file ph is',self.ph
        print 'str is',self.get_str()

        f=open(self.ph,'w')
        f.write( self.get_str() )
        f.close()

    def save_wide(self,char *widph):
        '''
        保存有关  词库中hahs之范围的两
        格式大概为  min max 
        '''
        print 'begin to save width'
        space=' '
        print 'begin to set hash index in class'
        #赋值给全局量
        self.left=hash( self.li[0] ) 
        self.right=hash( self.li[-1] )
        strr=str( self.left )+ space + str(self.right )
        print 'the width is',strr
        f=open(widph,'w')
        f.write(strr)
        f.close()

    def create_hash(self,char *ph):
        '''
        生成一级索引哈系表
        需要通过动态分配内存的方式？
        '''
        print 'begin create_hash'
        #分为STEP个hashindex表
        cdef: 
            HI hashIndex[STEP]
            int i
            double minidx
            double step   #步长 
            int cur_step

        self.left=hash(self.li[0])
        self.right=hash(self.li[-1])

        #print 'get the step left ',self.left
        #print 'get the step right',self.right

        step=<double>( (self.right-self.left)/STEP )
        

        #初始化 Create_hashIndex
        #产生 hash参考表
        cdef Create_hashIndex cHashIdx=Create_hashIndex(self.li)
        print '传入 系数',self.left,self.right,STEP
        print 'the length of wordbar is',len(self.li)
        #定义初始 index为1
        cur_step = 0

        print 'get the step:',step

        minidx=self.left

        print 'begin the for'

        for i in range(STEP):
            #寻找边界
            print i
            minidx += step
            print 'minidx is ',
            print minidx
            print 'step is',
            print step
            print 'cur_step',cur_step

            hashIndex[i].left=cur_step+1

            hashIndex[i].right=cHashIdx.find(minidx)

            cur_step=hashIndex[i].right
            print 'right is',cur_step
            
            print '>'*50

        print 'begin to save the hash'

        self.save_hash(ph,hashIndex)

    cdef save_hash(self,char *ph,HI *hi):
        '''
        将hash参考表进行保存
        传入 hashindex 数组的指针
        将hash参考index进行传出
        '''
        print 'begin to save hash'
        cdef FILE *fp=<FILE *>fopen(ph,"wb")
        fwrite(hi,sizeof(HI),STEP,fp)
        fclose(fp)
        print 'succeed save hash'
        
        ############# debug #######################
        print 'begin to show the hash'
        cdef int i
        for i in range(STEP):
            print i
            print hi[i].left
            print hi[i].right
            print '-'*50

        




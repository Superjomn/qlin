import os

from libc.stdlib cimport malloc,free

from libc.stdio cimport fopen, fwrite, fread,fclose,FILE

DEF List_init_size = 100  #定义List初始化长度
DEF List_max_size = 1000  #定义List最长长度

DEF List_num = 20         #划分 块 数目


#定义 Hit 结构
cdef struct Hit:
    int wordID
    int docID
    short score
    int pos

#################### Init_Thesaurus from parser/Thesaurus ##################
DEF STEP=20


cdef struct HI: 
    int left    #左侧范围
    int right   #右侧范围


      ############## init_hashIndex  from  Thesaurus.pyx  #########

cdef class init_hashIndex:
    '''
    init he hash index
    '''
    #define the hash index 

    cdef HI hi[STEP]

    def __cinit__(self,char *ph):
        '''
        init
        '''
        cdef FILE *fp=<FILE *>fopen(ph,"rb")
        fread(self.hi,sizeof(HI),STEP,fp)
        fclose(fp)

    def pos(self,double hashvalue):
        '''
        pos the word by hashvalue 
        if the word is beyond hash return -1
        else return the pos
        
        '''
        cdef int cur=-1
        
        if hashvalue>self.hi[0].left:
            cur+=1
        else:
            return cur

        while hashvalue > self.hi[cur].left:

            cur+=1

        return cur

           #################################################


#定义 hashIndex 结构
cdef struct HI: #hashIndex 结构
    int left    #左侧范围
    int right   #右侧范围
    

cdef class Init_thesaurus:
    '''
    初始化词库
    '''
    #使用动态分配内存方式  
    #分配词库内存空间
    cdef char **word_list
    #一级hash 参考表 初始化
    cdef init_hashIndex hashIndex
    #词库长度 由 delloc 调用
    cdef int length

    def __cinit__(self,char *ph):
        '''
        传入词库地址
        初始化词库
        '''
        #一级hash 参考表 初始化
        self.hashIndex = init_hashIndex("sore/hashIndex.b")

        cdef:
            int i
            int l

        f=open(ph)
        words=f.read()
        f.close()

        #词的数量 
        self.length=len(words)
        cdef char  **li=<char **>malloc( sizeof(char *) * self.length )
        if li!=NULL:
            print 'the li is successful'
            self.word_list=li
        else:
            print 'the li is failed'

        #开始对每个词分配内存 
        #并且分配内存
        for i,w in enumerate(words):
            self.word_list[i]=<char *>malloc( sizeof(char) * len(w) )
            self.word_list[i]=w

    def __dealloc__(self):
        '''
        释放c内存空间
        '''
        print 'begin to delete all the C spaces'

        cdef char* point
        cdef int i=0

        #释放每一个词的空间
        for i in range(self.length):
            free(self.word_list[i])

        #释放整个词库 pointer 的空间
        free(self.word_list)


    cdef double v(self,data):
        '''
        将元素比较的属性取出
        '''
        return hash(data)

    def show(self):
        for d in self.wlist:
            print hash(d),d

    def find(self,data):
        '''
        具体查取值 
        若存在 返回位置 
        若不存在 返回   0
        '''
        #需要测试 
        #print 'want to find ',hash(data),data
        cdef:
            int l
            int fir
            int mid
            int end
            int pos
            HI cur  #范围

        dv=self.v(data)     #传入词的hash

        pos=self.hashIndex( dv )

        if pos!=-1 and pos<STEP:
            cur=self.hashIndex.hi[pos]

        else:
            print "the word is not in wordbar or pos wrong"
            return False

        #取得 hash 的一级推荐范围
        fir=cur.left
        end=cur.right
        mid=fir

        while fir<end:
            mid=(fir+ end)/2
            if ( dv > self.v(self.wlist[mid]) ):
                fir = mid + 1
            elif  dv < self.v(self.wlist[mid]) :
                end = mid - 1
            else:
                break

        if fir == end:
            if self.v(self.wlist[fir]) > dv:
                return 0 
            elif self.v(self.wlist[fir]) < dv:
                return 0
            else:
                #print 'return fir,mid,end',fir,mid,end
                return end#需要测试
                
        elif fir>end:
            return 0

        else:
            #print '1return fir,mid,end',fir,mid,end
            return mid#需要测试


#######################  end Init_thusurus ##################################





cdef class Hit_lists:
    '''
    hit存储队列
    每个list对应于一个存储文件
    '''
    cdef:
        int length
        int top
        Hit *hits

    def __cinit__(self):
        '''
        初始化数据空间
        '''
        self.hits=<Hit *>malloc( sizeof(Hit) * List_init_size )
        self.top=-1 #-1代表空
        self.length=List_init_size
        
        if hits != NULL:
            print '>>init list ok!'

    cdef void eq(self,idx,wordID,docID,score,pos):
        '''
        赋值处理
        '''
        self.hits[idx].wordID=wordID
        self.hits[idx].docID=docID
        self.hits[idx].score=score
        self.hits[idx].pos=pos

    cdef bint append(self,wordID,docID,score,pos):
        '''
        向list中添加数据
        如果list溢出 则返回False
        添加成功 返回True
        '''
        top+=1
        eq(self,top,wordID,docID,score,pos)

        if (self.top == length-2):
            #如果 分配长度快到最大长度 则返回false
            #如果 lenth还有空间 继续分配空间
            if (self.length<List_max_size):
                #添加新的空间
                self.hits=<Hit *>realloc(self.hits,sizeof(Hit)*
                        (self.length+List_init_size))
                return True

            else:
                #已经达到最大限度
                return False

        else:
            #空间和其他都不缺少
            #正常情况
            return True

    cdef void empty(self):
        '''
        将List清空
        释放空间
        再重新分配基本空间
        '''
        free(self.hits)
        self.hits=<Hit *>malloc( sizeof(Hit) * List_init_size )


cdef class sorter:
    '''
    最优法排序
    '''
    #hitlist 的私有对象
    cdef Hit *dali 

    def __cinit__(self,Hit *datalist):
        '''
        初始化 
        将hit队列传递为self
        '''
        self.dali=datalist

    cdef double gvalue(self,data):
        '''
        取得值
        '''
        return 

    def quicksort(self,int p,int q):

        cdef int j
        a=self.dali
        st=[]
        while True:
            while p<q:
                j=self.partition(a,p,q)
                if (j-p)<(q-j):
                    st.append(j+1)
                    st.append(q)
                    q=j-1
                else:
                    st.append(p)
                    st.append(j-1)
                    p=j+1
            if(len(st)==0):
                return
            q=st.pop()
            p=st.pop()

    cdef int  partition(self,a,int low,int high):
        #gvalue=self.gvalue
        v=a[low]
        while low<high:
            while low<high and self.gvalue( a[high] ) >= self.gvalue( v ):
                high-=1
            a[low]=a[high]

            while low<high and self.gvalue( a[low] )<=self.gvalue( v ):
                low+=1
            a[high]=a[low]

        a[low]=v
        return low

    def showlist(self):
        for i in self.dali:
            print i



cdef class Indexer:
    '''
    索引器
    '''
    #文件目录地址
    cdef char *ph
    cdef Hit_lists hit_list[List_num]

    def __cinit__(self,ph):
        '''
        init
        ph: wordsplit文件目录地址
        '''
        self.ph=ph
        self.hit_list=[]

    cdef loc_list(self):
        '''
        传入一个word
        定位 其 应该存在的 list 
        可以继承 词库 
        '''
        #???????????????????????????????

    def run(self):
        '''
        运行主程序
        '''
        cdef:
            int list_idx    #定位 list 的号码

        li=os.listdir(self.ph)
        length=len(li)

        for doc in li:
            f=open(self.ph+'/'+fl)
            c=f.read()
            f.close()

            tags=c.split('@chunwei@')
            abspos=0
            for scoid,tag in enumerate(tags):
                #对每个标签进行处理
                words=tag.split()
                for pos,word in enumerate(words):
                    wid=findWI(word)
                    
                    #定位 list号码
                    list_idx=self.loc_list(word)

                    if wid:
                        if self.hit_list[list_idx].add(word):
                            continue
                        else:
                            #将 list_idx 对应的list写入到文件
                            self.add(list_idx)
                            #将相应list清空
                            self.hit_list[list_idx].empty()

    cdef sort(self):
        '''
        将结果逐个进行排序
        '''

    cdef int add(self,int list_idx):
        '''
        将相关内容添加到文件中 
        '''
        cdef FILE *fp=<FILE *>fopen(self.toph,"wb")
        #此处 size 需要???????????????????????????????????????
        fwrite(hi,sizeof(Hit),List_max_size,fp)
        fclose(fp)


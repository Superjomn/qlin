cimport os

from libc.stdlib cimport malloc,realloc,free

from libc.stdio cimport fopen, fwrite, fread,fclose,FILE

DEF List_init_size 100  #定义List初始化长度
DEF List_max_size 1000  #定义List最长长度

DEF List_num 20         #划分 块 数目


#定义 Hit 结构
cdef struct Hit:
    int wordID
    int docID
    short score
    int pos

cdef class List:
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

    cdef bool append(self,wordID,docID,score,pos):
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
    cdef object dali

    def __cinit__(self,datalist):

        self.dali=datalist

    cdef double gvalue(self,data):
        '''
        取得值
        '''
        return hash(data[1])

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
    cdef List lists[List_num]

    def __cinit__(self,ph):
        '''
        init
        ph: wordsplit文件目录地址
        '''
        self.ph=ph

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
                        if self.lists[list_idx].add(word)
                            continue
                        else:
                            #将 list_idx 对应的list写入到文件
                            self.add(list_idx)
                            #将相应list清空
                            self.lists[list_idx].empty()

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
        fwrite(hi,sizeof(Hit),List_max_size),fp)
        fclose(fp)


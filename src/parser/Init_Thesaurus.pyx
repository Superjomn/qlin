#定义 hashIndex 结构
cdef struct HI: #hashIndex 结构
    int left    #左侧范围
    int right   #右侧范围
    

cdef class Init_Thesaurus:
    '''
    词库设计:
        本库旨在设计一个与Query库相通的高效词库查询系统
        采用Cython和C优化  甚至可以放弃类结构
        加入一级hash表加速

    解释：
        一级hash表
            所在词在词库中的大概位置范围
            为了安全地分开正数和负数 将参考表分为两个表
            一正 一负
    '''

    #词库词量
    cdef word_num=10000
    #一级hash索引范围数目
    cdef index_pos_num=20   #正数 index 参考数
    cdef index_neg_num=20   #负数 index 参考数

    #定义词库数组
    cdef char* wlist[word_num]
    #定义hash索引范围参考数组
    cdef HI hash_index[index_num]
    
    def __cinit__(self,ph):
        '''
        提供公共文件地址
        '''
        f=open(ph)
        #是 split 还是 readlines 需要由词库存储格式而定
        cdef:
            int i
            char *l

        for i,l in enumerate(f.readlines()):
            #可以考虑将wordbar内置为类属性
            self.wlist[i]=i
        f.close()

    cdef void initHashIndex(self):
        '''
        初始化 一级hash范围参考表
        '''
        #需要同时初始化两个表
        #一正  一负
        #*****************

    cdef HI hashIndex(self,double hv):
        '''
        输入hash 返回一级hash表中对应在词库中index范围
        ---由find()调用
        '''
        #????取得词库中最小hash值 词库生成的时候储存于sqlite中
        cdef hash_width=10000
        if hv>0:
            return self.pos_index[int( hv/hash_width )]

        else:
            return self.neg_index[int( -hv/hash_width )]

        #****************

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
            HI cur  #范围

        l=len(self.wlist)
        dv=self.v(data)     #传入词的hash
        #取得 hash 的一级推荐范围
        cur=self.hashIndex(dv)
        #fir=0
        #end=l-1
        #mid=0
        #赋值范围
        fir=cur.left
        end=cur.right
        mid=fir

        if l == 0:
            return 0#空

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



'''
Created on May 19, 2011

@author: chunwei
'''
#需要添加进动态内存管理
#但似乎动态管理不可能--词库中char长度不一
#需要提前知道词库大小(可以保存到sqlite)
#本文件包含两个库 建立词库  及新建词库

# *******相关函数可以考虑写为   inline   提供必要接口

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

    def int find(self,data):
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



cdef class Create_Thesaurus:
    '''
    新建词库
    '''
    #此处字符串传入方式需要确定

    cdef char* fp
    cdef object li

    def __cinit__(self,char* ph):
        '''
        传入文件目录
        '''
        print 'begin init'

        self.ph=ph
        #空词库list
        self.li=[]

    def find(self,word):
        '''
        在list中查找word
        如果查找到 返回True
        如果没有找到 返回False
        '''
        print 'begin find()'

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

        print 'the hash of',word,"is",
        print num
        print 'the len of self.li is',l
        
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

    cdef char *get_str():
        '''
        保存时使用字符串直接保存
        将self.li转化为str进行保存
        '''
        print 'begin get_str()'

        cdef char* strr
        strr=''
        cdef char *i

        for i in self.li:
            strr+=i

        return strr

    def save(self):
        '''
        保存词库
        格式： 直接采用的字符串空格
        '''
        print 'begin to save all the words!'

        f=open(self.ph,'w')
        f.write( self.get_str() )
        f.close()


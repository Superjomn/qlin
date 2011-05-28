cdef class Wordlist:
    '''
    生成唯一的wordlist 可以同时搜寻word
    '''
    cdef object li #cython继承似乎不行 单独创建list
    def __cinit__(self):
        self.li=[]

    def find(self,word):
        '''
        在list中查找word
        如果查找到 返回Treu
        如果没有找到 返回False
        '''
        #定义变量
        cdef int l
        cdef int first
        cdef int end
        cdef int mid
        cdef int num
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
        for i in self.li:
            print i


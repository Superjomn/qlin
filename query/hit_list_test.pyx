
from libc.stdio cimport fopen, fwrite, fread,fclose,FILE 
from libc.stdlib cimport realloc,malloc,free

cdef struct Hit:
    int wordID
    int docID
    short score
    int pos


cdef class  hit_list:
   
    cdef:
        int ind
   
    cdef Hit *hit_list

    cdef int length
    
    def __cinit__(self,int ind):
        self.ind=ind

    def read_wide(self):
        f=open('store/hits/hit_size.txt')
        c=f.read().split()
        f.close()
        self.length=int(c[self.ind])
        print 'get length',self.length
        self.hit_list=<Hit *>malloc(sizeof(Hit)*self.length)


    def test(self):
        cdef:
            char *fn

        fname = 'store/hits/' + str(self.ind) + '.hit'
        print 'fname is',fname
        fn = fname
        fp=<FILE *>fopen(fn,"rb")
        fread(self.hit_list , sizeof(Hit), self.length ,fp)
        fclose(fp)


    def show(self):
        self.read_wide()
        self.test()

        print 'begin to show it'
        print 'get length',self.length
        for i in range(self.length):
            print i,self.hit_list[i].wordID,self.hit_list[i].docID






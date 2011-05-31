cdef class hello:
    def __cinit__(self):
        '''
        init
        '''
        f=open('../store/wordBar')
        c=f.read()
        f.close()

        print 'start to print the words'

        for w in c.split():
            print w



hellol=hello()

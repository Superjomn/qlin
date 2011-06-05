from libc.stdlib cimport malloc,free

cdef char **wlist = <char **>malloc ( sizeof(char *) * length)

f=open('store/wordBar')
c=f.read()
f.close()

words=c.split()

cdef int length = len(words)


def hello():

    cdef:
        int i
    print 'begin malloc'
    
    for i in range( length ):
        wlist[i] = words[i]

    print 'malloc ok'

def show():
    cdef:
        int i

    for i in range(length):
        print wlist[i]




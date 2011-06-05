# -*- coding: utf-8 -*-
import sys
import chardet
reload(sys)
sys.setdefaultencoding('utf-8')
import ictclas
#ictclas.import_dict('./userdict.txt',eCodeType.UTF8)
class Ictclas:
    def __init__(self,basepath='./'):
        ictclas.ict_init(basepath)

    def __del__ (self):
        ictclas.ict_exit()

    def split(self,s):
        #print '--------------split----------------'
        #print chardet.detect(s)
        length=len(s)
        #print s
        li=ictclas.process_str_ret_list(s,length,ictclas.eCodeType.UTF8)

        str=''
        for i in li:
            #print i.iStartPos
            str=str+s[i.iStartPos:(i.iStartPos+i.iLength)]+' '
        return str

if __name__=='__main__':
    c=Ictclas()
    words = c.split('中国你好')
    print words.split()

    for w in words.split():
        print w


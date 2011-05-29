# -*- coding: utf-8 -*-
#!/usr/bin/env python
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

    def wsplit(self,s):
        length=len(s)
        li=ictclas.process_str_ret_list(s,length,ictclas.eCodeType.UNKNOW)
        str=''
        for i in li:
            str=str+s[i.iStartPos:(i.iStartPos+i.iLength)]+' '
        return str

if __name__=='__main__':
    c=Ictclas()
    print c.wsplit('hello world,i am chunwei 中国农业大学欢迎您！')

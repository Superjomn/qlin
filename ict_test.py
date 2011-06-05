
# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')




from ICTCLAS50.Ictclas import Ictclas

import chardet as cdt

ict=Ictclas('ICTCLAS50/') 

words = ict.split("中国农业大学")

print words

for w in words:
    print w
    print cdt.detect(w)

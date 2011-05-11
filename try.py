# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import chardet
from pyquery import PyQuery as pq

html=pq(url='http://www.cau.edu.cn')
text=html.text()
print text.encode('utf8')
#print text.encode('utf8')
#print chardet.detect(a)
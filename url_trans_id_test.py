# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

from parser.UrlTransID import UrlTransDir

urlTransDir = UrlTransDir('store/sorted_url.txt')

urlTransDir.renameDoc('store/wordsplit')







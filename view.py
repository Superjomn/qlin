# -*- coding: utf-8 -*-

from django.template.loader import get_template
from django.template import Context
from django.http import HttpResponse

import Query

query = Query.Res_Query()




def hello(request):
    t = get_template('hello.html')
    html = t.render( Context({'title':'hello Lavender','content':'I will marry you!'} ) )
    return HttpResponse(html)



def index(request):

    '''
    首页
    '''
    t = get_template('index.html')
    html = t.render(Context({}))
    return HttpResponse(html)



def search(request):
    
    '''
    搜索主程序
    '''
    t = get_template('search.html')

    if 'query_text' in request.GET:

        if 'page' in request.GET:
            page = int(request.GET['page'])
            print 'get page',page

            if page < 0:
                page = 1

        else:
            page = 1

        print 'final page',page

        text = request.GET['query_text'] 

        result = query.gres( text, page)

        Per_page = 8 

        page_num = result['length']/Per_page
        if result['length'] > Per_page * page_num:
            page_num += 1
        
        print 'get pagenum',page_num

        if result:
            result.setdefault('query_text',text)

            words = text.split()
            strr = ''

            if len(words)>1:
                for w in words[:-1]:
                    strr+=w+'+'
                strr+=words[-1]
                print 'the query word is',strr
            else:
                strr=text

            result.setdefault('url_text',strr)
            result.setdefault('page_num',page_num)
            result.setdefault('page',page)


        else:
            result = {}
            result.setdefault('query_text',text)
            result.setdefault('length',0)
            result.setdefault('res_list',[])
                   #print result
        html = t.render( Context( result ) )

        return HttpResponse(html)

    else:
        message = 'You submitted an empty form'

    return HttpResponse(message)

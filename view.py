# -*- coding: utf-8 -*-

from django.template.loader import get_template
from django.template import Context
from django.http import HttpResponse

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
    if 'query_text' in request.GET:
        message = 'You searched for : %r' % request.GET['query_text']
    else:
        message = 'You submitted an empty form'

    return HttpResponse(message)

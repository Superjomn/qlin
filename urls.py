from django.conf.urls.defaults import patterns, include, url
from qlin.view import *

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('',
    ('^hello/$',hello),
    ('^index/$',index),
    ('^search/$',search),
    # Examples:
    # url(r'^$', 'qlin.views.home', name='home'),
    # url(r'^qlin/', include('qlin.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
)

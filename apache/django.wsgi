import os
import sys
 
sys.path.append('～')
sys.path.append('～/qlin')
  
os.environ['DJANGO_SETTINGS_MODULE']='qlin.settings'
   
import django.core.handlers.wsgi
    
application=django.core.handlers.wsgi.WSGIHandler()

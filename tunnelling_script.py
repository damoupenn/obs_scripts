#! /bin/bash

import os

user = 'damo'
padloper = '196.24.41.252'
stillnet = '192.168.216.'

for i in range(5):
    stillhost = 'still%d'%(i+1)
    still_ip = stillnet + str([112,113,114,115,110][i])
    sh_port = 2001+i 
    om_port = 3001+i
    print 'Forwarding to %s (IP %s), through port %d:' % (stillhost,still_ip,om_port)
    command1 = 'ssh -f -c 3des -p 2222 %s@%s -L %d/%s/22 sleep 5 >/dev/null' % (user,padloper,sh_port,still_ip)
    print '\t$',command1
    os.system(command1)
    os.system('2>/dev/null')
    print '\t\tWaiting for connection to establish'
    os.system('sleep 5')
    command2 = 'ssh -f -c 3des -p %d obs@localhost -L %d/%s/1311 sleep 5 >/dev/null' %(sh_port,om_port,still_ip)
    print '\t$',command2
    os.system(command2)
    os.system('2>/dev/null')
    print '\t\tWaiting for connection to establish'
    os.system('sleep 5')
    print
    print "------------------------------------------------------------------------------"
    print "Visit 'https://localhost:%d' in your favourite browser to view web interface" % om_port
    print "------------------------------------------------------------------------------"
    print

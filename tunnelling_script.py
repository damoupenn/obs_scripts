1
    os.system(command1)
    print '\t\tWaiting for connection to establish'
    os.system('sleep 5')
    command2 = 'ssh -f -c 3des -p %d obs@localhost -L %d/%s/1311 sleep 5 >/dev/null' %(sh_port,om_port,still_ip)
    print '\t$',command2
    os.system(command2)
    print '\t\tWaiting for connection to establish'
    os.system('sleep 5')
    print
    print "------------------------------------------------------------------------------"
    print "Visit 'https://localhost:%d' in your favourite browser to view web interface" % om_port
    print "------------------------------------------------------------------------------"
    print

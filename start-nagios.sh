#!/bin/sh

#if [ ! -f ${NAGIOS_HOME}/etc/htpasswd.users ] ; then
#  htpasswd -c -b -s ${NAGIOS_HOME}/etc/htpasswd.users ${NAGIOSADMIN_USER} ${NAGIOSADMIN_PASS}
#  chown -R nagios.nagios ${NAGIOS_HOME}/etc/htpasswd.users
#fi

exec ${NAGIOS_HOME}/bin/nagios ${NAGIOS_HOME}/etc/nagios.cfg

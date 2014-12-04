FROM softeu/ubuntu-base

MAINTAINER Jindrich Vimr <jvimr@softeu.com>

RUN apt-get install -y iputils-ping netcat build-essential msmtp

RUN cd /usr/src && mkdir nagios3 && cd /usr/src/nagios3 && wget 'http://downloads.sourceforge.net/project/nagios/nagios-3.x/nagios-3.5.1/nagios-3.5.1.tar.gz' && tar -xzf nagios-3.5.1.tar.gz

ENV NAGIOS_HOME /opt/nagios
ENV NAGIOS_USER nagios
ENV NAGIOS_GROUP nagios
ENV NAGIOS_CMDUSER nagios
ENV NAGIOS_CMDGROUP nagios
ENV NAGIOSADMIN_USER nagiosadmin
ENV NAGIOSADMIN_PASS HeslooHesloo123

RUN ( egrep -i  "^${NAGIOS_GROUP}" /etc/group || groupadd -g 1001 $NAGIOS_GROUP ) && ( egrep -i "^${NAGIOS_CMDGROUP}" /etc/group || groupadd $NAGIOS_CMDGROUP )

RUN  id -u $NAGIOS_USER || echo "nagios user does not exist"
RUN ( id -u $NAGIOS_USER || useradd --system $NAGIOS_USER -g $NAGIOS_GROUP -d $NAGIOS_HOME -u 1001 ) && ( id -u $NAGIOS_CMDUSER || useradd --system -d $NAGIOS_HOME -g $NAGIOS_CMDGROUP $NAGIOS_CMDUSER )

RUN  id -u $NAGIOS_USER

RUN mkdir -p /etc/apache2/conf.d/

RUN cd /usr/src/nagios3/nagios   && ./configure --prefix=${NAGIOS_HOME} --exec-prefix=${NAGIOS_HOME} --enable-event-broker --with-nagios-command-user=${NAGIOS_CMDUSER} --with-command-group=${NAGIOS_CMDGROUP} --with-nagios-user=${NAGIOS_USER} --with-nagios-group=${NAGIOS_GROUP} && make all && make install && make install-init && make install-config && make install-commandmode && cp sample-config/httpd.conf /etc/apache2/conf.d/nagios.conf



RUN cd /usr/src/nagios3 && wget 'http://nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz' && tar -xzf nagios-plugins-2.0.3.tar.gz && cd nagios-plugins-2.0.3 && ./configure --prefix=${NAGIOS_HOME} && make && make install

RUN ln -s ${NAGIOS_HOME}/bin/nagios /usr/local/bin/nagios && ln -s ${NAGIOS_HOME}/etc/ /etc/nagios3

RUN mkdir -p ${NAGIOS_HOME}/etc/conf.d && mkdir -p ${NAGIOS_HOME}/etc/monitor 
RUN echo "cfg_dir=${NAGIOS_HOME}/etc/conf.d" >> ${NAGIOS_HOME}/etc/nagios.cfg
#RUN echo "cfg_dir=${NAGIOS_HOME}/etc/monitor" >> ${NAGIOS_HOME}/etc/nagios.cfg

VOLUME /opt/nagios/var
VOLUME /opt/nagios/etc
VOLUME /opt/nagios/libexec

ADD start-nagios.sh /

ENV MAIL_HOST 172.17.42.1

ADD msmtprc /etc/msmtprc



RUN ln -s /usr/bin/msmtp /bin/mail

CMD ["/start-nagios.sh" ]

#! /bin/sh
### BEGIN INIT INFO
# Provides:          fleet-service
# Required-Start:    redis-server mysql
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: fleet service start
# Description:       fleet service start
### END INIT INFO

SERVICE_NAME=fleet-service
PATH=/bin:/usr/bin:/sbin:/usr/sbin
DAEMON=/opt/fleet/fleet-run.sh
PIDFILE=/var/run/fleet-run.pid

test -x $DAEMON || exit 0

. /lib/lsb/init-functions

case "$1" in
  start)
     log_daemon_msg "Starting $SERVICE_NAME"
     start_daemon -p $PIDFILE $DAEMON
     log_end_msg $?
   ;;
  stop)
     log_daemon_msg "Stopping $SERVICE_NAME"
     killproc -p $PIDFILE $DAEMON
     PID=`ps x |grep feed | head -1 | awk '{print $1}'`
     kill -9 $PID       
     log_end_msg $?
   ;;
  force-reload|restart)
     $0 stop
     $0 start
   ;;
  status)
     status_of_proc -p $PIDFILE $DAEMON fleet-service && exit 0 || exit $?
   ;;
 *)
   echo "Usage: /etc/init.d/fleet-service {start|stop|restart|force-reload|status}"
   exit 1
  ;;
esac

exit 0
#!/bin/bash
# 
#database backup script
TIME="$(date +"%Y-%m-%d")"
FILENAME=ewcms_rc_$TIME
TMPDIR=/home/backup
TMPFILE=${TMPDIR}/$FILENAME.dmp
BAKFILE=${TMPDIR}/$FILENAME.tar.gz
USER=postgres
PG_HOME=/db/pgsql
DUMP=${PG_HOME}/bin/pg_dumpall
echo "start backup database..."
su - postgres -c ${DUMP} > ${TMPFILE}
echo "backup database end."
echo "start tar database file..."
cd ${TMPDIR}
tar -zcf ${BAKFILE} .
echo "tar database file end."
echo "start delete database tmp..."
rm -f ${TMPFILE}
echo "delete database tmp end."

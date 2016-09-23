#!/bin/bash

# v 0.3:  
#    Merge pg_*_slave_install.sh to pg_*_install.sh (2016-05-26)
#
# v 0.2:  
#    Add pgsql-9.4 and pgsql-9.5 install (2016-05-24)
#
# v 0.1:   
#    Add pgsql-9.3 install (2015-08-31)

if [ "$#" -ne "2" ] ; then
  echo "Usage $0 $1 $2"
  echo "Usage pg_6_install.sh {master|slave} {9.3|9.4|9.5}"
  exit 1
fi

pg_data_dir="/data/pgsql/"$2"/data"
pg_sock_dir="/var/run/postgresql"

if [ "$2" = "9.3" ] ; then
  ## create psql repo
  rpm -ivh http://yum.postgresql.org/"$2"/redhat/rhel-6-x86_64/pgdg-centos93-"$2"-2.noarch.rpm

  ## install postgresql
  yum install -y postgresql93 postgresql93-contrib postgresql93-libs postgresql93-server
  if [ "$?" -ne "0" ] ; then
    exit 1
  fi

  ## create log dir
  if [ ! -d $pg_data_dir ] ; then
    mkdir -p $pg_data_dir
    chown -R postgres.postgres $pg_data_dir
    chmod 700 $pg_data_dir
  fi

  ## change init script for centos-6.x
  sed -ir 's#var/lib#data#g' /etc/init.d/postgresql-"$2"

  if [ "$1" = "master" ] ; then
    ## init db for centos-6.x
    service postgresql-"$2" initdb
    
    ## copy pg file
    cp ./postgresql_master.conf $pg_data_dir/postgresql.conf && chown postgres.postgres $pg_data_dir/postgresql.conf
    cp ./pg_hba.conf $pg_data_dir/ && chown postgres.postgres $pg_data_dir/pg_hba.conf
    
    ## start service for centos-6.x
    chkconfig postgresql-"$2" on
    service postgresql-"$2" start
    
    ## add replication user
    su - postgres -c 'psql -c "CREATE ROLE repl login replication password '\'repl\''"'

  elif [ "$1" = "slave" ] ; then 
    ## postgresql base backup
    echo please input psql master ip :
    read ip
    su - postgres -c "/usr/pgsql-"$2"/bin/pg_basebackup -D /data/pgsql/"$2"/data/ -Fp -Xs -v -P -R -h $ip -U repl -p 5432"
  
    ## copy pg file
    cp ./postgresql_slave.conf $pg_data_dir/postgresql.conf && chown postgres.postgres $pg_data_dir/postgresql.conf
    cp ./pg_hba.conf $pg_data_dir/ && chown postgres.postgres $pg_data_dir/pg_hba.conf
  
    ## start service for centos-6.x
    chkconfig postgresql-"$2" on
    service postgresql-"$2" start
  fi

elif [ "$2" = "9.4" ] ; then
  ## create psql repo
  rpm -ivh http://yum.postgresql.org/"$2"/redhat/rhel-6-x86_64/pgdg-centos94-"$2"-2.noarch.rpm

  ## install postgresql
  yum install -y postgresql94 postgresql94-contrib postgresql94-libs postgresql94-server
  if [ "$?" -ne "0" ] ; then
    exit 1
  fi

  ## create log dir
  if [ ! -d $pg_data_dir ] ; then
    mkdir -p $pg_data_dir
    chown -R postgres.postgres $pg_data_dir
    chmod 700 $pg_data_dir
  fi

  ## change init script for centos-6.x
  sed -ir 's#var/lib#data#g' /etc/init.d/postgresql-"$2"
  
  if [ "$1" = "master" ] ; then
    ## init db for centos-6.x
    service postgresql-"$2" initdb
   
    ## copy pg file
    cp ./postgresql_master.conf $pg_data_dir/postgresql.conf && chown postgres.postgres $pg_data_dir/postgresql.conf
    #echo "unix_socket_directories = '/var/run/postgresql, /tmp'" >> $pg_data_dir/postgresql.conf
    cp ./pg_hba.conf $pg_data_dir/ && chown postgres.postgres $pg_data_dir/pg_hba.conf
    if [ ! -d $pg_sock_dir ] ; then
      mkdir -p $pg_sock_dir
      chown -R postgres.postgres $pg_sock_dir
    fi    

    ## start service for centos-6.x
    chkconfig postgresql-"$2" on
    service postgresql-"$2" start
    
    ## add replication user
    su - postgres -c 'psql -c "CREATE ROLE repl login replication password '\'repl\''"'

  elif [ "$1" = "slave" ] ; then
    ## postgresql base backup
    echo please input psql master ip :
    read ip
    su - postgres -c "/usr/pgsql-"$2"/bin/pg_basebackup -D /data/pgsql/"$2"/data/ -Fp -Xs -v -P -R -h $ip -U repl -p 5432"
  
    ## copy pg file
    cp ./postgresql_slave.conf $pg_data_dir/postgresql.conf && chown postgres.postgres $pg_data_dir/postgresql.conf
    #echo "unix_socket_directories = '/var/run/postgresql, /tmp'" >> $pg_data_dir/postgresql.conf
    cp ./pg_hba.conf $pg_data_dir/ && chown postgres.postgres $pg_data_dir/pg_hba.conf

    if [ ! -d $pg_sock_dir ] ; then
      mkdir -p $pg_sock_dir
      chown -R postgres.postgres $pg_sock_dir
    fi
  
    ## start service for centos-6.x
    chkconfig postgresql-"$2" on
    service postgresql-"$2" start
  fi

elif [ "$2" = "9.5" ] ; then
  ## create psql repo
  rpm -ivh http://yum.postgresql.org/"$2"/redhat/rhel-6-x86_64/pgdg-centos95-"$2"-2.noarch.rpm

  ## install postgresql
  yum install -y postgresql95 postgresql95-contrib postgresql95-libs postgresql95-server
  if [ "$?" -ne "0" ] ; then
    exit 1
  fi

  ## create log dir
  if [ ! -d $pg_data_dir ] ; then
    mkdir -p $pg_data_dir
    chown -R postgres.postgres $pg_data_dir
    chmod 700 $pg_data_dir
  fi

  ## change init script for centos-6.x
  sed -ir 's#var/lib#data#g' /etc/init.d/postgresql-"$2"

  if [ "$1" = "master" ] ; then
    ## init db for centos-6.x
    service postgresql-"$2" initdb
  
    ## copy pg file
    cp ./postgresql_master.conf $pg_data_dir/postgresql.conf && chown postgres.postgres $pg_data_dir/postgresql.conf
    #echo "unix_socket_directories = '/var/run/postgresql, /tmp'" >> $pg_data_dir/postgresql.conf
    cp ./pg_hba.conf $pg_data_dir/ && chown postgres.postgres $pg_data_dir/pg_hba.conf
    if [ ! -d $pg_sock_dir ] ; then
      mkdir -p $pg_sock_dir
      chown -R postgres.postgres $pg_sock_dir
    fi
  
    ## start service for centos-6.x
    chkconfig postgresql-"$2" on
    service postgresql-"$2" start
  
    ## add replication user
    su - postgres -c 'psql -c "CREATE ROLE repl login replication password '\'repl\''"'

  elif [ "$1" = "slave" ] ; then
    ## postgresql base backup
    echo please input psql master ip :
    read ip
    su - postgres -c "/usr/pgsql-"$2"/bin/pg_basebackup -D /data/pgsql/"$2"/data/ -Fp -Xs -v -P -R -h $ip -U repl -p 5432"
  
    ## copy pg file
    cp ./postgresql_slave.conf $pg_data_dir/postgresql.conf && chown postgres.postgres $pg_data_dir/postgresql.conf
    #echo "unix_socket_directories = '/var/run/postgresql, /tmp'" >> $pg_data_dir/postgresql.conf
    cp ./pg_hba.conf $pg_data_dir/ && chown postgres.postgres $pg_data_dir/pg_hba.conf

    if [ ! -d $pg_sock_dir ] ; then
      mkdir -p $pg_sock_dir
      chown -R postgres.postgres $pg_sock_dir
    fi
  
    ## start service for centos-6.x
    chkconfig postgresql-"$2" on
    service postgresql-"$2" start
  fi
fi

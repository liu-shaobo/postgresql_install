#!/bin/bash

<<<<<<< HEAD
# v 0.5:
#    Add pgsql-9.6 install (2016-11-14)
#
=======
>>>>>>> origin/master
# v 0.4:
#    Merge postgresql.conf and pg_hba.conf to pg_*_install.sh (2016-09-29)
#
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
  echo "Usage pg_7_install.sh {master|slave} {9.3|9.4|9.5}"
  exit 1
fi

pg_data_dir="/data/pgsql/"$2"/data"
pg_sock_dir="/var/run/postgresql"

if [ "$2" = "9.3" ] ; then
  ## create psql repo
  rpm -ivh http://yum.postgresql.org/"$2"/redhat/rhel-7-x86_64/pgdg-centos93-"$2"-2.noarch.rpm
  
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
  
  ## change init script for centos-7.x
  sed -ir 's#var/lib#data#g' /usr/lib/systemd/system/postgresql-"$2".service

  if [ "$1" = "master" ] ; then
    ## init db for centos-7.x
    /usr/pgsql-"$2"/bin/postgresql93-setup initdb
    
    ## create pg file
    echo -e "listen_addresses = '*'\nmax_connections = 100\nshared_buffers = 128MB\nwork_mem = 4MB\nmaintenance_work_mem = 64MB\neffective_io_concurrency = 10\nwal_level = hot_standby\nfsync = off\nmax_wal_senders = 10\nwal_keep_segments = 64\nwal_sender_timeout = 60s\nlog_destination = 'csvlog'\nlogging_collector = on\nlog_directory = 'pg_log'\nlog_filename = 'postgresql-%Y-%m-%d.log'\nlog_truncate_on_rotation = on\nlog_rotation_age = 1d\nlog_rotation_size = 0\nlog_min_duration_statement = 1s\nlog_line_prefix = '< %m >'\nlog_statement = 'all'\nlog_timezone = 'PRC'\ndatestyle = 'iso, mdy'\ntimezone = 'PRC'\nlc_messages = 'en_US.UTF-8'\nlc_monetary = 'en_US.UTF-8'\nlc_numeric = 'en_US.UTF-8'\nlc_time = 'en_US.UTF-8'\ndefault_text_search_config = 'pg_catalog.english'" > $pg_data_dir/postgresql.conf

    ## create access authentication file
    echo "local   all             all                             trust" > $pg_data_dir/pg_hba.conf
    read -p "please input cidr address,Examples: (192.168.1.0/24) : " cidr_address
    echo -e "host    all             all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    echo -e "host    replication     all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    
    ## start service for centos-7.x
    systemctl enable postgresql-"$2"
    systemctl start postgresql-"$2"
    
    ## add replication user
    su - postgres -c 'psql -c "CREATE ROLE repl login replication password '\'repl\''"'

  elif [ "$1" = "slave" ] ; then
    ## postgresql base backup
    echo please input psql master ip :
    read master_ip
    su - postgres -c "/usr/pgsql-"$2"/bin/pg_basebackup -D /data/pgsql/"$2"/data/ -Fp -Xs -v -P -R -h $master_ip -U repl -p 5432"
  
    ## create pg file
    echo -e "listen_addresses = '*'\nmax_connections = 200\nshared_buffers = 128MB\nwork_mem = 4MB\nmaintenance_work_mem = 64MB\neffective_io_concurrency = 10\nwal_level = hot_standby\nfsync = off\nmax_wal_senders = 10\nwal_keep_segments = 64\nwal_sender_timeout = 60s\nhot_standby = on\nlog_destination = 'csvlog'\nlogging_collector = on\nlog_directory = 'pg_log'\nlog_filename = 'postgresql-%Y-%m-%d.log'\nlog_truncate_on_rotation = on\nlog_rotation_age = 1d\nlog_rotation_size = 0\nlog_min_duration_statement = 1s\nlog_line_prefix = '< %m >'\nlog_statement = 'all'\nlog_timezone = 'PRC'\ndatestyle = 'iso, mdy'\ntimezone = 'PRC'\nlc_messages = 'en_US.UTF-8'\nlc_monetary = 'en_US.UTF-8'\nlc_numeric = 'en_US.UTF-8'\nlc_time = 'en_US.UTF-8'\ndefault_text_search_config = 'pg_catalog.english'" > $pg_data_dir/postgresql.conf

    ## create access authentication file
    echo "local   all             all                             trust" > $pg_data_dir/pg_hba.conf
    read -p "please input cidr address,Examples: (192.168.1.0/24) : " cidr_address
    echo -e "host    all             all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    echo -e "host    replication     all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
  
    ## start service for centos-7.x
    systemctl enable postgresql-"$2"
    systemctl start postgresql-"$2"
  fi

elif [ "$2" = "9.4" ] ; then
  ## create psql repo
  rpm -ivh http://yum.postgresql.org/"$2"/redhat/rhel-7-x86_64/pgdg-centos94-"$2"-2.noarch.rpm

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

  ## change init script for centos-7.x
  sed -ir 's#var/lib#data#g' /usr/lib/systemd/system/postgresql-"$2".service

  if [ "$1" = "master" ] ; then
    ## init db for centos-7.x
    /usr/pgsql-"$2"/bin/postgresql94-setup initdb
  
    ## create pg file
    echo -e "listen_addresses = '*'\nmax_connections = 200\nshared_buffers = 128MB\nwork_mem = 4MB\nmaintenance_work_mem = 64MB\neffective_io_concurrency = 10\nwal_level = hot_standby\nfsync = off\nmax_wal_senders = 10\nwal_keep_segments = 64\nwal_sender_timeout = 60s\nhot_standby = on\nlog_destination = 'csvlog'\nlogging_collector = on\nlog_directory = 'pg_log'\nlog_filename = 'postgresql-%Y-%m-%d.log'\nlog_truncate_on_rotation = on\nlog_rotation_age = 1d\nlog_rotation_size = 0\nlog_min_duration_statement = 1s\nlog_line_prefix = '< %m >'\nlog_statement = 'all'\nlog_timezone = 'PRC'\ndatestyle = 'iso, mdy'\ntimezone = 'PRC'\nlc_messages = 'en_US.UTF-8'\nlc_monetary = 'en_US.UTF-8'\nlc_numeric = 'en_US.UTF-8'\nlc_time = 'en_US.UTF-8'\ndefault_text_search_config = 'pg_catalog.english'" > $pg_data_dir/postgresql.conf

    #echo "unix_socket_directories = '/var/run/postgresql, /tmp'" >> $pg_data_dir/postgresql.conf
    ## create access authentication file
    echo "local   all             all                             trust" > $pg_data_dir/pg_hba.conf
    read -p "please input cidr address,Examples: (192.168.1.0/24) : " cidr_address
    echo -e "host    all             all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    echo -e "host    replication     all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf

    if [ ! -d $pg_sock_dir ] ; then
      mkdir -p $pg_sock_dir
      chown -R postgres.postgres $pg_sock_dir
    fi

    ## start service for centos-7.x
    systemctl enable postgresql-"$2"
    systemctl start postgresql-"$2"
  
    ## add replication user
    su - postgres -c 'psql -c "CREATE ROLE repl login replication password '\'repl\''"'

  elif [ "$1" = "slave" ] ; then
    ## postgresql base backup
    echo please input psql master ip :
    read master_ip
    su - postgres -c "/usr/pgsql-"$2"/bin/pg_basebackup -D /data/pgsql/"$2"/data/ -Fp -Xs -v -P -R -h $master_ip -U repl -p 5432"
  
    ## copyte pg file
    echo -e "listen_addresses = '*'\nmax_connections = 200\nshared_buffers = 128MB\nwork_mem = 4MB\nmaintenance_work_mem = 64MB\neffective_io_concurrency = 10\nwal_level = hot_standby\nfsync = off\nmax_wal_senders = 10\nwal_keep_segments = 64\nwal_sender_timeout = 60s\nhot_standby = on\nlog_destination = 'csvlog'\nlogging_collector = on\nlog_directory = 'pg_log'\nlog_filename = 'postgresql-%Y-%m-%d.log'\nlog_truncate_on_rotation = on\nlog_rotation_age = 1d\nlog_rotation_size = 0\nlog_min_duration_statement = 1s\nlog_line_prefix = '< %m >'\nlog_statement = 'all'\nlog_timezone = 'PRC'\ndatestyle = 'iso, mdy'\ntimezone = 'PRC'\nlc_messages = 'en_US.UTF-8'\nlc_monetary = 'en_US.UTF-8'\nlc_numeric = 'en_US.UTF-8'\nlc_time = 'en_US.UTF-8'\ndefault_text_search_config = 'pg_catalog.english'" > $pg_data_dir/postgresql.conf
    #echo "unix_socket_directories = '/var/run/postgresql, /tmp'" >> $pg_data_dir/postgresql.conf
    ## create access authentication file
    echo "local   all             all                             trust" > $pg_data_dir/pg_hba.conf
    read -p "please input cidr address,Examples: (192.168.1.0/24) : " cidr_address
    echo -e "host    all             all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    echo -e "host    replication     all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    chown postgres.postgres $pg_data_dir/pg_hba.conf

    if [ ! -d $pg_sock_dir ] ; then
      mkdir -p $pg_sock_dir
      chown -R postgres.postgres $pg_sock_dir
    fi
  
    ## start service for centos-7.x
    systemctl enable postgresql-"$2"
    systemctl start postgresql-"$2"
  fi

elif [ "$2" = "9.5" ] ; then
  ## create psql repo
  rpm -ivh http://yum.postgresql.org/"$2"/redhat/rhel-7-x86_64/pgdg-centos95-"$2"-2.noarch.rpm

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

  ## change init script for centos-7.x
  sed -ir 's#var/lib#data#g' /usr/lib/systemd/system/postgresql-"$2".service

  if [ "$1" = "master" ] ; then
    ## init db for centos-7.x
    /usr/pgsql-"$2"/bin/postgresql95-setup initdb
  
    ## create pg file
    echo -e "listen_addresses = '*'\nmax_connections = 100\nshared_buffers = 128MB\nwork_mem = 4MB\nmaintenance_work_mem = 64MB\neffective_io_concurrency = 10\nwal_level = hot_standby\nfsync = off\nmax_wal_senders = 10\nwal_keep_segments = 64\nwal_sender_timeout = 60s\nlog_destination = 'csvlog'\nlogging_collector = on\nlog_directory = 'pg_log'\nlog_filename = 'postgresql-%Y-%m-%d.log'\nlog_truncate_on_rotation = on\nlog_rotation_age = 1d\nlog_rotation_size = 0\nlog_min_duration_statement = 1s\nlog_line_prefix = '< %m >'\nlog_statement = 'all'\nlog_timezone = 'PRC'\ndatestyle = 'iso, mdy'\ntimezone = 'PRC'\nlc_messages = 'en_US.UTF-8'\nlc_monetary = 'en_US.UTF-8'\nlc_numeric = 'en_US.UTF-8'\nlc_time = 'en_US.UTF-8'\ndefault_text_search_config = 'pg_catalog.english'" > $pg_data_dir/postgresql.conf
    chown postgres.postgres $pg_data_dir/postgresql.conf
    #echo "unix_socket_directories = '/var/run/postgresql, /tmp'" >> $pg_data_dir/postgresql.conf
    ## create access authentication file
    echo "local   all             all                             trust" > $pg_data_dir/pg_hba.conf
    read -p "please input cidr address,Examples: (192.168.1.0/24) : " cidr_address
    echo -e "host    all             all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    echo -e "host    replication     all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    chown postgres.postgres $pg_data_dir/pg_hba.conf

    if [ ! -d $pg_sock_dir ] ; then
      mkdir -p $pg_sock_dir
      chown -R postgres.postgres $pg_sock_dir
    fi

    ## start service for centos-7.x
    systemctl enable postgresql-"$2"
    systemctl start postgresql-"$2"
  
    ## add replication user
    su - postgres -c 'psql -c "CREATE ROLE repl login replication password '\'repl\''"'

  elif [ "$1" = "slave" ] ; then
    ## postgresql base backup
    echo please input psql master ip :
    read master_ip
    su - postgres -c "/usr/pgsql-"$2"/bin/pg_basebackup -D /data/pgsql/"$2"/data/ -Fp -Xs -v -P -R -h $master_ip -U repl -p 5432"
  
    ## copyte pg file
    echo -e "listen_addresses = '*'\nmax_connections = 200\nshared_buffers = 128MB\nwork_mem = 4MB\nmaintenance_work_mem = 64MB\neffective_io_concurrency = 10\nwal_level = hot_standby\nfsync = off\nmax_wal_senders = 10\nwal_keep_segments = 64\nwal_sender_timeout = 60s\nhot_standby = on\nlog_destination = 'csvlog'\nlogging_collector = on\nlog_directory = 'pg_log'\nlog_filename = 'postgresql-%Y-%m-%d.log'\nlog_truncate_on_rotation = on\nlog_rotation_age = 1d\nlog_rotation_size = 0\nlog_min_duration_statement = 1s\nlog_line_prefix = '< %m >'\nlog_statement = 'all'\nlog_timezone = 'PRC'\ndatestyle = 'iso, mdy'\ntimezone = 'PRC'\nlc_messages = 'en_US.UTF-8'\nlc_monetary = 'en_US.UTF-8'\nlc_numeric = 'en_US.UTF-8'\nlc_time = 'en_US.UTF-8'\ndefault_text_search_config = 'pg_catalog.english'" > $pg_data_dir/postgresql.conf

    chown postgres.postgres $pg_data_dir/postgresql.conf
    #echo "unix_socket_directories = '/var/run/postgresql, /tmp'" >> $pg_data_dir/postgresql.conf
    ## create access authentication file
    echo "local   all             all                             trust" > $pg_data_dir/pg_hba.conf
    read -p "please input cidr address,Examples: (192.168.1.0/24) : " cidr_address
    echo -e "host    all             all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    echo -e "host    replication     all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    chown postgres.postgres $pg_data_dir/pg_hba.conf

    if [ ! -d $pg_sock_dir ] ; then
      mkdir -p $pg_sock_dir
      chown -R postgres.postgres $pg_sock_dir
    fi
  
    ## start service for centos-7.x
    systemctl enable postgresql-"$2"
    systemctl start postgresql-"$2"
  fi
<<<<<<< HEAD

elif [ "$2" = "9.6" ] ; then
  ## create psql repo
  rpm -ivh http://yum.postgresql.org/"$2"/redhat/rhel-7-x86_64/pgdg-centos96-"$2"-3.noarch.rpm

  ## install postgresql
  yum install -y postgresql96 postgresql96-contrib postgresql96-libs postgresql96-server
  if [ "$?" -ne "0" ] ; then
    exit 1
  fi

  ## create log dir
  if [ ! -d $pg_data_dir ] ; then
    mkdir -p $pg_data_dir
    chown -R postgres.postgres $pg_data_dir
    chmod 700 $pg_data_dir
  fi

  ## change init script for centos-7.x
  sed -ir 's#var/lib#data#g' /usr/lib/systemd/system/postgresql-"$2".service

  if [ "$1" = "master" ] ; then
    ## init db for centos-7.x
    /usr/pgsql-"$2"/bin/postgresql96-setup initdb
  
    ## create pg file
    echo -e "listen_addresses = '*'\nmax_connections = 100\nshared_buffers = 128MB\nwork_mem = 4MB\nmaintenance_work_mem = 64MB\neffective_io_concurrency = 10\nwal_level = hot_standby\nfsync = off\nmax_wal_senders = 10\nwal_keep_segments = 64\nwal_sender_timeout = 60s\nlog_destination = 'csvlog'\nlogging_collector = on\nlog_directory = 'pg_log'\nlog_filename = 'postgresql-%Y-%m-%d.log'\nlog_truncate_on_rotation = on\nlog_rotation_age = 1d\nlog_rotation_size = 0\nlog_min_duration_statement = 1s\nlog_line_prefix = '< %m >'\nlog_statement = 'all'\nlog_timezone = 'PRC'\ndatestyle = 'iso, mdy'\ntimezone = 'PRC'\nlc_messages = 'en_US.UTF-8'\nlc_monetary = 'en_US.UTF-8'\nlc_numeric = 'en_US.UTF-8'\nlc_time = 'en_US.UTF-8'\ndefault_text_search_config = 'pg_catalog.english'" > $pg_data_dir/postgresql.conf
    chown postgres.postgres $pg_data_dir/postgresql.conf
    #echo "unix_socket_directories = '/var/run/postgresql, /tmp'" >> $pg_data_dir/postgresql.conf
    ## create access authentication file
    echo "local   all             all                             trust" > $pg_data_dir/pg_hba.conf
    read -p "please input cidr address,Examples: (192.168.1.0/24) : " cidr_address
    echo -e "host    all             all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    echo -e "host    replication     all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    chown postgres.postgres $pg_data_dir/pg_hba.conf

    if [ ! -d $pg_sock_dir ] ; then
      mkdir -p $pg_sock_dir
      chown -R postgres.postgres $pg_sock_dir
    fi

    ## start service for centos-7.x
    systemctl enable postgresql-"$2"
    systemctl start postgresql-"$2"
  
    ## add replication user
    su - postgres -c 'psql -c "CREATE ROLE repl login replication password '\'repl\''"'

  elif [ "$1" = "slave" ] ; then
    ## postgresql base backup
    echo please input psql master ip :
    read master_ip
    su - postgres -c "/usr/pgsql-"$2"/bin/pg_basebackup -D /data/pgsql/"$2"/data/ -Fp -Xs -v -P -R -h $master_ip -U repl -p 5432"
  
    ## copyte pg file
    echo -e "listen_addresses = '*'\nmax_connections = 200\nshared_buffers = 128MB\nwork_mem = 4MB\nmaintenance_work_mem = 64MB\neffective_io_concurrency = 10\nwal_level = hot_standby\nfsync = off\nmax_wal_senders = 10\nwal_keep_segments = 64\nwal_sender_timeout = 60s\nhot_standby = on\nlog_destination = 'csvlog'\nlogging_collector = on\nlog_directory = 'pg_log'\nlog_filename = 'postgresql-%Y-%m-%d.log'\nlog_truncate_on_rotation = on\nlog_rotation_age = 1d\nlog_rotation_size = 0\nlog_min_duration_statement = 1s\nlog_line_prefix = '< %m >'\nlog_statement = 'all'\nlog_timezone = 'PRC'\ndatestyle = 'iso, mdy'\ntimezone = 'PRC'\nlc_messages = 'en_US.UTF-8'\nlc_monetary = 'en_US.UTF-8'\nlc_numeric = 'en_US.UTF-8'\nlc_time = 'en_US.UTF-8'\ndefault_text_search_config = 'pg_catalog.english'" > $pg_data_dir/postgresql.conf

    chown postgres.postgres $pg_data_dir/postgresql.conf
    #echo "unix_socket_directories = '/var/run/postgresql, /tmp'" >> $pg_data_dir/postgresql.conf
    ## create access authentication file
    echo "local   all             all                             trust" > $pg_data_dir/pg_hba.conf
    read -p "please input cidr address,Examples: (192.168.1.0/24) : " cidr_address
    echo -e "host    all             all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    echo -e "host    replication     all             $cidr_address    md5" >> $pg_data_dir/pg_hba.conf
    chown postgres.postgres $pg_data_dir/pg_hba.conf

    if [ ! -d $pg_sock_dir ] ; then
      mkdir -p $pg_sock_dir
      chown -R postgres.postgres $pg_sock_dir
    fi
  
    ## start service for centos-7.x
    systemctl enable postgresql-"$2"
    systemctl start postgresql-"$2"
  fi
fi
=======
fi 
>>>>>>> origin/master

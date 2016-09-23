# postgresql auto install scirpt

1、安装脚本支持postgresql-9.3、postgresql-9.4、postgresql-9.5的版本；

2、pg_6_install.sh 对应centos-6.x的版本，支持PostgreSQL主库和从库安装；

3、pg_7_install.sh 对应centos-7.x的版本，支持PostgreSQL主库和从库安装；

4、复制用户repl的默认密码为repl，在pg_6_install.sh和pg_7_install.sh文件中修改；

5、执行建立从库的密码时，请输入主库的IP和主库repl用户的密码；

6、pg_hba.conf文件中的IP地址段请根据环境自行修改；

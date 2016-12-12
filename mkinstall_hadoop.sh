#!/bin/bash

Master1=hadp01.bonc.com
Master2=hadp02.bonc.com
Slaver1=hadp03.bonc.com
Slaver2=hadp04.bonc.com
Slaver3=hadp05.bonc.com

DIR=/usr/local
HADOOP_HOME=$DIR/hadoop/hadoop-2.7.3
JAVAHOME=$DIR/JDK/jdk1.7.0_67

#解压tar包
tar zxf all.tar.gz 

#进入解压包目录
cd all

#设置hadoop与JDK的解压目录
mkdir /usr/local/hadoop/
mkdir /usr/local/JDK

#解压
tar zxf hadoop-2.7.3.tar.gz -C /usr/local/hadoop/
tar zxf jdk-7u67-linux-x64.tar.gz -C /usr/local/JDK/


# 修改hadoop配置文件
# 配置JAVA_HOME
sed -i "s/\${JAVA_HOME}/\/usr\/local\/JDK\/jdk1.7.0_67/g"  $HADOOP_HOME/etc/hadoop/hadoop-env.sh

#先配置好core-site.xml 与 hdfs-site.xml
sed -i "s/<value>.*:8020<\/value>/<value>hdfs:\/\/$Master1:8020<\/value>/g" conf/core-site.xml
sed -i "s/<value>.*:50070<\/value>/<value>$Master1:50070<\/value>/g" conf/hdfs-site.xml

#配置Slaves
echo -e "$Master1\n$Master2\n$Slaver1\n$Slaver2\n$Slaver3\n"  > /usr/local/hadoop/hadoop-2.7.3/etc/hadoop/slaves

#从conf目录下拉取core-site.xml 与 hdfs-site.xml
cp conf/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml

cp conf/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml

################分发hadoop和JDK########################

ssh $Master1 "mkdir $DIR/hadoop"
ssh $Master1 "mkdir $DIR/JDK"
ssh $Master2 "mkdir $DIR/hadoop"
ssh $Master2 "mkdir $DIR/JDK"
ssh $Slaver1 "mkdir $DIR/hadoop"
ssh $Slaver1 "mkdir $DIR/JDK"
ssh $Slaver2 "mkdir $DIR/hadoop"
ssh $Slaver2 "mkdir $DIR/JDK"
ssh $Slaver3 "mkdir $DIR/hadoop"
ssh $Slaver3 "mkdir $DIR/JDK"ssh 

scp -r $HADOOP_HOME $Master1:$DIR/hadoop
scp -r $HADOOP_HOME $Master2:$DIR/hadoop
scp -r $HADOOP_HOME $Slaver1:$DIR/hadoop
scp -r $HADOOP_HOME $Slaver2:$DIR/hadoop
#scp -r $HADOOP_HOME $Slaver3:$DIR/hadoop

scp -r $JAVAHOME $Master1:$DIR/JDK
scp -r $JAVAHOME $Master2:$DIR/JDK
scp -r $JAVAHOME $Slaver1:$DIR/JDK
scp -r $JAVAHOME $Slaver2:$DIR/JDK
#scp -r $JAVAHOME $Slaver3:$J$DIR/JDK

########################################

echo "NameNode 格式化..."
#格式化 namenode
ssh $Master1 "/usr/local/hadoop/hadoop-2.7.3/bin/hdfs namenode -format"

echo "Hadoop启动..."
#启动HADOOP
ssh $Master1 "/usr/local/hadoop/hadoop-2.7.3/sbin/start-dfs.sh"

#/usr/local/hadoop/hadoop-2.7.3/sbin/hadoop-daemon.sh start namenode
#/usr/local/hadoop/hadoop-2.7.3/sbin/hadoop-daemon.sh start datanode

echo "Hadoop启动成功!"

#删除all目录
rm -rf ../all


# centos 7
# Oracle Java 1.8.0_151 64 bit
# Maven 3.5.2
# Jenkins 2.92
# git 1.8.3.1
# node v9.2.0
# Nano

# extend the most recent long term support centOS version
FROM centos:7

MAINTAINER xuqiang alvin.xuqiang@gmail.com

# this is a non-interactive automated build - avoid some warning messages
ENV DEBIAN_FRONTEND noninteractive

# update dpkg repositories
RUN yum update

# install wget
RUN yum install -y wget

# get maven 3.5.2
RUN wget --no-verbose -O /tmp/apache-maven-3.5.2.tar.gz https://mirrors.ustc.edu.cn/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz

# verify checksum
#RUN echo "87e5cc81bc4ab9b83986b3e77e6b3095 /tmp/apache-maven-3.5.2.tar.gz" | md5sum -c

# install maven
RUN tar xzf /tmp/apache-maven-3.5.2.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.5.2 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.5.2.tar.gz
ENV MAVEN_HOME /opt/maven

# install git
RUN yum install -y git

# install nano
RUN yum install -y nano

#nodejs
RUN curl --silent --location https://rpm.nodesource.com/setup_9.x | bash - && yum -y install nodejs


# remove download archive files
RUN yum clean all

# set shell variables for java installation
ENV java_version 1.8.0_151
ENV filename jdk-8u151-linux-x64.tar.gz
ENV downloadlink http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/$filename

# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$filename $downloadlink

# unpack java
RUN mkdir /opt/java-oracle && tar -zxf /tmp/$filename -C /opt/java-oracle/
ENV JAVA_HOME /opt/java-oracle/jdk$java_version
ENV PATH $JAVA_HOME/bin:$PATH

# configure symbolic links for the java and javac executables
RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000

# copy jenkins war file to the container
ADD http://mirrors.jenkins-ci.org/war/2.92/jenkins.war /opt/jenkins.war
RUN chmod 644 /opt/jenkins.war
ENV JENKINS_HOME /jenkins

# configure the container to run jenkins, mapping container port 8080 to that host port
ENTRYPOINT ["java", "-jar", "/opt/jenkins.war"]
EXPOSE 8080

CMD [""]
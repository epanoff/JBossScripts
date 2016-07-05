#!/bin/bash

DOCKER_FILENAME="Dockerfile"
FILEPATH_TO_JNDI_LIST=$1
FILEPATH_TO_EAR=$2

if [ -z "$1" ]
then
    echo "Usage: $0 FILEPATH_TO_JNDI_LIST FILEPATH_TO_EAR";
    exit 1
fi

echo "FROM jboss/wildfly" > $DOCKER_FILENAME
echo "RUN /opt/jboss/wildfly/bin/add-user.sh admin Admin#70365 --silent && \ " >> $DOCKER_FILENAME
#add oracle driver
echo "curl http://artifactory.dek.corp.mvideo.ru/artifactory/libs-release-local/com/oracle/ojdbc6/11.2.0.4.0/ojdbc6-11.2.0.4.0.jar -o /tmp/ojdbc6-11.2.0.4.0.jar && \ " >> $DOCKER_FILENAME
echo "/opt/jboss/wildfly/bin/jboss-cli.sh --commands=\"embed-server --server-config=standalone.xml,\ " >> $DOCKER_FILENAME
echo "module add --name=com.oracle --resources=/tmp/ojdbc6-11.2.0.4.0.jar --dependencies=javax.api\\,javax.transaction.api,\ " >> $DOCKER_FILENAME
#add datasources
echo "/subsystem=datasources/jdbc-driver=oracle:add(driver-module-name=com.oracle,driver-name=oracle,driver-class-name=oracle.jdbc.driver.OracleDriver),\ " >> $DOCKER_FILENAME
echo "/subsystem=datasources/data-source=MSPIntDS:add(jndi-name=java:/MSPIntDS, driver-name=oracle, enabled=true, connection-url=${DATASOURCE_URL},user-name=MSP_INT,password=$MSPINT ),\ "  >> $DOCKER_FILENAME
echo "/subsystem=datasources/data-source=MSPSysDS:add(jndi-name=java:/MSPSysDS, driver-name=oracle, enabled=true, connection-url=${DATASOURCE_URL},user-name=MSP_SYS,password=$MSPSysDSpassword ),\ "  >> $DOCKER_FILENAME
echo "/subsystem=datasources/data-source=MSPProdDS:add(jndi-name=java:/MSPProdDS, driver-name=oracle, enabled=true, connection-url=${DATASOURCE_URL},user-name=MSP_PROD,password=$MSPProdDSpassword ),\ "  >> $DOCKER_FILENAME

if [ -f $FILEPATH_TO_JNDI_LIST ];
then
   grep java $FILEPATH_TO_JNDI_LIST | while read JNDI_STRING
   do
      BEFORE_EQUAL=$((`expr index "$JNDI_STRING" "="` - 1 ))
      AFTER_EQUAL=$((`expr index "$JNDI_STRING" "="` ))
      echo "/subsystem=naming/binding=\\\"${JNDI_STRING:0:BEFORE_EQUAL}\\\":add(binding-type=simple, type=java.lang.String, value=\\\"${JNDI_STRING:AFTER_EQUAL}\\\"),\ " >> $DOCKER_FILENAME
   done
else
   echo "WARN File $FILEPATH_TO_JNDI_LIST does not exist."
fi
echo "quit\"" >> $DOCKER_FILENAME

echo "ADD WebEar/target/MVideo_Services_Platform.ear /opt/wildfly/standalone/deployments/" >> $DOCKER_FILENAME

echo "CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]" >> $DOCKER_FILENAME


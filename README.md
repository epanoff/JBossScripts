# JBossScripts

create_wildfly_docker_file.sh - The script create DockerFile with 
1) add admin user
2) add and register oracle jdbc driver
3) add datasources from Env variables (I have 3, and script create 3)
4) add simple string jndi from file with format 
JNDI_NAME=VALUE
java:global/Host=http://www-host01-uat2.corp.companyname.ru
4) copy ear to /opt/wildfly/standalone/deployments/

jndi_on_jboss.sh - The script for add simple JNDI name to JBOSS/WILDFLY domain controller server from file with format
JNDI_NAME=VALUE

Usage: jndi_on_jboss.sh MANAGEMENT_SERVER PROFILE USER PASSWORD FILEPATH_TO_JNDI_LIST

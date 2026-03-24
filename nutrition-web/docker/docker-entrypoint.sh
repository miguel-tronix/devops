#!/bin/bash
set -e

/opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 &

WILDFLY_PID=$!

echo "Waiting for WildFly to start..."
until /opt/jboss/wildfly/bin/jboss-cli.sh --command="connect" 2>/dev/null; do
    sleep 1
done

/opt/jboss/wildfly/bin/jboss-cli.sh --connect <<EOF
/subsystem=datasources/jdbc-driver=postgresql:add(driver-name=postgresql, driver-module-name=org.postgresql, driver-class-name=org.postgresql.Driver)
/subsystem=datasources/data-source=NUTRITION:add( \
    jndi-name="java:/NUTRITION", \
    driver-name=postgresql, \
    connection-url="jdbc:postgresql://${DB_HOST:-localhost}:${DB_PORT:-5432}/${DB_NAME:-nutrition_db}", \
    user-name="${DB_USER:-nutrition}", \
    password="${DB_PASSWORD:-changeme}", \
    min-pool-size=5, \
    max-pool-size=20, \
    enabled=true \
)
EOF

echo "Datasource configured. WildFly is running."
wait $WILDFLY_PID

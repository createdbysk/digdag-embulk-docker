initialize_environment() {
    if [ -z $DIGDAG_ENCRYPTION_KEY ]; then
        DIGDAG_ENCRYPTION_KEY=MDEyMzQ1Njc4OTAxMjM0NQ==
    fi

    if [ -z $CONFIG_FILE ]; then
        CONFIG_FILE=./digdag.properties
    fi
}

start_server() {
    if [[ -n $POSTGRES_ENV_POSTGRES_USER && \
          -n $POSTGRES_ENV_POSTGRES_PASSWORD && \
          -n $POSTGRES_ENV_POSTGRES_DB && \
          -n $POSTGRES_PORT_5432_TCP_ADDR && \
          -n $POSTGRES_PORT_5432_TCP_PORT ]]; then
          digdag server  $* --bind 0.0.0.0 \
                         --port 65432 \
                         --admin-bind 0.0.0.0 \
                         --admin-port 65433 \
                         --config $CONFIG_FILE \
                         -X database.type=postgresql \
                         -X database.user=$POSTGRES_ENV_POSTGRES_USER \
                         -X database.password=$POSTGRES_ENV_POSTGRES_PASSWORD \
                         -X database.host=$POSTGRES_PORT_5432_TCP_ADDR \
                         -X database.port=$POSTGRES_PORT_5432_TCP_PORT \
                         -X database.database=$POSTGRES_ENV_POSTGRES_DB \
                         -X digdag.secret-encryption-key=$DIGDAG_ENCRYPTION_KEY
    elif [[ -n $DB_USER && \
            -n $DB_PASSWORD && \
            -n $DB_NAME && \
            -n $DB_HOST && \
            -n $DB_PORT ]]; then
            digdag server  $* --bind 0.0.0.0 \
                           --port 65432 \
                           --admin-bind 0.0.0.0 \
                           --admin-port 65433 \
                           --config $CONFIG_FILE \
                           -X database.type=postgresql \
                           -X database.user=$DB_USER \
                           -X database.password=$DB_PASSWORD \
                           -X database.host=$DB_HOST \
                           -X database.port=$DB_PORT \
                           -X database.database=$DB_NAME \
                           -X digdag.secret-encryption-key=$DIGDAG_ENCRYPTION_KEY
    elif [[ -n $DB_DIR ]]; then
        digdag server  $* --bind 0.0.0.0 \
                       --port 65432 \
                       --admin-bind 0.0.0.0 \
                       --admin-port 65433 \
                       --config $CONFIG_FILE \
                       --database $DB_DIR
    else
        digdag server  $* --bind 0.0.0.0 \
                       --port 65432 \
                       --admin-bind 0.0.0.0 \
                       --admin-port 65433 \
                       --config $CONFIG_FILE \
                       --memory
    fi
}

initialize_environment

if [ $# -ne 0 ]; then
    echo "Starting digdag server with additional parameters $*"
else
    echo "Starting digdag server with no additional parameters"
fi

start_server $*

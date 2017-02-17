# What is digdag?
See https://www.digdag.io for details.

# What is embulk?
See http://www.embulk.org for details.

# Why are they bundled together?
digdag provides native support to call embulk. Embulk enables data movement in many ETL workloads. This image enables the use of the native embulk support in digdag.

# Start a digdag server instance with an in-memory database
In this mode, digdag removes the data when the server exits. Use this for test purposes only.

    $ docker run -it --rm -p 65432:65432 satvidh/digdag-embulk


# Start a digdag server instance connected to a postgres database
Use this method when you have a Postgresql database instance with the environment variables that correspond to the respective database parameters.

    $ docker run -it --rm -p 65432:65432 -e DB_USER=postgres_user -e DB_PASSWORD=password -e DB_HOST=<host_ip_or_dns_entry> -e DB_PORT=5432 -e DB_NAME=digdag satvidh/digdag-embulk

# Start a digdag server instance linked to a postgres instance in a docker container
Use this method when you have a docker container named postgres that runs a postgresql database.

    $ docker run -it --rm --link postgres -p 65432:65432 satvidh/digdag-embulk

*NOTE* the image expects the name of the link to be postgres. Therefore, if your docker container is named differently, then provide postgres as an alias as indicated below.

    $ docker run -it --rm --link postgres_different:postgres -p 65432:65432 satvidh/digdag-embulk

# Start a digdag server instance as a master node that dispatches tasks

Use this method to launch a digdag server that schedules tasks for worker nodes to execute.

    $ docker run -it --rm -p 65432:65432 --link postgres -e ADDITIONAL_DIGDAG_CLI_PARAMETERS=--disable-local-agent satvidh/digdag-embulk

# Start a digdag server instance as a worker node that executes tasks

Use this method to launch a digdag server that executes tasks scheduled by a master node.

    $ docker run -it --rm --link postgres -e ADDITIONAL_DIGDAG_CLI_PARAMETERS=--disable-executor-loop satvidh/digdag-embulk

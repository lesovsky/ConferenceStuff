#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>
#include "libpq-fe.h"

/* gcc -std=gnu99 -pedantic -I/usr/pgsql-9.5/include -L/usr/pgsql-9.5/lib -o conns-to-pgbouncer src/conns-to-pgbouncer.c -lpq */

#define CONNINFO "host = 127.0.0.1 port = 6432 dbname = pgbench user = postgres"
#define PAUSE_BETWEEN_CONN 2
#define PAUSE_BETWEEN_FAILED_CONN 2

int main (void)
{
    PGconn *m_conn;
    PGresult *m_conn_res;
    int i, max_conn, max_fail = 0;

    /* check max_connections */
    m_conn = PQconnectdb(CONNINFO);
    m_conn_res = PQexec(m_conn, "SELECT setting from pg_settings where name = 'max_connections'");
    max_conn = atoi(PQgetvalue(m_conn_res,0,0));
    fprintf(stdout, "The number of max allowed connections is %i\n", max_conn);
    PQclear(m_conn_res);
    PQfinish(m_conn);
    
    PGconn *conns[max_conn + 1];
    PGresult *conns_res[max_conn + 1];

    /* open connections */
    for (i = 0; i < max_conn + 1; i++) {
        conns[i] = PQconnectdb(CONNINFO);
	if (PQstatus(conns[i]) != CONNECTION_OK) {
        	fprintf(stderr, "Connection to database failed: %s", PQerrorMessage(conns[i]));
		sleep(PAUSE_BETWEEN_FAILED_CONN);
		i = i - 1;
		max_fail++;
	} else {
        	conns_res[i] = PQexec(conns[i], "SELECT 1000");
		if (i % 10 == 0) {
			fprintf(stdout, "opened %i/%i\n", i, max_conn);
		        sleep(PAUSE_BETWEEN_CONN);
		}
	}
	if (max_fail > 10) {
		fprintf(stderr, "Too many failed attempts\n");
		break;
	}
    }

    printf("Closing connections\n");

    /* close connections */
    for (i = 0; i < max_conn - 1; i++) {
        PQclear(conns_res[i]);
        PQfinish(conns[i]);
    }
    
    return 0;
}

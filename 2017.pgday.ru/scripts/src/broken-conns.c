#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <unistd.h>
#include "libpq-fe.h"


/* gcc -std=gnu99 -pedantic -I/usr/include/postgresql -L/usr/lib/x86_64-linux-gnu -o broken-conns src/broken-conns.c -lpq */

#define CONNINFO "host = 127.0.0.1 port = 5432 dbname = pgbench_6gb user = postgres"
#define IDLE_IN_XACT_NUM 10
#define WAITING_NUM 10
#define BLOCK_TIME 120

#define IDLE_FORK_PAUSE 2
#define WAITING_FORK_PAUSE 2
#define AFTER_WAIT_PAUSE 1
int main (void)
{
    int xconns_sz = IDLE_IN_XACT_NUM;
    int wconns_sz = WAITING_NUM;

    PGconn *idle_in_xact_conns[xconns_sz];
    PGresult *idle_in_xact_res[xconns_sz];
    PGconn *blocking_conn;
    PGresult *blocking_res;
    pid_t blocking_pid;
    PGconn *waiting_conns[wconns_sz];
    PGresult *waiting_res[wconns_sz];
    pid_t waiting_pids[wconns_sz];
    int i;

    /* open idle_in_xact transactions */
    fprintf(stdout, "Creating idle in transaction connections...");
    fflush(stdout);
    for (i = 0; i < xconns_sz; i++) {
        idle_in_xact_conns[i] = PQconnectdb(CONNINFO);
        idle_in_xact_res[i] = PQexec(idle_in_xact_conns[i], "BEGIN");
        sleep(IDLE_FORK_PAUSE);
    }
    fprintf(stdout, " done.\n");
    
    /* open blocking transaction */
    blocking_pid = fork();
    if (blocking_pid == 0) {
        blocking_conn = PQconnectdb(CONNINFO);
        /* create temp table */
        fprintf(stdout, "Create temporary table for waiting transactions\n");
        blocking_res = PQexec(blocking_conn, "CREATE TABLE waitings (id int, v1 int)");
        blocking_res = PQexec(blocking_conn, "INSERT INTO waitings (id, v1) values (1,1)");
        /* issue blocking update */
        fprintf(stdout, "Creating blocking transaction...");
        fflush(stdout);
        blocking_res = PQexec(blocking_conn, "BEGIN");
        blocking_res = PQexec(blocking_conn, "UPDATE waitings SET v1 = random()*100 WHERE id = 1");
        fprintf(stdout, " done.\nSuspend blocking transaction for %i seconds\n", BLOCK_TIME);
        sleep(BLOCK_TIME);
        fprintf(stdout, "Resume and commit blocking transaction\n");
        blocking_res = PQexec(blocking_conn, "COMMIT");
        PQclear(blocking_res);
        PQfinish(blocking_conn);
        exit(0);
    }
    sleep(2);

    /* open waiting transactions */
    fprintf(stdout, "Run concurrent transactions that will be blocked\n");
    for (i = 0; i < wconns_sz; i++) {
        waiting_pids[i] = fork();
        if (waiting_pids[i] == 0) {
            waiting_conns[i] = PQconnectdb(CONNINFO);
            waiting_res[i] = PQexec(waiting_conns[i], "BEGIN");
            /* process must wait until postgres return response */
            waiting_res[i] = PQexec(waiting_conns[i], "UPDATE waitings SET v1 = random()*100 WHERE id = 1");
            sleep(AFTER_WAIT_PAUSE);        /* here we go in idle_in_xact state for AFTER_WAIT_PAUSE */
            waiting_res[i] = PQexec(waiting_conns[i], "COMMIT");
            PQclear(waiting_res[i]);
            PQfinish(waiting_conns[i]);
            exit(0);
        }
        sleep(WAITING_FORK_PAUSE);
    }
    fprintf(stdout, "Wait until the blocked transaction will resumed\n");
    fprintf(stdout, "Use this time for checking logs, pg_stat_activity and pg_locks ;)\n");

    /* wait when all children finish */
    for (i = 0; i < wconns_sz; i++) {
        if (waitpid(waiting_pids[i], NULL, 0) != waiting_pids[i]) {
            continue;
        } else if (waitpid(blocking_pid, NULL, 0) != blocking_pid) {
            continue;
        }
    }

    sleep(AFTER_WAIT_PAUSE);

    /* close idle_in_xact transactions */
    fprintf(stdout, "Close idle transaction connections\n");
    for (i = 0; i < xconns_sz; i++) {
        PQclear(idle_in_xact_res[i]);
        PQfinish(idle_in_xact_conns[i]);
        sleep(IDLE_FORK_PAUSE);
    }
    
    /* drop temp table */
    fprintf(stdout, "Drop temporary table\n");
    blocking_conn = PQconnectdb(CONNINFO);
    blocking_res = PQexec(blocking_conn, "DROP TABLE waitings");
    PQclear(blocking_res);
    PQfinish(blocking_conn);

    return 0;
}

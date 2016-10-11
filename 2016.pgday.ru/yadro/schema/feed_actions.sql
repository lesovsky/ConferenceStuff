CREATE TABLE feed_actions (
    id bigserial,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    job_board_id integer,
    request_id character varying(512),
    action integer,
    requested_at timestamp without time zone,
    user_ip character varying(255),
    user_agent text,
    employer_id integer,
    source character varying,
    response_code integer
);

INSERT INTO feed_actions (created_at, updated_at, job_board_id, request_id, action, requested_at, user_ip, user_agent, employer_id, source, response_code)
SELECT now(),
	now(),
	random() * 10000000,
	(select string_agg(md5(j::text),'') from generate_series(1,15) gs(j)),
	random() * 10000000,
	now(),
	(select string_agg(md5(j::text),'') from generate_series(1,5) gs(j)),
	(select string_agg(md5(j::text),'') from generate_series(1,1500) gs(j)),
	random() * 10000000,
	(select string_agg(md5(j::text),'') from generate_series(1,15) gs(j)),
	random() * 10000000
FROM generate_series(1,3000000) AS gs(i);

ALTER TABLE feed_actions OWNER TO postgres;
ALTER TABLE ONLY feed_actions ADD CONSTRAINT feed_accesses_pkey PRIMARY KEY (id);

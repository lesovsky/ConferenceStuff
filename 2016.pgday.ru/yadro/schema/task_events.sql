CREATE TABLE task_events (
    id bigserial,
    created_at timestamp without time zone,
    associated_at timestamp without time zone,
    task_id integer,
    parent character varying(512),
    description_id integer,
    updated_at timestamp without time zone,
    user_uuid character varying(255),
    user_description text,
    customer_id integer,
    cause character varying,
    result_label integer
);

ALTER TABLE task_events OWNER TO postgres;
ALTER TABLE ONLY task_events ADD CONSTRAINT task_events_pkey PRIMARY KEY (id);

INSERT INTO task_events (created_at, associated_at, task_id, parent, description_id, updated_at, user_uuid, user_description, customer_id, cause, result_label)
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

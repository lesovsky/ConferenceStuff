CREATE TABLE box_campaigns (
    id bigserial,
    created_at timestamp without time zone,
    finished_at timestamp without time zone,
    against_id integer,
    creator_id character varying(512),
    option_code integer,
    registered_at timestamp without time zone,
    state_name character varying(255),
    full_description text,
    process_id integer,
    main_context character varying,
    return_result_id integer
);

ALTER TABLE box_campaigns OWNER TO postgres;
ALTER TABLE ONLY box_campaigns ADD CONSTRAINT box_campaigns_pkey PRIMARY KEY (id);

INSERT INTO box_campaigns (created_at, finished_at, against_id, creator_id, option_code, registered_at, state_name, full_description, process_id, main_context, return_result_id)
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

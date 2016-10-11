CREATE TABLE track_issues (
    id bigserial,
    recorded_at timestamp without time zone,
    registered_at timestamp without time zone,
    reporter_id integer,
    caiter_id character varying(512),
    operation_desc integer,
    first_download_at timestamp without time zone,
    author character varying(255),
    history text,
    group_id integer,
    opts_list character varying,
    void_parameters integer
);

ALTER TABLE track_issues OWNER TO postgres;
ALTER TABLE ONLY track_issues ADD CONSTRAINT track_issues_pkey PRIMARY KEY (id);

INSERT INTO track_issues (recorded_at, registered_at, reporter_id, caiter_id, operation_desc, first_download_at, author, history, group_id, opts_list, void_parameters)
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

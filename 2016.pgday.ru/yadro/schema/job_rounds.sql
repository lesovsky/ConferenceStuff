CREATE TABLE job_rounds (
    id bigserial,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    board_id integer,
    bucket_id character varying(512),
    status_code integer,
    charged_at timestamp without time zone,
    box_no character varying(255),
    box_context text,
    packager_id integer,
    destination character varying,
    check_options integer
);

ALTER TABLE job_rounds OWNER TO postgres;
ALTER TABLE ONLY job_rounds ADD CONSTRAINT job_rounds_pkey PRIMARY KEY (id);

INSERT INTO job_rounds (created_at, updated_at, board_id, bucket_id, status_code, charged_at, box_no, box_context, packager_id, destination, check_options)
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

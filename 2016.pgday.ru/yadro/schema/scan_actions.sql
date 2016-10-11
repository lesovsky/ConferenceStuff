CREATE TABLE scan_actions (
    id bigserial,
    scanned_at timestamp without time zone,
    last_accessed_at timestamp without time zone,
    device_id integer,
    property_id character varying(512),
    operation_status integer,
    requested_at timestamp without time zone,
    operator_code character varying(255),
    operator_desc text,
    weight integer,
    content character varying,
    content_size integer
);

ALTER TABLE scan_actions OWNER TO postgres;
ALTER TABLE ONLY scan_actions ADD CONSTRAINT scan_actions_pkey PRIMARY KEY (id);

INSERT INTO scan_actions (scanned_at, last_accessed_at, device_id, property_id, operation_status, requested_at, operator_code, operator_desc, weight, content, content_size)
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

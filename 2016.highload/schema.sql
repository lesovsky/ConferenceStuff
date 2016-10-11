create table test (id serial, v_id int, value text);
alter table test add primary key (id,v_id);
insert into test (v_id, value) (select (random() * 1000)::int, md5(random()::text) from generate_series(1,1000));
create index test_v_id_idx on test (v_id);
alter table test set (autovacuum_enabled = 'off');

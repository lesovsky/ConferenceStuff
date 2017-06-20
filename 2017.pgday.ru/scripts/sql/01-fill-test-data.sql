create extension if not exists pg_stat_statements;

create table games as select 
  generate_series(1,75000) as id,
  md5(random()::text) as map_id,
  (random()*1000)::numeric(10,2) as weight,
  (random() * 21 + 22)::int as players,
  (array['FFA','TM','GDI','BFG','CTF'])[ceil(random()*2)] as gtype,
  (now() - interval '1 day' * round(random()*100))::timestamp(0) as updated_at,
  (select string_agg(md5(j::text),'') from generate_series(1,100) gs( j)) as payload;

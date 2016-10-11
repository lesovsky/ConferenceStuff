create extension if not exists pg_stat_statements;

create table products as select 
  generate_series(1,500000) as id,
  md5(random()::text)::char(10) as name,
  (random()*1000)::numeric(10,2) as price,
  (random() * 21 + 22)::int as size,
  (array['cyan','magenta'])[ceil(random()*2)] as color,
  (now() - interval '1 day' * round(random()*100))::timestamp(0) as updated_at,
  (now() - interval '2 year' + interval '1 year' * random())::date as built;

insert into products select 
  generate_series(500001,1000000) as id,
  md5(random()::text)::char(10) as name,
  (random()*1000)::numeric(10,2) as price,
  (random() * 21 + 22)::int as size,
  (array['cyan','magenta'])[ceil(random()*2)] as color,
  (now() - interval '1 day' * round(random()*100))::timestamp(0) as updated_at,
  (now() - interval '2 year' + interval '1 year' * random())::date as built;

insert into products select 
  generate_series(1000001,1500000) as id,
  md5(random()::text)::char(10) as name,
  (random()*1000)::numeric(10,2) as price,
  (random() * 21 + 22)::int as size,
  (array['cyan','magenta'])[ceil(random()*2)] as color,
  (now() - interval '1 day' * round(random()*100))::timestamp(0) as updated_at,
  (now() - interval '2 year' + interval '1 year' * random())::date as built;

checkpoint;

ALTER TABLE products ADD PRIMARY KEY (id);
CREATE INDEX products_price_idx ON products (price);
ALTER TABLE products SET (autovacuum_vacuum_scale_factor=0.001);

create table games as select 
  generate_series(1,75000) as id,
  md5(random()::text) as map_id,
  (random()*1000)::numeric(10,2) as weight,
  (random() * 21 + 22)::int as players,
  (array['FFA','TM','GDI','BFG','CTF'])[ceil(random()*2)] as gtype,
  (now() - interval '1 day' * round(random()*100))::timestamp(0) as updated_at;
--  (select string_agg(md5(j::text),'') from generate_series(1,100) gs( j)) as payload;

ALTER TABLE games ADD PRIMARY KEY (id);
CREATE INDEX games_players_idx ON games (players);
CREATE INDEX games_weight_idx ON games (weight);

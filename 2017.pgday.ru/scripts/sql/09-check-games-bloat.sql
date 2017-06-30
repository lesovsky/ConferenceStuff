select 
  pg_size_pretty(table_len) as table_size,
  tuple_count,
  pg_size_pretty(tuple_len) as live_tuple_size,
  tuple_percent as live_tuple_percent,
  dead_tuple_count,
  pg_size_pretty(dead_tuple_len) as dead_tuple_size,
  dead_tuple_percent,
  pg_size_pretty(free_space) as free_space_size,
  free_percent
from pgstattuple('games');

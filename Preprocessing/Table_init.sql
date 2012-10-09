CREATE TABLE IF NOT EXISTS sanpo_routes (
  id bigint NOT NULL DEFAULT nextval('sanpo_routes_id'),
  user_route_id bigint NOT NULL,
  user_id varchar(32) NOT NULL,
  start_time timestamp NOT NULL,
  end_time timestamp NOT NULL,
  start_lat decimal(9,6) NOT NULL,
  start_lng decimal(9,6) NOT NULL,
  end_lat decimal(9,6) NOT NULL,
  end_lng decimal(9,6) NOT NULL,
  geom geometry(MultiLineString,4326),
  public boolean NOT NULL DEFAULT '1',
  PRIMARY KEY (id)
);


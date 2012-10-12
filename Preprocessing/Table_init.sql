CREATE SEQUENCE sanpo_routes_id;

CREATE TABLE IF NOT EXISTS sanpo_routes (
  id bigint NOT NULL DEFAULT nextval('sanpo_routes_id'),
  user_route_id bigint NOT NULL,
  user_id text NOT NULL,
  start_time timestamp NOT NULL,
  end_time timestamp NOT NULL,
  start_lat decimal(9,6) NOT NULL,
  start_lng decimal(9,6) NOT NULL,
  end_lat decimal(9,6) NOT NULL,
  end_lng decimal(9,6) NOT NULL,
  geom geometry(MultiLineString,4326),
  length decimal(5,3),
  tracking_times text,
  public boolean NOT NULL DEFAULT '1',
  PRIMARY KEY (id)
);

CREATE SEQUENCE sanpo_photos_id;

CREATE TABLE IF NOT EXISTS sanpo_photos (
  id bigint NOT NULL DEFAULT nextval('sanpo_photos_id'),
  user_id text NOT NULL,
  user_route_id bigint NOT NULL,
  user_photo_id bigint NOT NULL,
  lat decimal(9,6) NOT NULL,
  lng decimal(9,6) NOT NULL,
  shoot_time timestamp NOT NULL,
  filename text,
  memo varchar(512),
  geo_tag text,
  PRIMARY KEY (id)
);

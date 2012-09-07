# Initializing the openfire mysql database for the Multi-User Gaming Plugin  

INSERT INTO ofVersion (name, version) VALUES ('mug-openfire', 0);

CREATE TABLE frogxMugService (
  serviceID             BIGINT        NOT NULL,
  subdomain             VARCHAR(255)  NOT NULL,
  description           VARCHAR(255)  NULL, 
  PRIMARY KEY(subdomain),
  INDEX frogxMugService_serviceID_idx(serviceID)
);

CREATE TABLE frogxMugServiceProp (
  serviceID           BIGINT        NOT NULL,
  name                VARCHAR(100)  NOT NULL,
  propValue           TEXT          NOT NULL,
  PRIMARY KEY (serviceID, name)
);

CREATE TABLE frogxMugGame (
	gameID	BIGINT	NOT NULL,
	namespace	VARCHAR(255)	NOT NULL,
	name		VARCHAR(255)	NOT NULL,
	description VARCHAR(255)    NULL,
	implClass	VARCHAR(128)	NOT NULL,
	defaultCategory BIGINT  	NOT NULL,
	CONSTRAINT game_pk PRIMARY KEY (namespace),
	CONSTRAINT game_uk_name UNIQUE(name),
	CONSTRAINT game_uk_gid UNIQUE(gameID)
);

CREATE TABLE frogxUserData (
  username           VARCHAR(255)   NOT NULL,
  propName           VARCHAR(255)   NOT NULL,
  propValue          TEXT           NOT NULL,
  version			 INT            NOT NULL,
  PRIMARY KEY (username, propName)
);
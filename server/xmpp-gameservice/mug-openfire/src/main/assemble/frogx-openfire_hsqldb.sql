// Initializing the openfire embedded database (hsqldb) for the Multi-User Gaming Plugin  

INSERT INTO ofVersion (name, version) VALUES ('frogx-openfire', 0);

CREATE TABLE frogxMugService (
  serviceID             BIGINT        NOT NULL,
  subdomain             VARCHAR(255)  NOT NULL,
  description           VARCHAR(255)  NULL, 
  CONSTRAINT frogxMugService_pk PRIMARY KEY(subdomain)
);
CREATE INDEX frogxMugService_serviceID_idx ON frogxMugService(serviceID);

CREATE TABLE frogxMugServiceProp (
  serviceID           BIGINT        NOT NULL,
  name                VARCHAR(100)  NOT NULL,
  propValue           VARCHAR(4000) NOT NULL,
  CONSTRAINT frogxMugServiceProp_pk PRIMARY KEY (serviceID, name)
);


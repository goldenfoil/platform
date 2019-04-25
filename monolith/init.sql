CREATE TABLE IF NOT EXISTS ausers (
    id serial NOT NULL PRIMARY KEY,
    "username" varchar NOT NULL,
    "password" varchar NOT NULL,
    UNIQUE(username)
);

CREATE TABLE IF NOT EXISTS tokens (
    id serial NOT NULL PRIMARY KEY,
    owner__id int REFERENCES ausers (id),
    token varchar NOT NULL
);


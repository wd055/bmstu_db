-- ************************************** DROP TABLES

DROP TABLE IF EXISTS "User" CASCADE;
DROP TABLE IF EXISTS Profile CASCADE;
DROP TABLE IF EXISTS School CASCADE;
DROP TABLE IF EXISTS Competition CASCADE;
DROP TABLE IF EXISTS Flow CASCADE;
DROP TABLE IF EXISTS Participant CASCADE;
DROP TABLE IF EXISTS Score CASCADE;

-- ************************************** "User"

CREATE TABLE "User"
(
    id serial NOT NULL PRIMARY KEY,
    username varchar(128) NOT NULL UNIQUE,
    password varchar(128) NOT NULL,
    email varchar(128) NOT NULL UNIQUE
);

CREATE INDEX User_nickname ON "User"
(
    username
);

-- ************************************** Profile

CREATE TABLE Profile
(
    id serial NOT NULL PRIMARY KEY,
    "user" int NOT NULL UNIQUE,
    birthday date,
    first_name varchar(128),
    last_name varchar(128),
    create_date timestamp DEFAULT NOW(),
    FOREIGN KEY ("user") REFERENCES "User" (id)
);

CREATE INDEX Profile_user ON Profile
(
    "user"
);

-- ************************************** School

CREATE TABLE School
(
    id serial NOT NULL PRIMARY KEY,
    "user" int NOT NULL UNIQUE,
    title varchar(128) NOT NULL,
    city varchar(128) NOT NULL,
    address varchar(128) NOT NULL,
    create_date timestamp DEFAULT NOW(),
    FOREIGN KEY ("user") REFERENCES "User" (id)
);

CREATE INDEX School_user ON School
(
    "user"
);

-- ************************************** Competition

CREATE TABLE Competition
(
    id serial NOT NULL PRIMARY KEY,
    school int NOT NULL,
    title varchar(128) NOT NULL,
    create_date timestamp DEFAULT NOW(),
    FOREIGN KEY (school) REFERENCES School (id)
);

CREATE INDEX Competition_school ON Competition
(
    school
);

-- ************************************** Flow

CREATE TABLE Flow
(
    id serial NOT NULL PRIMARY KEY,
    competition int NOT NULL,
    FOREIGN KEY (competition) REFERENCES Competition (id)
);

CREATE INDEX Flow_competition ON Flow
(
    competition
);

-- ************************************** Participant

CREATE TABLE Participant
(
    id serial NOT NULL PRIMARY KEY,
    competition int NOT NULL,
    flow int NOT NULL,
    profile int NOT NULL,
    FOREIGN KEY (competition) REFERENCES Competition (id),
    FOREIGN KEY (flow) REFERENCES Flow (id),
    FOREIGN KEY (profile) REFERENCES Profile (id)
);

CREATE INDEX Participant_competition ON Participant
(
    competition
);

CREATE INDEX Participant_flow ON Participant
(
    flow
);

CREATE INDEX Participant_profile ON Participant
(
    profile
);

-- ************************************** Score

CREATE TABLE Score
(
    id serial NOT NULL PRIMARY KEY,
    competition int NOT NULL,
    judge int NOT NULL,
    participant int NOT NULL,
    score real NOT NULL,
    create_date timestamp DEFAULT NOW(),
    FOREIGN KEY (competition) REFERENCES Competition (id),
    FOREIGN KEY (judge) REFERENCES Profile (id),
    FOREIGN KEY (participant) REFERENCES Profile (id),
    CONSTRAINT Score_score_gte_0 CHECK(score >= 0),
    CONSTRAINT Score_score_lte_10 CHECK(score <= 10)
);

CREATE INDEX Score_competition ON Score
(
    competition
);

CREATE INDEX Score_judge ON Score
(
    judge
);

CREATE INDEX Score_participant ON Score
(
    participant
);

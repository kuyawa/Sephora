------------------------------------------------------------
-- CREATE DATABASE
------------------------------------------------------------

-- CREATE DATABASE forums

------------------------------------------------------------
-- CREATE TABLES
------------------------------------------------------------
-- SETTINGS

CREATE TABLE IF NOT EXISTS settings (
    key       varchar(20) NOT NULL,
    value     varchar(140)
);

------------------------------------------------------------
-- USERS

CREATE TABLE IF NOT EXISTS users (
    userid    serial NOT NULL PRIMARY KEY,
    nick      varchar(20) NOT NULL,
    avatar    varchar(30),
    timezone  integer,
    lastact   timestamp,
    status    varchar(40),
    isnoob    boolean,
    ismod     boolean,
    banned    boolean
);

------------------------------------------------------------
-- FORUMS

CREATE TABLE IF NOT EXISTS forums (
    forumid   serial NOT NULL PRIMARY KEY,
    name      varchar(40) NOT NULL,
    descrip   varchar(140),
    rowpos    integer,
    hidden    boolean,
    disabled  boolean
);

------------------------------------------------------------
-- POSTS

CREATE TABLE IF NOT EXISTS posts (
    postid    serial  NOT NULL PRIMARY KEY,
    forumid   integer NOT NULL DEFAULT 1,
    type      integer DEFAULT 0,
    date      timestamp DEFAULT now(),
    userid    integer,
    nick      varchar(24),
    title     varchar(80),
    content   text,
    views     integer DEFAULT 0,
    replies   integer DEFAULT 0,
    answered  boolean DEFAULT false,
    sticky    boolean DEFAULT false,
    closed    boolean DEFAULT false,
    hidden    boolean DEFAULT false
);

------------------------------------------------------------
-- REPLIES

CREATE TABLE IF NOT EXISTS replies (
    replyid   serial NOT NULL PRIMARY KEY,
    postid    integer,
    userid    integer,
    nick      varchar(20),
    date      timestamp DEFAULT now(),
    content   text,
    votes     integer DEFAULT 0,
    votesup   integer DEFAULT 0,
    votesdn   integer DEFAULT 0,
    answer    boolean DEFAULT false,
    hidden    boolean DEFAULT false
);

------------------------------------------------------------
-- POPULATE DATABASE
------------------------------------------------------------

-- SETTINGS
INSERT INTO settings(key, value) VALUES ('forum.name', 'Sephora');
INSERT INTO settings(key, value) VALUES ('forum.title', 'Forums in Swift');
INSERT INTO settings(key, value) VALUES ('status.offline', 'false');

-- USERS
INSERT INTO users(nick, avatar, lastact, status, isnoob, ismod, banned, timezone) VALUES ('Admin', 'admin.png', now(), 'Always on', false, true, false, 0);
INSERT INTO users(nick, avatar, lastact, status, isnoob, ismod, banned, timezone) VALUES ('Mod', 'mod.png', now(), 'Always watching', false, true, false, 0);
INSERT INTO users(nick, avatar, lastact, status, isnoob, ismod, banned, timezone) VALUES ('Test', 'test.png', now(), 'Testing...', true, true, false, 0);

-- FORUMS
INSERT INTO forums(name, descrip, rowpos) VALUES ('Welcome', 'Welcome to our forums', 1);
INSERT INTO forums(name, descrip, rowpos) VALUES ('General Discussion', 'All about programming', 2);
INSERT INTO forums(name, descrip, rowpos) VALUES ('Tutorials', 'Come learn with us', 3);
INSERT INTO forums(name, descrip, rowpos) VALUES ('Swift', 'All about Swift', 4);

-- POSTS
INSERT INTO posts(forumid, type, date, userid, nick, title, content) VALUES (1, 0, now(), 1, 'Admin', 'Welcome!', 'Welcome to our forums');

-- REPLIES
INSERT INTO replies(postid, userid, nick, date, content) VALUES (1, 2, 'Mod', now(), 'Thanks for the warm welcome. Mod reporting to work');

------------------------------------------------------------

-- END
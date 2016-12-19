------------------------------------------------------------
-- GENERATE DATABASE
------------------------------------------------------------

CREATE DATABASE forums WITH 
    OWNER = mini
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

------------------------------------------------------------
-- CREATE TABLES
------------------------------------------------------------
-- SETTINGS
-- Table: public.settings
-- DROP TABLE public.settings;

CREATE TABLE public.settings IF NOT EXISTS (
    key       character varying(20) NOT NULL,
    value     character varying(140)
)
WITH ( OIDS = FALSE )
TABLESPACE pg_default;

ALTER TABLE public.settings OWNER to mini;

------------------------------------------------------------
-- USERS
-- Table: public.users
-- DROP TABLE public.users;

CREATE TABLE public.users (
    userid    serial NOT NULL,
    nick      character varying(20) NOT NULL,
    avatar    character varying(30),
    timezone  integer,
    lastact   timestamp without time zone,
    status    character varying(40),
    isnoob    boolean,
    ismod     boolean,
    banned    boolean,
    PRIMARY KEY (userid)
)
WITH ( OIDS = FALSE )
TABLESPACE pg_default;

ALTER TABLE public.users OWNER to mini;

------------------------------------------------------------
-- FORUMS
-- Table: public.forums
-- DROP TABLE public.forums;

CREATE TABLE public.forums (
    forumid   serial NOT NULL,
    name      character varying(40) NOT NULL,
    descrip   character varying(140),
    rowpos    integer,
    hidden    boolean,
    disabled  boolean,
    PRIMARY KEY (forumid)
)
WITH ( OIDS = FALSE )
TABLESPACE pg_default;

ALTER TABLE public.forums OWNER to mini;

------------------------------------------------------------
-- POSTS
-- Table: public.posts
-- DROP TABLE public.posts;

CREATE TABLE public.posts (
    postid    serial  NOT NULL,
    forumid   integer NOT NULL DEFAULT 1,
    type      integer DEFAULT 0,
    date      timestamp without time zone DEFAULT now(),
    userid    integer,
    nick      character varying(24),
    title     character varying(80),
    content   text,
    views     integer DEFAULT 0,
    replies   integer DEFAULT 0,
    answered  boolean DEFAULT false,
    sticky    boolean DEFAULT false,
    closed    boolean DEFAULT false,
    hidden    boolean DEFAULT false,
    PRIMARY KEY (postid)
)
WITH ( OIDS = FALSE )
TABLESPACE pg_default;

ALTER TABLE public.posts OWNER to mini;

------------------------------------------------------------
-- REPLIES
-- Table: public.replies
-- DROP TABLE public.replies;

CREATE TABLE public.replies (
    replyid   serial NOT NULL,
    postid    integer,
    userid    integer,
    nick      character varying(20),
    date      timestamp without time zone DEFAULT now(),
    content   text,
    votes     integer DEFAULT 0,
    votesup   integer DEFAULT 0,
    votesdn   integer DEFAULT 0,
    answer    boolean DEFAULT false,
    hidden    boolean DEFAULT false,
    PRIMARY KEY (replyid)
)
WITH ( OIDS = FALSE )
TABLESPACE pg_default;

ALTER TABLE public.replies OWNER to mini;

------------------------------------------------------------
-- POPULATE DATABASE
------------------------------------------------------------

-- SETTINGS
INSERT INTO public.settings(key, value) VALUES ('forum.name', 'Sephora');
INSERT INTO public.settings(key, value) VALUES ('forum.title', 'Forums in Swift');
INSERT INTO public.settings(key, value) VALUES ('status.offline', 'false');

-- USERS
INSERT INTO public.users(nick, avatar, lastact, status, isnoob, ismod, banned, timezone) VALUES ('Admin', 'admin.png', now(), 'Always on', false, true, false, 0);
INSERT INTO public.users(nick, avatar, lastact, status, isnoob, ismod, banned, timezone) VALUES ('Mod', 'mod.png', now(), 'Always watching', false, true, false, 0);
INSERT INTO public.users(nick, avatar, lastact, status, isnoob, ismod, banned, timezone) VALUES ('Test', 'test.png', now(), 'Testing...', true, true, false, 0);

-- FORUMS
INSERT INTO public.forums(name, descrip, rowpos) VALUES ('Welcome', 'Welcome to our forums', 1);
INSERT INTO public.forums(name, descrip, rowpos) VALUES ('General Discussion', 'All about programming', 2);
INSERT INTO public.forums(name, descrip, rowpos) VALUES ('Tutorials', 'Come learn with us', 3);
INSERT INTO public.forums(name, descrip, rowpos) VALUES ('Swift', 'All about Swift', 4);

-- POSTS
INSERT INTO public.posts(forumid, type, date, userid, nick, title, content) VALUES (1, 0, now(), 1, 'Admin', 'Welcome!', 'Welcome to our forums');

-- REPLIES
INSERT INTO public.replies(postid, userid, nick, date, content) VALUES (1, 2, 'Mod', now(), 'Thanks for the warm welcome. Mod reporting to work');

------------------------------------------------------------
-- SEQUENCES

-- CREATE SEQUENCE public.users_seq   START 1 INCREMENT 1;
-- CREATE SEQUENCE public.forums_seq  START 1 INCREMENT 1;
-- CREATE SEQUENCE public.posts_seq   START 1 INCREMENT 1;
-- CREATE SEQUENCE public.replies_seq START 1 INCREMENT 1;

-- ALTER SEQUENCE public.users_seq    OWNER TO mini;
-- ALTER SEQUENCE public.forums_seq   OWNER TO mini;
-- ALTER SEQUENCE public.posts_seq    OWNER TO mini;
-- ALTER SEQUENCE public.replies_seq  OWNER TO mini;


-- END
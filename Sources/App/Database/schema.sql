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
    name      varchar(40),
    avatar    varchar(250),
    timezone  integer DEFAULT 0,
    lastact   timestamp DEFAULT now(),
    status    varchar(40) DEFAULT 'Hello',
    isnoob    boolean DEFAULT true,
    ismod     boolean DEFAULT false,
    banned    boolean DEFAULT false,
    karma     integer DEFAULT 0,
--  OAUTH
    state     varchar(80),
    code      varchar(80),
    token     varchar(80),
    isvalid   boolean DEFAULT false,
    expired   boolean DEFAULT false,
    islogged  boolean DEFAULT false
);

------------------------------------------------------------
-- FORUMS

CREATE TABLE IF NOT EXISTS forums (
    forumid   serial NOT NULL PRIMARY KEY,
    name      varchar(40) NOT NULL,
    dirname   varchar(20) NOT NULL,
    descrip   varchar(140),
    rowpos    integer DEFAULT 0,
    hidden    boolean DEFAULT false,
    disabled  boolean DEFAULT false
);

------------------------------------------------------------
-- POSTS

CREATE TABLE IF NOT EXISTS posts (
    postid    serial  NOT NULL PRIMARY KEY,
    forumid   integer NOT NULL DEFAULT 1,
    type      integer DEFAULT 0,
    date      timestamp DEFAULT now(),
    userid    integer,
    nick      varchar(20),
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
-- VOTES

CREATE TABLE IF NOT EXISTS votes (
    voteid    serial NOT NULL PRIMARY KEY,
    userid    integer,
    nick      varchar(20),
    date      timestamp DEFAULT now(),
    postid    integer,
    replyid   integer,
    state     integer DEFAULT 1
);

------------------------------------------------------------
-- WEBLOGS

CREATE TABLE IF NOT EXISTS weblogs (
    date      timestamp DEFAULT now(),
    type      character(1) DEFAULT 'I',
    text      text
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
INSERT INTO users(nick, avatar, lastact, status, isnoob, ismod, banned, timezone) VALUES ('Test', 'test.png', now(), 'Testing...', true, false, false, 0);

-- FORUMS
INSERT INTO forums(name, dirname, descrip, rowpos) VALUES 
    ('Welcome', 'welcome', 'Welcome to our forums', 1);
    ('General Discussion', 'general', 'All about programming', 2);
    ('Tutorials', 'tutorials', 'Come learn with us', 3);
    ('Swift', 'swift', 'All about Swift', 4);
    ('iOS', 'ios', 'Everything about mobile apps for iPhone and iPad', 5),
    ('macOS', 'macos', 'Apps for the desktop, terminal or modules', 6),
    ('watchOS', 'watchos', 'Apps for the Apple Watch', 7),
    ('tvOS', 'tvos', 'Apps for your Apple TV', 8),
    ('Server', 'server', 'Server apps for web sites and APIs', 9),
    ('Linux', 'linux', 'All about Swift on Linux', 10),
    ('Frameworks', 'frameworks', 'Showcase your libraries, modules and frameworks', 11),
    ('Apps Showcase', 'showcase', 'Impress the world with your latest app', 12),
    ('Request Apps', 'request', 'Need an app? Let programmers know so they can develop it', 13),
    ('Jobs - Hiring', 'jobs', 'Job offerings for Swift developers around the world', 14),
    ('Jobs - For hire', 'forhire', 'Are you a developer looking for employment or freelancing?', 15),
    ('Meta', 'meta', 'About the forums and their inner workings', 16);

-- POSTS
INSERT INTO posts(forumid, type, date, userid, nick, title, content) VALUES (1, 0, now(), 1, 'Admin', 'Welcome!', 'Welcome to our forums');

-- REPLIES
INSERT INTO replies(postid, userid, nick, date, content) VALUES (1, 2, 'Mod', now(), 'Thanks for the invitation. Mod reporting to work');

------------------------------------------------------------

-- END
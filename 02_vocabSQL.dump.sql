--
-- PostgreSQL database dump
--

-- Dumped from database version 13.7 (Raspbian 13.7-0+deb11u1)
-- Dumped by pg_dump version 13.7 (Raspbian 13.7-0+deb11u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: contacts; Type: TYPE; Schema: public; Owner: vk_admin
--

CREATE TYPE public.contacts AS (
	phone character varying(15),
	email character varying(120)
);


ALTER TYPE public.contacts OWNER TO vk_admin;

--
-- Name: most_messages_to_user_id(integer); Type: FUNCTION; Schema: public; Owner: vk_admin
--

CREATE FUNCTION public.most_messages_to_user_id(user_id integer, OUT usr integer) RETURNS integer
    LANGUAGE sql
    AS $$
    SELECT
        from_user_id
        FROM messages
        where to_user_id = user_id
        group by from_user_id
        ORDER BY COUNT (from_user_id) DESC
        LIMIT 1;
$$;


ALTER FUNCTION public.most_messages_to_user_id(user_id integer, OUT usr integer) OWNER TO vk_admin;

--
-- Name: photo_owner_check(integer); Type: PROCEDURE; Schema: public; Owner: vk_admin
--

CREATE PROCEDURE public.photo_owner_check(checked_owner integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE profiles 
    SET main_photo_id=NULL
    WHERE user_id = checked_owner AND (SELECT owner_id FROM photo WHERE main_photo_id = photo.id) != checked_owner;
END;
$$;


ALTER PROCEDURE public.photo_owner_check(checked_owner integer) OWNER TO vk_admin;

--
-- Name: update_profiles_photo_trigger(); Type: FUNCTION; Schema: public; Owner: vk_admin
--

CREATE FUNCTION public.update_profiles_photo_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE is_owner BOOLEAN;
BEGIN
  is_owner := EXISTS(SELECT * FROM photo WHERE photo.id = NEW.main_photo_id AND owner_id = NEW.user_id);
  IF is_owner THEN
    RETURN NEW;
  END IF;

END
$$;


ALTER FUNCTION public.update_profiles_photo_trigger() OWNER TO vk_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: communities; Type: TABLE; Schema: public; Owner: vk_admin
--

CREATE TABLE public.communities (
    id integer NOT NULL,
    name character varying(120),
    creator_id integer NOT NULL,
    created_at timestamp without time zone,
    members integer[]
);


ALTER TABLE public.communities OWNER TO vk_admin;

--
-- Name: communities_id_seq; Type: SEQUENCE; Schema: public; Owner: vk_admin
--

CREATE SEQUENCE public.communities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.communities_id_seq OWNER TO vk_admin;

--
-- Name: communities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vk_admin
--

ALTER SEQUENCE public.communities_id_seq OWNED BY public.communities.id;


--
-- Name: communities_users; Type: TABLE; Schema: public; Owner: vk_admin
--

CREATE TABLE public.communities_users (
    community_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone
);


ALTER TABLE public.communities_users OWNER TO vk_admin;

--
-- Name: following; Type: TABLE; Schema: public; Owner: vk_admin
--

CREATE TABLE public.following (
    id integer NOT NULL,
    follower_id integer NOT NULL,
    followed_to_id integer NOT NULL,
    is_user boolean NOT NULL,
    followed_at timestamp without time zone NOT NULL
);


ALTER TABLE public.following OWNER TO vk_admin;

--
-- Name: following_id_seq; Type: SEQUENCE; Schema: public; Owner: vk_admin
--

CREATE SEQUENCE public.following_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.following_id_seq OWNER TO vk_admin;

--
-- Name: following_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vk_admin
--

ALTER SEQUENCE public.following_id_seq OWNED BY public.following.id;


--
-- Name: friendship; Type: TABLE; Schema: public; Owner: vk_admin
--

CREATE TABLE public.friendship (
    id integer NOT NULL,
    requested_by_user_id integer NOT NULL,
    requested_to_user_id integer NOT NULL,
    status_id integer NOT NULL,
    requested_at timestamp without time zone,
    confirmed_at timestamp without time zone
);


ALTER TABLE public.friendship OWNER TO vk_admin;

--
-- Name: friendship_id_seq; Type: SEQUENCE; Schema: public; Owner: vk_admin
--

CREATE SEQUENCE public.friendship_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.friendship_id_seq OWNER TO vk_admin;

--
-- Name: friendship_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vk_admin
--

ALTER SEQUENCE public.friendship_id_seq OWNED BY public.friendship.id;


--
-- Name: friendship_statuses; Type: TABLE; Schema: public; Owner: vk_admin
--

CREATE TABLE public.friendship_statuses (
    id integer NOT NULL,
    name character varying(30)
);


ALTER TABLE public.friendship_statuses OWNER TO vk_admin;

--
-- Name: friendship_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: vk_admin
--

CREATE SEQUENCE public.friendship_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.friendship_statuses_id_seq OWNER TO vk_admin;

--
-- Name: friendship_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vk_admin
--

ALTER SEQUENCE public.friendship_statuses_id_seq OWNED BY public.friendship_statuses.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: vk_admin
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    from_user_id integer NOT NULL,
    to_user_id integer NOT NULL,
    body text,
    is_important boolean,
    is_delivered boolean,
    created_at timestamp without time zone
);


ALTER TABLE public.messages OWNER TO vk_admin;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: vk_admin
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.messages_id_seq OWNER TO vk_admin;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vk_admin
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: photo; Type: TABLE; Schema: public; Owner: vk_admin
--

CREATE TABLE public.photo (
    id integer NOT NULL,
    url character varying(250) NOT NULL,
    owner_id integer NOT NULL,
    description character varying(250) NOT NULL,
    uploaded_at timestamp without time zone NOT NULL,
    size integer NOT NULL
);


ALTER TABLE public.photo OWNER TO vk_admin;

--
-- Name: photo_id_seq; Type: SEQUENCE; Schema: public; Owner: vk_admin
--

CREATE SEQUENCE public.photo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.photo_id_seq OWNER TO vk_admin;

--
-- Name: photo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vk_admin
--

ALTER SEQUENCE public.photo_id_seq OWNED BY public.photo.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: vk_admin
--

CREATE TABLE public.profiles (
    user_id integer,
    main_photo_id integer,
    user_contacts public.contacts,
    created_at timestamp without time zone
);


ALTER TABLE public.profiles OWNER TO vk_admin;

--
-- Name: users; Type: TABLE; Schema: public; Owner: vk_admin
--

CREATE TABLE public.users (
    id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    email character varying(120) NOT NULL,
    phone character varying(15)
);


ALTER TABLE public.users OWNER TO vk_admin;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: vk_admin
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO vk_admin;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vk_admin
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: video; Type: TABLE; Schema: public; Owner: vk_admin
--

CREATE TABLE public.video (
    id integer NOT NULL,
    url character varying(250) NOT NULL,
    owner_id integer NOT NULL,
    description character varying(250) NOT NULL,
    uploaded_at timestamp without time zone NOT NULL,
    size integer NOT NULL
);


ALTER TABLE public.video OWNER TO vk_admin;

--
-- Name: video_10_newest; Type: VIEW; Schema: public; Owner: vk_admin
--

CREATE VIEW public.video_10_newest AS
 SELECT video.id,
    video.url,
    video.owner_id,
    video.description,
    video.uploaded_at,
    video.size
   FROM public.video
  ORDER BY video.uploaded_at DESC
 LIMIT 10;


ALTER TABLE public.video_10_newest OWNER TO vk_admin;

--
-- Name: video_id_seq; Type: SEQUENCE; Schema: public; Owner: vk_admin
--

CREATE SEQUENCE public.video_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.video_id_seq OWNER TO vk_admin;

--
-- Name: video_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vk_admin
--

ALTER SEQUENCE public.video_id_seq OWNED BY public.video.id;


--
-- Name: video_with_users; Type: VIEW; Schema: public; Owner: vk_admin
--

CREATE VIEW public.video_with_users AS
 SELECT video.id,
    video.url,
    video.owner_id,
    video.description,
    video.uploaded_at,
    video.size,
    profiles.user_id,
    profiles.main_photo_id,
    profiles.user_contacts,
    profiles.created_at
   FROM (public.video
     LEFT JOIN public.profiles ON ((video.owner_id = profiles.user_id)));


ALTER TABLE public.video_with_users OWNER TO vk_admin;

--
-- Name: communities id; Type: DEFAULT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.communities ALTER COLUMN id SET DEFAULT nextval('public.communities_id_seq'::regclass);


--
-- Name: following id; Type: DEFAULT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.following ALTER COLUMN id SET DEFAULT nextval('public.following_id_seq'::regclass);


--
-- Name: friendship id; Type: DEFAULT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.friendship ALTER COLUMN id SET DEFAULT nextval('public.friendship_id_seq'::regclass);


--
-- Name: friendship_statuses id; Type: DEFAULT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.friendship_statuses ALTER COLUMN id SET DEFAULT nextval('public.friendship_statuses_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: photo id; Type: DEFAULT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.photo ALTER COLUMN id SET DEFAULT nextval('public.photo_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: video id; Type: DEFAULT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.video ALTER COLUMN id SET DEFAULT nextval('public.video_id_seq'::regclass);


--
-- Data for Name: communities; Type: TABLE DATA; Schema: public; Owner: vk_admin
--

COPY public.communities (id, name, creator_id, created_at, members) FROM stdin;
3	Tellus Non Company	20	2022-11-21 00:00:00	{18}
2	Risus Morbi Metus Industries	8	2021-12-28 00:00:00	\N
4	Nunc Ac Sem Inc.	3	2022-11-11 00:00:00	\N
5	Non Lacinia Consulting	93	2021-09-25 00:00:00	\N
6	Tincidunt Aliquam Arcu Industries	98	2021-12-06 00:00:00	\N
7	Accumsan Convallis Ante PC	59	2021-12-07 00:00:00	\N
8	Iaculis Quis Ltd	70	2022-10-20 00:00:00	\N
9	Suscipit Nonummy LLP	13	2022-05-20 00:00:00	\N
10	Non Arcu Corp.	1	2023-05-31 00:00:00	\N
11	In Faucibus Corporation	28	2023-05-31 00:00:00	\N
12	Auctor Associates	82	2021-11-15 00:00:00	\N
13	Cubilia Incorporated	93	2022-11-09 00:00:00	\N
14	Nunc Est Corporation	93	2021-10-02 00:00:00	\N
15	Vulputate Nisi Sem Industries	39	2023-08-05 00:00:00	\N
16	Dui Industries	56	2022-07-23 00:00:00	\N
17	Curabitur Ut LLP	69	2023-06-29 00:00:00	\N
18	Sem Egestas LLP	52	2022-08-30 00:00:00	\N
19	Feugiat Sed Corporation	32	2022-12-18 00:00:00	\N
20	Vitae Posuere Company	54	2023-07-13 00:00:00	\N
21	Ante Corp.	35	2023-08-04 00:00:00	\N
22	Pharetra Industries	44	2022-09-19 00:00:00	\N
23	Cras Sed Inc.	65	2023-02-26 00:00:00	\N
24	Magna Nec Quam LLC	33	2023-05-26 00:00:00	\N
25	Mauris Magna Corp.	56	2022-02-01 00:00:00	\N
26	Vitae Incorporated	31	2023-04-15 00:00:00	\N
27	Cras Pellentesque Foundation	65	2022-04-14 00:00:00	\N
28	Mus Institute	66	2022-08-18 00:00:00	\N
29	Accumsan Convallis Ante Institute	7	2022-11-09 00:00:00	\N
30	Donec Egestas Industries	40	2022-09-16 00:00:00	\N
31	At Ltd	30	2021-10-23 00:00:00	\N
32	Donec Limited	66	2022-09-23 00:00:00	\N
33	Quam Elementum Foundation	94	2023-02-25 00:00:00	\N
34	A Institute	94	2022-06-26 00:00:00	\N
35	Mauris Company	58	2022-10-19 00:00:00	\N
36	Ante Ipsum Company	44	2022-03-16 00:00:00	\N
37	Mauris Nulla Limited	31	2023-07-30 00:00:00	\N
38	Felis Adipiscing Ltd	68	2021-10-17 00:00:00	\N
39	Luctus Ipsum Corp.	51	2023-02-04 00:00:00	\N
40	In At Incorporated	18	2022-09-14 00:00:00	\N
41	Iaculis Nec Company	58	2021-09-09 00:00:00	\N
42	Turpis Egestas Ltd	40	2023-04-16 00:00:00	\N
43	Euismod Corporation	16	2022-05-03 00:00:00	\N
44	Turpis LLP	26	2022-12-07 00:00:00	\N
45	Consequat Purus Maecenas Institute	17	2023-04-11 00:00:00	\N
46	Odio Consulting	79	2022-03-23 00:00:00	\N
47	Ipsum Sodales Corp.	11	2023-02-05 00:00:00	\N
48	Rhoncus Proin Industries	51	2022-09-07 00:00:00	\N
49	Nunc Incorporated	57	2021-10-24 00:00:00	\N
50	amet metus.	85	2023-06-11 00:00:00	\N
51	Lobortis Class Limited	5	2022-07-07 00:00:00	\N
52	non	15	2022-01-24 00:00:00	\N
53	nisi. Aenean	79	2022-02-23 00:00:00	\N
54	Etiam gravida	65	2022-02-18 00:00:00	\N
55	Duis cursus,	97	2022-05-27 00:00:00	\N
56	volutpat ornare,	26	2022-02-09 00:00:00	\N
57	luctus vulputate,	62	2022-12-04 00:00:00	\N
58	laoreet, libero	75	2022-07-26 00:00:00	\N
59	justo eu arcu.	90	2022-02-26 00:00:00	\N
60	mauris erat	73	2022-08-11 00:00:00	\N
61	Nunc mauris	2	2023-02-20 00:00:00	\N
62	mi pede, nonummy	20	2023-01-20 00:00:00	\N
63	est tempor bibendum.	83	2022-03-17 00:00:00	\N
64	blandit congue. In	63	2022-09-04 00:00:00	\N
65	Cras dolor	33	2022-03-04 00:00:00	\N
66	vitae semper	43	2022-06-14 00:00:00	\N
67	sed,	80	2023-02-08 00:00:00	\N
68	sagittis semper.	20	2021-09-15 00:00:00	\N
69	aliquam iaculis,	24	2023-04-17 00:00:00	\N
70	magna. Sed	81	2021-11-13 00:00:00	\N
71	senectus et	46	2022-01-10 00:00:00	\N
72	Suspendisse ac metus	36	2023-06-14 00:00:00	\N
73	leo, in lobortis	90	2022-12-02 00:00:00	\N
74	quis massa.	67	2023-04-06 00:00:00	\N
1	Turpis Nec Mauris Incorporated	93	2022-09-01 00:00:00	\N
75	Nulla interdum. Curabitur	11	2022-05-28 00:00:00	\N
76	Quisque ornare	32	2022-04-11 00:00:00	\N
77	quam, elementum	23	2022-06-24 00:00:00	\N
78	est tempor	69	2021-10-21 00:00:00	\N
79	eget	17	2023-06-30 00:00:00	\N
80	mauris blandit	43	2023-06-13 00:00:00	\N
81	fermentum	38	2022-02-05 00:00:00	\N
82	netus et	65	2022-08-29 00:00:00	\N
83	malesuada id, erat.	76	2023-03-22 00:00:00	\N
84	lorem, luctus	25	2022-06-18 00:00:00	\N
85	dapibus ligula.	75	2023-05-10 00:00:00	\N
86	ante, iaculis	53	2022-11-23 00:00:00	\N
87	magna. Cras	52	2021-08-25 00:00:00	\N
88	euismod urna.	40	2022-04-24 00:00:00	\N
89	Morbi sit amet	6	2021-08-31 00:00:00	\N
90	at lacus.	63	2023-06-09 00:00:00	\N
91	Phasellus	1	2021-12-28 00:00:00	\N
92	Quisque nonummy	4	2022-12-19 00:00:00	\N
93	Integer	28	2022-01-23 00:00:00	\N
94	orci. Ut	31	2021-11-01 00:00:00	\N
95	eu,	33	2023-07-10 00:00:00	\N
96	lorem,	74	2022-06-05 00:00:00	\N
97	dapibus	28	2022-10-23 00:00:00	\N
98	libero lacus,	30	2021-08-12 00:00:00	\N
99	erat vel	98	2023-06-17 00:00:00	\N
100	mauris sagittis placerat.	30	2021-10-05 00:00:00	\N
\.


--
-- Data for Name: communities_users; Type: TABLE DATA; Schema: public; Owner: vk_admin
--

COPY public.communities_users (community_id, user_id, created_at) FROM stdin;
1	1	2022-12-01 00:00:00
2	38	2021-10-11 00:00:00
3	18	2023-05-20 00:00:00
4	19	2023-05-19 00:00:00
5	58	2022-06-13 00:00:00
6	13	2023-05-27 00:00:00
7	74	2023-04-02 00:00:00
8	4	2021-08-24 00:00:00
9	18	2022-03-30 00:00:00
10	66	2022-08-18 00:00:00
11	99	2021-12-13 00:00:00
12	95	2022-03-31 00:00:00
13	79	2021-08-08 00:00:00
14	13	2021-09-12 00:00:00
15	92	2023-03-24 00:00:00
16	63	2021-08-05 00:00:00
17	58	2022-03-20 00:00:00
18	59	2022-05-20 00:00:00
19	60	2023-06-26 00:00:00
20	76	2023-01-19 00:00:00
21	95	2021-10-30 00:00:00
22	12	2022-05-27 00:00:00
23	27	2023-03-19 00:00:00
24	13	2022-12-09 00:00:00
25	91	2021-10-24 00:00:00
26	15	2022-02-13 00:00:00
27	38	2022-12-01 00:00:00
28	50	2023-07-07 00:00:00
29	88	2023-01-30 00:00:00
30	47	2021-10-26 00:00:00
31	33	2022-05-06 00:00:00
32	6	2023-01-09 00:00:00
33	75	2021-10-30 00:00:00
34	75	2023-03-23 00:00:00
35	26	2022-06-21 00:00:00
36	44	2023-03-29 00:00:00
37	26	2023-04-14 00:00:00
38	62	2022-01-26 00:00:00
39	98	2022-05-12 00:00:00
40	13	2023-03-19 00:00:00
41	36	2022-06-02 00:00:00
42	5	2023-04-24 00:00:00
43	1	2021-09-25 00:00:00
44	77	2022-03-08 00:00:00
45	18	2022-12-31 00:00:00
46	77	2022-03-13 00:00:00
47	83	2021-10-13 00:00:00
48	56	2022-12-07 00:00:00
49	49	2022-06-11 00:00:00
50	43	2021-12-15 00:00:00
51	67	2023-02-22 00:00:00
52	67	2022-08-11 00:00:00
53	81	2022-01-06 00:00:00
54	38	2023-01-30 00:00:00
55	60	2022-12-21 00:00:00
56	12	2022-04-10 00:00:00
57	82	2023-04-03 00:00:00
58	34	2022-01-16 00:00:00
59	42	2021-08-11 00:00:00
60	51	2023-03-17 00:00:00
61	51	2022-11-01 00:00:00
62	63	2021-11-28 00:00:00
63	22	2023-06-09 00:00:00
64	45	2021-10-25 00:00:00
65	5	2022-08-05 00:00:00
66	56	2021-10-13 00:00:00
67	60	2023-06-06 00:00:00
68	4	2021-11-08 00:00:00
69	63	2023-01-27 00:00:00
70	97	2022-12-18 00:00:00
71	84	2022-07-21 00:00:00
72	8	2022-04-05 00:00:00
73	20	2023-07-05 00:00:00
74	79	2022-04-24 00:00:00
75	83	2022-11-26 00:00:00
76	66	2022-06-14 00:00:00
77	45	2021-08-02 00:00:00
78	58	2022-08-21 00:00:00
79	39	2022-07-08 00:00:00
80	53	2022-12-16 00:00:00
81	10	2022-10-05 00:00:00
82	69	2021-11-30 00:00:00
83	59	2022-07-13 00:00:00
84	70	2023-02-16 00:00:00
85	22	2023-07-03 00:00:00
86	47	2022-03-13 00:00:00
87	27	2022-10-27 00:00:00
88	51	2022-05-30 00:00:00
89	29	2022-03-29 00:00:00
90	95	2022-02-14 00:00:00
91	46	2023-01-12 00:00:00
92	90	2023-08-09 00:00:00
93	70	2021-10-27 00:00:00
94	37	2021-09-11 00:00:00
95	42	2021-11-24 00:00:00
96	38	2023-02-04 00:00:00
97	37	2022-12-01 00:00:00
98	21	2022-08-05 00:00:00
99	17	2023-04-29 00:00:00
100	70	2022-06-23 00:00:00
\.


--
-- Data for Name: following; Type: TABLE DATA; Schema: public; Owner: vk_admin
--

COPY public.following (id, follower_id, followed_to_id, is_user, followed_at) FROM stdin;
1	14	2	f	2022-04-03 00:00:00
2	84	24	t	2022-08-05 00:00:00
3	76	69	t	2022-01-06 00:00:00
4	24	7	t	2023-05-13 00:00:00
5	62	47	t	2022-12-12 00:00:00
6	22	36	f	2023-05-23 00:00:00
7	99	54	t	2022-12-09 00:00:00
8	36	99	f	2022-11-20 00:00:00
9	64	13	f	2022-12-22 00:00:00
10	58	1	f	2022-04-24 00:00:00
11	95	34	t	2022-06-29 00:00:00
12	71	65	f	2022-01-01 00:00:00
13	81	98	t	2021-10-05 00:00:00
14	57	72	f	2021-12-02 00:00:00
15	47	26	f	2022-10-25 00:00:00
16	28	86	f	2022-07-20 00:00:00
17	7	2	f	2022-07-09 00:00:00
18	12	95	f	2023-06-24 00:00:00
19	77	42	f	2022-05-04 00:00:00
20	82	42	f	2021-09-09 00:00:00
21	58	66	f	2023-03-01 00:00:00
22	59	67	t	2023-01-07 00:00:00
23	84	29	f	2023-06-19 00:00:00
24	53	37	f	2023-02-14 00:00:00
25	25	53	t	2022-10-08 00:00:00
26	69	41	f	2022-02-01 00:00:00
27	28	46	f	2021-10-09 00:00:00
28	27	72	t	2022-11-18 00:00:00
29	89	39	f	2023-04-22 00:00:00
30	8	49	f	2022-01-23 00:00:00
31	10	64	t	2022-01-27 00:00:00
32	95	36	f	2023-01-25 00:00:00
33	30	36	f	2022-06-28 00:00:00
34	25	94	f	2021-11-08 00:00:00
35	88	14	t	2023-05-02 00:00:00
36	48	85	f	2022-03-07 00:00:00
37	21	99	t	2021-10-01 00:00:00
38	30	33	t	2023-05-08 00:00:00
39	14	35	f	2022-03-24 00:00:00
40	89	4	f	2023-02-06 00:00:00
41	63	62	f	2023-05-09 00:00:00
42	23	14	t	2023-01-31 00:00:00
43	84	23	f	2023-08-09 00:00:00
44	70	68	t	2022-06-18 00:00:00
45	92	73	f	2023-03-15 00:00:00
46	97	45	f	2021-11-01 00:00:00
47	95	74	t	2023-01-19 00:00:00
48	93	2	f	2022-01-28 00:00:00
49	34	45	t	2023-06-05 00:00:00
50	96	14	t	2023-03-19 00:00:00
51	21	37	f	2022-06-22 00:00:00
52	77	13	f	2021-08-10 00:00:00
53	5	81	t	2022-06-26 00:00:00
54	61	29	t	2023-01-28 00:00:00
55	91	96	f	2023-03-01 00:00:00
56	96	79	t	2021-08-24 00:00:00
57	53	10	f	2023-04-09 00:00:00
58	18	67	t	2022-12-11 00:00:00
59	54	54	f	2022-08-12 00:00:00
60	24	98	f	2023-02-13 00:00:00
61	82	31	t	2021-08-06 00:00:00
62	77	82	f	2023-06-21 00:00:00
63	35	62	f	2023-06-13 00:00:00
64	64	38	f	2022-04-28 00:00:00
65	76	47	f	2022-05-04 00:00:00
66	21	7	t	2023-07-07 00:00:00
67	83	46	t	2023-04-06 00:00:00
68	31	80	t	2022-09-20 00:00:00
69	94	78	f	2022-11-20 00:00:00
70	86	14	f	2021-09-02 00:00:00
71	61	65	t	2022-10-05 00:00:00
72	44	3	t	2023-04-04 00:00:00
73	58	76	f	2022-10-30 00:00:00
74	16	79	f	2022-03-12 00:00:00
75	2	56	f	2022-11-15 00:00:00
76	23	37	f	2022-08-10 00:00:00
77	2	23	t	2023-06-14 00:00:00
78	8	13	t	2022-06-20 00:00:00
79	42	12	t	2021-10-12 00:00:00
80	96	59	f	2023-04-05 00:00:00
81	49	32	f	2022-03-17 00:00:00
82	53	73	f	2022-09-10 00:00:00
83	19	74	f	2023-07-16 00:00:00
84	10	21	f	2021-08-15 00:00:00
85	93	59	t	2022-04-08 00:00:00
86	38	75	f	2021-10-07 00:00:00
87	35	28	f	2023-02-18 00:00:00
88	98	58	f	2022-11-08 00:00:00
89	44	73	f	2023-04-29 00:00:00
90	36	61	t	2022-03-17 00:00:00
91	52	46	f	2023-07-21 00:00:00
92	73	37	f	2022-09-24 00:00:00
93	16	8	t	2023-07-16 00:00:00
94	37	93	f	2021-11-20 00:00:00
95	100	65	f	2021-12-12 00:00:00
96	39	44	t	2022-03-16 00:00:00
97	21	89	t	2021-10-24 00:00:00
98	25	53	f	2022-01-19 00:00:00
99	49	97	f	2022-02-22 00:00:00
100	27	84	f	2023-04-03 00:00:00
\.


--
-- Data for Name: friendship; Type: TABLE DATA; Schema: public; Owner: vk_admin
--

COPY public.friendship (id, requested_by_user_id, requested_to_user_id, status_id, requested_at, confirmed_at) FROM stdin;
1	49	12	4	2021-07-06 00:00:00	2022-03-08 00:00:00
2	70	46	2	2021-07-06 00:00:00	2023-03-27 00:00:00
3	47	92	2	2021-07-07 00:00:00	2022-07-01 00:00:00
4	40	20	3	2021-07-02 00:00:00	2023-04-14 00:00:00
5	57	40	2	2021-07-07 00:00:00	2022-09-16 00:00:00
6	95	62	3	2021-07-02 00:00:00	2023-03-10 00:00:00
7	34	81	2	2021-07-05 00:00:00	2022-07-10 00:00:00
8	73	54	3	2021-07-07 00:00:00	2021-10-04 00:00:00
9	33	65	3	2021-07-03 00:00:00	2022-04-05 00:00:00
10	8	79	3	2021-07-06 00:00:00	2022-11-05 00:00:00
11	83	97	3	2021-07-06 00:00:00	2023-06-25 00:00:00
12	85	13	4	2021-07-06 00:00:00	2023-07-02 00:00:00
13	29	17	2	2021-07-05 00:00:00	2022-04-28 00:00:00
14	21	99	1	2021-07-03 00:00:00	2021-08-08 00:00:00
15	21	34	2	2021-07-06 00:00:00	2022-02-15 00:00:00
16	23	69	3	2021-07-03 00:00:00	2022-11-26 00:00:00
17	57	84	1	2021-07-03 00:00:00	2022-09-09 00:00:00
18	95	42	2	2021-07-02 00:00:00	2022-01-21 00:00:00
19	15	61	4	2021-07-07 00:00:00	2022-08-27 00:00:00
20	23	44	3	2021-07-03 00:00:00	2022-07-31 00:00:00
21	68	75	3	2021-07-07 00:00:00	2022-05-03 00:00:00
22	42	18	1	2021-07-02 00:00:00	2022-02-15 00:00:00
23	62	48	3	2021-07-07 00:00:00	2023-03-09 00:00:00
24	23	45	4	2021-07-03 00:00:00	2022-03-09 00:00:00
25	3	19	3	2021-07-02 00:00:00	2022-08-31 00:00:00
26	39	58	2	2021-07-04 00:00:00	2022-06-15 00:00:00
27	41	86	2	2021-07-04 00:00:00	2021-10-10 00:00:00
28	11	78	1	2021-07-06 00:00:00	2022-01-30 00:00:00
29	93	75	1	2021-07-05 00:00:00	2022-06-16 00:00:00
30	56	5	3	2021-07-04 00:00:00	2022-05-25 00:00:00
31	21	81	1	2021-07-06 00:00:00	2022-12-03 00:00:00
32	21	13	3	2021-07-04 00:00:00	2022-11-21 00:00:00
33	68	33	3	2021-07-06 00:00:00	2021-09-17 00:00:00
34	67	68	3	2021-07-07 00:00:00	2023-08-02 00:00:00
35	60	2	4	2021-07-05 00:00:00	2021-09-17 00:00:00
36	58	61	1	2021-07-07 00:00:00	2023-01-15 00:00:00
37	46	51	1	2021-07-07 00:00:00	2021-08-31 00:00:00
38	25	13	2	2021-07-05 00:00:00	2022-10-03 00:00:00
39	78	64	2	2021-07-07 00:00:00	2022-06-24 00:00:00
40	81	28	3	2021-07-05 00:00:00	2022-03-16 00:00:00
41	80	57	4	2021-07-06 00:00:00	2023-04-25 00:00:00
42	84	27	2	2021-07-02 00:00:00	2022-05-28 00:00:00
43	82	6	2	2021-07-07 00:00:00	2021-09-20 00:00:00
44	53	61	2	2021-07-06 00:00:00	2023-04-15 00:00:00
45	66	47	3	2021-07-04 00:00:00	2023-01-07 00:00:00
46	34	7	1	2021-07-04 00:00:00	2021-10-31 00:00:00
47	100	85	4	2021-07-05 00:00:00	2022-05-23 00:00:00
48	24	16	3	2021-07-06 00:00:00	2022-12-11 00:00:00
49	72	60	3	2021-07-03 00:00:00	2022-10-26 00:00:00
50	94	62	2	2021-07-06 00:00:00	2022-07-31 00:00:00
51	34	30	2	2021-07-02 00:00:00	2022-05-08 00:00:00
52	11	12	3	2021-07-03 00:00:00	2023-03-18 00:00:00
53	76	14	1	2021-07-03 00:00:00	2021-11-15 00:00:00
54	78	85	2	2021-07-04 00:00:00	2023-04-01 00:00:00
55	86	37	4	2021-07-06 00:00:00	2022-10-25 00:00:00
56	98	56	3	2021-07-04 00:00:00	2022-06-25 00:00:00
57	98	37	4	2021-07-03 00:00:00	2022-01-14 00:00:00
58	71	4	2	2021-07-07 00:00:00	2023-02-18 00:00:00
59	19	5	3	2021-07-06 00:00:00	2021-12-01 00:00:00
60	68	41	2	2021-07-02 00:00:00	2022-03-03 00:00:00
61	23	95	2	2021-07-04 00:00:00	2022-10-01 00:00:00
62	95	58	4	2021-07-07 00:00:00	2022-03-16 00:00:00
63	100	17	3	2021-07-03 00:00:00	2022-09-05 00:00:00
64	59	41	4	2021-07-06 00:00:00	2022-08-17 00:00:00
65	75	90	1	2021-07-03 00:00:00	2022-11-04 00:00:00
66	86	24	2	2021-07-02 00:00:00	2022-05-07 00:00:00
67	5	95	1	2021-07-04 00:00:00	2023-06-10 00:00:00
68	61	35	3	2021-07-07 00:00:00	2023-03-23 00:00:00
69	53	84	2	2021-07-05 00:00:00	2021-11-15 00:00:00
70	15	53	3	2021-07-02 00:00:00	2022-02-13 00:00:00
71	96	9	2	2021-07-07 00:00:00	2023-01-14 00:00:00
72	17	61	1	2021-07-07 00:00:00	2023-06-25 00:00:00
73	98	31	2	2021-07-04 00:00:00	2022-11-12 00:00:00
74	93	27	3	2021-07-06 00:00:00	2022-05-30 00:00:00
75	24	69	4	2021-07-02 00:00:00	2022-05-28 00:00:00
76	55	50	1	2021-07-06 00:00:00	2023-04-25 00:00:00
77	98	83	2	2021-07-06 00:00:00	2023-06-29 00:00:00
78	10	45	3	2021-07-07 00:00:00	2023-03-19 00:00:00
79	13	24	4	2021-07-06 00:00:00	2021-08-23 00:00:00
80	45	4	2	2021-07-05 00:00:00	2022-11-02 00:00:00
81	11	38	2	2021-07-07 00:00:00	2023-02-23 00:00:00
82	6	49	4	2021-07-04 00:00:00	2022-04-11 00:00:00
83	51	51	1	2021-07-06 00:00:00	2022-01-04 00:00:00
84	77	92	4	2021-07-04 00:00:00	2022-08-24 00:00:00
85	38	14	4	2021-07-03 00:00:00	2023-02-04 00:00:00
86	38	47	3	2021-07-03 00:00:00	2023-01-12 00:00:00
87	32	63	3	2021-07-07 00:00:00	2022-08-20 00:00:00
88	92	66	3	2021-07-06 00:00:00	2023-07-22 00:00:00
89	56	57	3	2021-07-07 00:00:00	2022-03-20 00:00:00
90	95	68	1	2021-07-05 00:00:00	2021-12-27 00:00:00
91	17	13	1	2021-07-02 00:00:00	2022-04-29 00:00:00
92	86	81	1	2021-07-02 00:00:00	2022-06-22 00:00:00
93	61	34	2	2021-07-02 00:00:00	2022-01-01 00:00:00
94	14	98	3	2021-07-07 00:00:00	2022-04-12 00:00:00
95	6	55	1	2021-07-04 00:00:00	2021-08-02 00:00:00
96	23	99	3	2021-07-04 00:00:00	2022-01-27 00:00:00
97	8	62	2	2021-07-02 00:00:00	2022-08-11 00:00:00
98	56	54	3	2021-07-02 00:00:00	2022-05-14 00:00:00
99	95	12	4	2021-07-05 00:00:00	2023-07-21 00:00:00
100	93	78	1	2021-07-05 00:00:00	2023-08-03 00:00:00
\.


--
-- Data for Name: friendship_statuses; Type: TABLE DATA; Schema: public; Owner: vk_admin
--

COPY public.friendship_statuses (id, name) FROM stdin;
1	sending
2	send
3	accepted
4	declined
5	test
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: vk_admin
--

COPY public.messages (id, from_user_id, to_user_id, body, is_important, is_delivered, created_at) FROM stdin;
1	10	55	feugiat nec, diam. Duis	f	t	2023-07-23 00:00:00
2	93	19	nisi magna sed dui. Fusce aliquam, enim nec	f	t	2021-10-29 00:00:00
3	58	73	rutrum eu, ultrices sit amet,	f	t	2022-10-02 00:00:00
4	2	73	Nullam vitae	t	f	2022-08-18 00:00:00
5	86	60	euismod in,	t	f	2022-01-30 00:00:00
6	22	5	luctus et ultrices posuere	f	f	2022-12-26 00:00:00
7	81	89	egestas. Fusce aliquet magna a neque.	t	t	2022-01-01 00:00:00
8	76	58	iaculis,	f	f	2022-08-14 00:00:00
9	64	4	Suspendisse eleifend.	f	t	2021-10-26 00:00:00
10	15	22	Mauris ut quam vel sapien imperdiet ornare. In faucibus.	f	f	2023-05-17 00:00:00
11	55	38	id nunc	t	f	2022-12-11 00:00:00
12	80	49	pede blandit congue. In scelerisque scelerisque dui.	f	f	2021-08-24 00:00:00
13	26	85	vitae,	t	f	2022-07-27 00:00:00
14	8	95	vel arcu. Curabitur ut odio vel est tempor bibendum.	f	t	2022-10-09 00:00:00
15	84	51	Aliquam auctor,	f	f	2023-06-08 00:00:00
16	98	65	felis. Nulla tempor	f	f	2022-12-16 00:00:00
17	40	23	sem, consequat nec, mollis vitae,	f	t	2023-07-11 00:00:00
18	77	32	lacinia at, iaculis quis, pede. Praesent eu dui.	f	t	2022-11-16 00:00:00
19	61	52	a	f	t	2023-05-11 00:00:00
20	23	40	tincidunt aliquam arcu. Aliquam ultrices iaculis odio.	t	t	2022-05-25 00:00:00
21	26	43	amet, consectetuer adipiscing elit. Aliquam auctor, velit	t	f	2021-10-03 00:00:00
22	80	72	facilisis lorem tristique	f	t	2022-04-01 00:00:00
23	10	89	dictum augue malesuada malesuada. Integer id	t	f	2022-07-08 00:00:00
24	70	4	sem semper erat, in consectetuer ipsum nunc id	f	f	2021-09-29 00:00:00
25	81	17	Nullam	f	f	2023-05-27 00:00:00
26	65	38	id magna et	f	t	2022-09-24 00:00:00
27	26	81	arcu. Morbi sit amet massa. Quisque porttitor	f	t	2022-07-17 00:00:00
28	67	59	eget lacus. Mauris non dui nec	t	f	2021-11-04 00:00:00
29	71	65	luctus et ultrices posuere cubilia	f	f	2021-08-05 00:00:00
30	96	59	Nunc mauris sapien, cursus in, hendrerit	f	f	2021-08-23 00:00:00
31	81	31	Nullam scelerisque neque sed	t	f	2022-10-19 00:00:00
32	58	94	vestibulum lorem, sit amet ultricies sem magna nec	f	f	2022-11-30 00:00:00
33	68	29	hendrerit a, arcu. Sed et libero. Proin mi.	t	t	2023-02-20 00:00:00
34	86	64	Pellentesque	f	t	2021-08-20 00:00:00
35	20	20	vestibulum lorem, sit amet ultricies sem magna nec quam. Curabitur	f	f	2022-08-02 00:00:00
36	48	6	tortor nibh sit amet orci. Ut sagittis	f	t	2023-02-09 00:00:00
37	30	94	at augue id ante dictum	f	f	2022-03-23 00:00:00
38	97	3	ipsum dolor sit amet, consectetuer adipiscing	t	f	2022-04-06 00:00:00
39	33	30	rutrum. Fusce dolor quam, elementum at, egestas a,	t	t	2022-09-27 00:00:00
40	57	31	dis parturient montes, nascetur ridiculus	f	f	2021-12-31 00:00:00
41	57	65	Proin vel nisl. Quisque fringilla euismod enim. Etiam	f	f	2022-05-05 00:00:00
42	83	22	Ut tincidunt orci quis lectus. Nullam suscipit, est ac	t	t	2022-05-05 00:00:00
43	34	86	semper pretium neque. Morbi quis urna. Nunc quis arcu	f	t	2022-07-22 00:00:00
44	64	55	diam eu dolor egestas rhoncus. Proin	f	f	2021-08-25 00:00:00
45	58	30	montes, nascetur ridiculus mus. Proin vel	t	t	2021-10-06 00:00:00
46	89	54	vel	t	t	2023-01-24 00:00:00
47	83	56	diam. Proin dolor. Nulla semper tellus id	t	f	2022-03-09 00:00:00
48	83	40	eu eros. Nam	f	t	2023-06-06 00:00:00
49	27	35	velit. Sed malesuada augue ut lacus. Nulla tincidunt, neque	t	f	2023-04-20 00:00:00
50	64	7	ut, sem. Nulla interdum. Curabitur dictum. Phasellus in felis.	f	f	2021-09-07 00:00:00
51	62	33	et risus. Quisque libero lacus, varius et, euismod	t	t	2022-09-24 00:00:00
52	5	96	tempus eu, ligula. Aenean euismod mauris eu elit.	f	f	2023-07-03 00:00:00
53	96	39	varius ultrices,	f	t	2021-09-15 00:00:00
54	67	8	diam at pretium	f	f	2022-12-27 00:00:00
55	74	37	auctor, nunc nulla vulputate dui, nec tempus mauris erat eget	f	t	2022-09-06 00:00:00
56	22	71	sagittis augue,	f	f	2022-02-08 00:00:00
57	60	67	a, scelerisque sed, sapien.	t	t	2023-07-03 00:00:00
58	77	14	erat neque	f	t	2022-03-09 00:00:00
59	99	47	Morbi	t	t	2022-11-30 00:00:00
60	14	93	purus ac tellus. Suspendisse sed	f	f	2022-06-06 00:00:00
61	31	2	Nam	f	t	2021-08-31 00:00:00
62	34	47	orci. Phasellus dapibus	f	f	2022-12-09 00:00:00
63	22	62	ultricies ligula. Nullam enim.	f	f	2021-07-18 00:00:00
64	3	24	pellentesque, tellus sem mollis dui, in sodales elit	f	f	2022-04-06 00:00:00
65	15	56	eu eros. Nam consequat dolor vitae	t	f	2021-12-09 00:00:00
66	39	67	conubia nostra, per inceptos hymenaeos.	f	f	2022-07-28 00:00:00
67	20	59	ultrices, mauris ipsum porta elit,	f	f	2023-07-27 00:00:00
68	17	20	lacus vestibulum lorem, sit amet ultricies	f	t	2022-05-03 00:00:00
69	88	23	dui quis accumsan convallis,	f	f	2022-02-09 00:00:00
70	83	79	velit in aliquet lobortis, nisi	f	t	2023-06-16 00:00:00
71	75	91	pharetra ut, pharetra sed, hendrerit a, arcu. Sed et	t	f	2022-11-30 00:00:00
72	58	69	justo eu arcu. Morbi sit amet massa. Quisque	f	f	2022-04-13 00:00:00
73	60	96	Duis mi enim, condimentum	t	t	2022-02-19 00:00:00
74	4	40	habitant morbi tristique senectus et netus	t	f	2021-08-12 00:00:00
75	21	81	magnis	t	f	2022-08-17 00:00:00
76	50	79	at, nisi. Cum	f	t	2021-10-06 00:00:00
77	57	97	cursus et, eros. Proin ultrices. Duis volutpat	f	t	2023-02-07 00:00:00
78	74	33	euismod est arcu ac orci. Ut semper	t	f	2022-09-03 00:00:00
79	11	36	mi eleifend egestas. Sed pharetra, felis eget	f	f	2022-06-19 00:00:00
80	84	16	Donec tempor, est	t	t	2022-01-28 00:00:00
81	76	51	natoque penatibus et	t	f	2021-11-06 00:00:00
82	61	95	fringilla. Donec feugiat	f	f	2022-01-26 00:00:00
83	34	69	neque. Nullam ut nisi a	f	f	2022-05-05 00:00:00
84	59	74	vel sapien imperdiet	f	t	2023-03-07 00:00:00
85	2	46	morbi tristique senectus et netus et	t	t	2022-10-16 00:00:00
86	74	82	lobortis. Class aptent taciti sociosqu ad litora torquent	t	f	2022-05-09 00:00:00
87	33	83	egestas.	t	f	2022-02-26 00:00:00
88	24	54	non sapien molestie orci tincidunt adipiscing. Mauris molestie pharetra	t	t	2022-10-17 00:00:00
89	7	79	tellus. Nunc lectus pede, ultrices a,	f	t	2023-01-01 00:00:00
90	84	32	eu lacus. Quisque imperdiet,	t	t	2021-12-30 00:00:00
91	72	59	sem molestie	t	f	2022-04-01 00:00:00
92	74	48	justo nec ante. Maecenas	f	t	2022-01-18 00:00:00
93	46	23	facilisis lorem tristique aliquet. Phasellus fermentum	f	f	2023-01-25 00:00:00
94	70	60	quis massa. Mauris vestibulum, neque sed dictum eleifend, nunc risus	t	t	2023-06-08 00:00:00
95	71	21	lorem, auctor quis, tristique ac, eleifend vitae, erat. Vivamus	t	t	2022-09-20 00:00:00
96	17	98	justo. Proin non massa non ante	f	f	2022-11-28 00:00:00
97	42	32	dolor quam, elementum at, egestas a, scelerisque	f	t	2023-02-05 00:00:00
98	64	68	magna a neque. Nullam ut nisi a odio semper	f	f	2022-03-20 00:00:00
99	32	53	iaculis	f	t	2022-09-17 00:00:00
100	85	89	tristique pharetra. Quisque ac	f	t	2022-06-10 00:00:00
\.


--
-- Data for Name: photo; Type: TABLE DATA; Schema: public; Owner: vk_admin
--

COPY public.photo (id, url, owner_id, description, uploaded_at, size) FROM stdin;
16	http://google.com/user/110?str=se	22	eros turpis non enim. Mauris	2022-01-15 00:00:00	3242
17	http://wikipedia.org/fr?str=se	32	enim. Curabitur massa. Vestibulum accumsan neque et nunc.	2022-04-08 00:00:00	2617
18	http://guardian.co.uk/fr?k=0	79	mattis semper,	2022-11-24 00:00:00	9860
19	http://yahoo.com/en-us?g=1	59	Sed neque. Sed	2021-10-29 00:00:00	8520
20	https://walmart.com/settings?page=1&offset=1	71	urna. Ut	2023-06-08 00:00:00	4612
21	http://baidu.com/en-ca?gi=100	20	a, magna. Lorem ipsum dolor sit	2021-09-02 00:00:00	2196
22	https://guardian.co.uk/user/110?search=1	81	et, commodo at, libero. Morbi accumsan laoreet ipsum. Curabitur	2022-05-19 00:00:00	8275
23	https://zoom.us/sub?k=0	82	ut dolor dapibus gravida. Aliquam tincidunt,	2022-11-12 00:00:00	6731
24	https://reddit.com/en-us?page=1&offset=1	94	tempus mauris erat eget	2022-01-06 00:00:00	525
25	http://google.com/user/110?q=4	9	justo eu	2022-05-21 00:00:00	3037
26	https://whatsapp.com/sub?ab=441&aad=2	95	molestie arcu. Sed eu nibh vulputate	2023-07-03 00:00:00	8745
27	http://youtube.com/settings?page=1&offset=1	73	Cras sed	2023-04-22 00:00:00	1399
28	https://twitter.com/user/110?q=11	56	nec, diam. Duis mi enim, condimentum	2022-03-29 00:00:00	394
30	https://wikipedia.org/sub?q=test	74	pellentesque a, facilisis non, bibendum	2022-05-18 00:00:00	2477
31	https://wikipedia.org/en-us?str=se	13	scelerisque neque sed sem	2021-09-24 00:00:00	4286
32	http://pinterest.com/fr?page=1&offset=1	57	nascetur ridiculus mus.	2021-10-12 00:00:00	8353
33	https://zoom.us/user/110?client=g	54	metus eu erat semper rutrum. Fusce	2022-07-08 00:00:00	5212
34	http://twitter.com/site?search=1&q=de	52	ornare sagittis felis. Donec tempor, est ac mattis	2023-05-27 00:00:00	374
35	http://pinterest.com/site?str=se	81	augue. Sed molestie. Sed id risus	2021-11-11 00:00:00	2518
36	https://yahoo.com/settings?page=1&offset=1	17	eu erat semper rutrum. Fusce dolor quam, elementum at, egestas	2023-01-15 00:00:00	9479
37	https://bbc.co.uk/sub?q=11	69	quis, tristique ac,	2021-09-21 00:00:00	342
38	http://yahoo.com/one?gi=100	57	egestas. Fusce aliquet magna a neque.	2022-11-30 00:00:00	3270
39	https://pinterest.com/sub/cars?gi=100	21	euismod enim. Etiam gravida molestie	2022-05-10 00:00:00	4621
40	https://cnn.com/en-ca?search=1	14	sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus	2023-03-23 00:00:00	6474
41	http://ebay.com/group/9?g=1	39	Duis a mi fringilla mi lacinia	2022-02-27 00:00:00	7856
42	https://twitter.com/group/9?search=1	64	adipiscing elit.	2023-04-17 00:00:00	893
43	http://facebook.com/one?q=test	95	mauris sagittis placerat. Cras dictum ultricies ligula. Nullam	2022-08-24 00:00:00	4723
44	http://facebook.com/user/110?client=g	57	ornare. Fusce mollis. Duis sit	2022-07-02 00:00:00	6459
45	https://whatsapp.com/en-ca?client=g	38	Suspendisse commodo tincidunt nibh.	2022-04-11 00:00:00	5710
46	http://twitter.com/fr?p=8	76	molestie pharetra nibh. Aliquam ornare, libero at auctor ullamcorper, nisl	2022-04-03 00:00:00	8005
47	https://google.com/sub?search=1&q=de	18	pede ac urna. Ut	2021-10-21 00:00:00	1158
48	https://google.com/settings?ab=441&aad=2	37	Curabitur dictum. Phasellus	2022-08-30 00:00:00	9090
49	https://nytimes.com/settings?p=8	74	ac	2021-11-16 00:00:00	5289
50	http://wikipedia.org/en-us?client=g	89	euismod est arcu ac orci. Ut semper pretium	2021-08-31 00:00:00	706
51	https://nytimes.com/user/110?q=test	40	Sed molestie. Sed id risus quis	2022-03-04 00:00:00	419
52	https://cnn.com/one?q=4	87	in felis. Nulla tempor augue ac ipsum. Phasellus	2023-05-26 00:00:00	8112
53	http://google.com/group/9?q=11	24	Aenean massa. Integer vitae nibh. Donec est mauris, rhoncus id,	2021-09-12 00:00:00	815
54	http://youtube.com/en-ca?ab=441&aad=2	82	leo. Morbi neque tellus, imperdiet non,	2023-02-22 00:00:00	6669
55	http://facebook.com/en-us?str=se	80	eget, venenatis a, magna. Lorem ipsum dolor sit	2022-11-04 00:00:00	2748
56	https://walmart.com/en-us?q=test	11	magna, malesuada vel,	2022-01-08 00:00:00	2709
57	http://naver.com/fr?search=1&q=de	75	Duis elementum, dui quis accumsan convallis, ante lectus	2023-06-18 00:00:00	6915
58	http://instagram.com/one?p=8	59	orci sem eget massa. Suspendisse eleifend. Cras	2021-09-11 00:00:00	7846
59	http://youtube.com/en-ca?gi=100	96	ipsum non arcu. Vivamus sit amet risus. Donec egestas. Aliquam	2021-11-27 00:00:00	5281
60	http://ebay.com/en-ca?search=1	100	purus. Duis elementum, dui quis accumsan convallis, ante	2021-08-10 00:00:00	3484
61	https://yahoo.com/settings?client=g	53	consequat purus.	2022-05-10 00:00:00	3326
62	http://guardian.co.uk/group/9?q=test	82	egestas nunc sed libero. Proin	2022-03-24 00:00:00	8449
63	https://nytimes.com/group/9?page=1&offset=1	9	adipiscing non, luctus sit amet, faucibus ut, nulla.	2023-03-24 00:00:00	7564
64	http://zoom.us/fr?search=1&q=de	94	quis massa. Mauris vestibulum, neque sed dictum	2023-05-21 00:00:00	3493
65	http://walmart.com/settings?search=1	15	et, eros.	2022-03-14 00:00:00	1008
66	https://instagram.com/en-us?search=1	8	neque. Nullam	2021-08-15 00:00:00	730
67	https://walmart.com/one?q=0	91	cursus. Integer mollis. Integer tincidunt aliquam arcu. Aliquam ultrices iaculis	2021-12-14 00:00:00	8145
68	http://baidu.com/en-us?str=se	70	quis lectus. Nullam suscipit,	2022-06-14 00:00:00	1739
69	https://facebook.com/group/9?p=8	82	bibendum. Donec felis orci,	2023-05-21 00:00:00	8720
70	https://reddit.com/group/9?q=0	67	non, hendrerit id, ante. Nunc mauris sapien,	2022-12-30 00:00:00	6733
71	http://nytimes.com/en-us?k=0	14	Integer sem elit, pharetra ut, pharetra sed,	2022-05-19 00:00:00	9028
72	http://wikipedia.org/site?search=1&q=de	36	erat neque	2022-03-15 00:00:00	4594
73	http://pinterest.com/en-us?q=11	87	molestie tortor nibh sit amet	2022-03-19 00:00:00	178
74	http://twitter.com/one?search=1&q=de	53	Aenean massa. Integer vitae	2022-04-04 00:00:00	8301
75	http://netflix.com/en-us?gi=100	82	et netus et malesuada fames	2021-09-09 00:00:00	8232
76	https://instagram.com/en-ca?ad=115	99	tempor	2022-11-11 00:00:00	5241
77	https://cnn.com/sub/cars?k=0	14	sed, facilisis vitae, orci. Phasellus dapibus quam quis diam.	2022-08-11 00:00:00	4384
78	http://cnn.com/settings?p=8	19	Vivamus rhoncus. Donec est. Nunc	2022-11-06 00:00:00	2618
79	http://ebay.com/en-us?q=test	78	Ut sagittis lobortis mauris. Suspendisse aliquet	2021-10-22 00:00:00	3001
80	https://nytimes.com/sub?p=8	89	lorem fringilla ornare placerat, orci lacus	2023-08-03 00:00:00	9673
81	https://whatsapp.com/sub/cars?k=0	75	Integer mollis. Integer tincidunt aliquam arcu.	2021-12-08 00:00:00	9339
82	http://walmart.com/site?gi=100	79	in, dolor. Fusce feugiat. Lorem ipsum dolor sit	2023-03-22 00:00:00	323
83	https://wikipedia.org/group/9?gi=100	94	morbi tristique senectus	2021-12-21 00:00:00	2660
84	http://whatsapp.com/sub/cars?g=1	11	mollis. Duis sit amet diam eu dolor egestas	2021-08-22 00:00:00	687
85	http://walmart.com/sub/cars?g=1	95	quis turpis	2021-10-14 00:00:00	3753
86	https://walmart.com/en-us?ad=115	10	eleifend non,	2021-12-25 00:00:00	8140
87	https://ebay.com/group/9?str=se	68	Duis dignissim	2022-10-01 00:00:00	3806
88	https://facebook.com/en-us?search=1	48	magnis dis	2023-07-13 00:00:00	1871
89	http://cnn.com/settings?k=0	30	ornare, lectus ante dictum	2023-02-23 00:00:00	2767
90	http://walmart.com/user/110?ab=441&aad=2	20	imperdiet dictum magna. Ut tincidunt	2022-07-05 00:00:00	3073
91	http://walmart.com/sub?k=0	44	torquent per conubia nostra, per inceptos hymenaeos. Mauris	2023-03-27 00:00:00	9038
92	https://ebay.com/sub/cars?ab=441&aad=2	88	orci. Ut sagittis lobortis mauris. Suspendisse aliquet molestie tellus.	2023-05-06 00:00:00	5869
93	http://cnn.com/user/110?gi=100	69	egestas blandit. Nam nulla	2023-03-08 00:00:00	5267
94	https://zoom.us/settings?gi=100	43	Quisque ac libero nec ligula	2021-09-16 00:00:00	5841
95	https://netflix.com/settings?str=se	37	sapien. Aenean massa. Integer vitae nibh. Donec est	2023-01-07 00:00:00	8866
96	https://bbc.co.uk/sub?ad=115	37	mi fringilla mi lacinia mattis. Integer	2021-10-01 00:00:00	6055
97	http://bbc.co.uk/en-ca?k=0	86	ligula. Nullam	2022-09-18 00:00:00	8062
98	https://bbc.co.uk/en-us?ad=115	17	ante dictum cursus. Nunc mauris elit,	2022-04-25 00:00:00	5427
100	https://naver.com/one?q=4	47	tincidunt aliquam arcu. Aliquam ultrices iaculis odio. Nam	2022-07-20 00:00:00	3273
1	https://walmart.com/sub/cars?client=g	69	Phasellus vitae mauris sit amet lorem semper auctor. Mauris	2022-09-07 00:00:00	3362
2	http://ebay.com/group/9?q=11	94	sed dui. Fusce aliquam, enim nec tempus scelerisque, lorem	2022-12-05 00:00:00	2335
3	https://instagram.com/one?str=se	27	id, mollis nec, cursus a, enim. Suspendisse aliquet, sem	2023-03-11 00:00:00	5645
4	http://naver.com/sub?q=test	34	nec, cursus a, enim. Suspendisse aliquet, sem ut cursus	2021-08-25 00:00:00	9785
5	https://baidu.com/en-ca?search=1&q=de	31	pellentesque, tellus sem mollis dui, in sodales elit erat vitae	2021-08-08 00:00:00	2827
6	http://naver.com/en-ca?search=1&q=de	58	hendrerit consectetuer, cursus et, magna. Praesent interdum ligula eu enim.	2021-08-29 00:00:00	8755
7	https://wikipedia.org/sub?k=0	56	eu tellus. Phasellus elit pede, malesuada vel,	2023-01-04 00:00:00	6166
8	http://naver.com/one?p=8	40	magna. Sed	2021-10-02 00:00:00	7823
9	http://walmart.com/fr?ab=441&aad=2	41	molestie arcu. Sed eu nibh vulputate mauris sagittis	2021-08-02 00:00:00	1862
10	http://bbc.co.uk/fr?search=1	22	nisi magna sed dui. Fusce	2022-08-23 00:00:00	9134
11	https://whatsapp.com/site?q=11	39	turpis egestas. Aliquam fringilla cursus purus. Nullam scelerisque neque	2023-05-31 00:00:00	1648
12	https://twitter.com/fr?search=1&q=de	92	sed, hendrerit	2022-07-04 00:00:00	7772
13	http://zoom.us/sub/cars?q=4	51	In mi pede, nonummy ut, molestie in, tempus	2021-11-07 00:00:00	8351
14	http://facebook.com/fr?search=1&q=de	39	Nam	2022-08-29 00:00:00	4802
15	https://walmart.com/fr?q=4	77	fringilla purus mauris a nunc. In at pede. Cras	2023-01-26 00:00:00	8727
29	https://youtube.com/one?q=11	29	elit erat vitae risus. Duis a mi fringilla mi lacinia	2022-02-02 00:00:00	3411
99	https://instagram.com/sub?q=11	29	Nullam scelerisque neque sed sem	2023-05-24 00:00:00	4281
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: vk_admin
--

COPY public.profiles (user_id, main_photo_id, user_contacts, created_at) FROM stdin;
21	42	(est@somemail.ru,luctus@outlook.org)	2022-05-23 00:00:00
2	59	(269-7584,quisque.purus.sapien@icloud.couk)	2021-10-30 00:00:00
3	30	(632-5791,ipsum.nunc.id@protonmail.edu)	2021-07-05 00:00:00
4	96	(527-6584,et.risus@protonmail.ca)	2022-11-10 00:00:00
5	75	(867-5615,sit.amet.risus@protonmail.couk)	2023-01-23 00:00:00
6	46	(255-1975,phasellus.fermentum.convallis@icloud.org)	2023-08-03 00:00:00
7	34	(992-2378,sodales.mauris@hotmail.net)	2023-02-28 00:00:00
8	54	(437-4645,donec@google.org)	2022-09-16 00:00:00
9	75	(771-8392,dolor@icloud.com)	2022-05-12 00:00:00
10	87	(357-8333,taciti.sociosqu.ad@protonmail.org)	2023-06-20 00:00:00
11	33	(834-7234,nunc.sed.orci@aol.org)	2022-08-14 00:00:00
12	73	(428-8723,fusce.dolor.quam@protonmail.edu)	2022-12-10 00:00:00
13	82	(336-2157,curabitur.consequat@yahoo.ca)	2022-04-10 00:00:00
14	49	(285-1713,lectus.sit@icloud.edu)	2022-02-16 00:00:00
15	43	(416-7654,integer.in@hotmail.couk)	2023-08-04 00:00:00
16	86	(484-2912,cras.dolor.dolor@yahoo.couk)	2022-08-05 00:00:00
17	97	(778-5117,convallis.est@yahoo.com)	2021-08-31 00:00:00
18	11	(546-2337,tellus@outlook.com)	2022-10-31 00:00:00
19	81	(412-2037,justo@hotmail.net)	2023-04-26 00:00:00
20	85	(856-6976,sem.magna@outlook.ca)	2023-07-09 00:00:00
22	33	(573-5659,hendrerit.consectetuer@outlook.couk)	2022-09-28 00:00:00
23	32	(753-9499,ut.molestie.in@yahoo.net)	2022-09-23 00:00:00
24	51	(668-8169,magna.malesuada@hotmail.edu)	2022-03-24 00:00:00
26	82	(623-7803,vitae.semper@aol.ca)	2022-11-22 00:00:00
27	37	(735-0746,sed@protonmail.org)	2022-03-22 00:00:00
29	99	(872-3172,sit.amet@google.couk)	2023-01-01 00:00:00
30	79	(775-3839,eu.eros@outlook.edu)	2023-04-16 00:00:00
31	66	(441-1442,urna.nec@icloud.net)	2022-09-24 00:00:00
32	24	(570-1513,eleifend.egestas@protonmail.org)	2022-11-09 00:00:00
33	18	(310-0338,magna@hotmail.couk)	2022-03-25 00:00:00
34	18	(272-5352,aenean.sed@outlook.org)	2022-10-07 00:00:00
35	74	(811-3808,vel@outlook.org)	2022-01-23 00:00:00
36	75	(455-4624,in@aol.org)	2022-11-09 00:00:00
37	16	(865-3760,lacus@icloud.com)	2022-07-10 00:00:00
38	83	(972-3106,a.enim.suspendisse@aol.ca)	2021-10-29 00:00:00
39	36	(450-4760,mauris@google.net)	2021-10-01 00:00:00
40	87	(578-4518,congue@outlook.org)	2021-08-29 00:00:00
41	20	(637-4443,cursus.in@outlook.org)	2022-03-17 00:00:00
42	75	(725-1214,iaculis.nec.eleifend@hotmail.couk)	2021-10-06 00:00:00
43	63	(942-3418,in.lorem@icloud.edu)	2022-08-03 00:00:00
44	88	(880-7366,condimentum.eget@outlook.org)	2023-03-24 00:00:00
45	76	(412-4525,elit@aol.org)	2022-01-03 00:00:00
46	2	(620-1692,semper@yahoo.couk)	2022-07-08 00:00:00
47	9	(462-8451,enim.diam.vel@protonmail.com)	2022-04-10 00:00:00
48	73	(878-8714,lobortis@aol.couk)	2022-04-05 00:00:00
49	23	(955-6707,lacus.aliquam@hotmail.org)	2021-12-22 00:00:00
50	72	(166-8662,dui.nec.tempus@yahoo.edu)	2022-01-15 00:00:00
51	1	(837-5417,dui.nec.urna@outlook.com)	2021-12-03 00:00:00
52	26	(685-2666,lorem.donec@outlook.edu)	2021-10-18 00:00:00
53	65	(295-7752,sagittis@google.com)	2021-07-23 00:00:00
54	57	(808-7786,adipiscing@yahoo.ca)	2022-07-21 00:00:00
55	24	(866-4262,sem.ut@outlook.edu)	2021-10-28 00:00:00
56	20	(696-2827,dolor.dapibus.gravida@hotmail.ca)	2023-04-25 00:00:00
57	37	(882-1601,curabitur.sed.tortor@protonmail.ca)	2022-03-18 00:00:00
58	71	(240-5158,molestie@hotmail.ca)	2023-01-04 00:00:00
59	29	(492-6104,egestas.fusce.aliquet@outlook.com)	2022-08-01 00:00:00
60	37	(471-5054,non.arcu@protonmail.net)	2022-12-04 00:00:00
61	37	(154-2137,cras.dolor@protonmail.net)	2022-12-14 00:00:00
62	79	(626-7173,tincidunt@hotmail.couk)	2022-11-27 00:00:00
63	40	(763-1097,eu.lacus@google.net)	2022-12-17 00:00:00
64	41	(382-2711,elit@google.ca)	2022-01-24 00:00:00
65	3	(128-6615,nulla.aliquet.proin@protonmail.org)	2022-02-19 00:00:00
66	13	(865-6324,euismod.mauris@google.couk)	2022-06-21 00:00:00
67	95	(273-4673,elit.pretium@aol.couk)	2022-01-04 00:00:00
68	88	(531-3732,ut@icloud.org)	2023-01-11 00:00:00
69	29	(463-3158,convallis.dolor@outlook.edu)	2023-07-02 00:00:00
70	83	(160-9300,ridiculus.mus@protonmail.ca)	2022-03-29 00:00:00
71	27	(702-5995,arcu.vestibulum.ante@aol.org)	2023-01-23 00:00:00
72	97	(905-8289,eu.dolor.egestas@yahoo.ca)	2022-01-10 00:00:00
73	10	(181-4185,arcu.vivamus.sit@protonmail.net)	2021-07-16 00:00:00
74	1	(667-8865,rhoncus.proin@protonmail.couk)	2022-03-25 00:00:00
75	42	(776-5123,ante.bibendum@icloud.com)	2023-01-13 00:00:00
76	85	(551-3181,lorem@yahoo.ca)	2022-09-21 00:00:00
77	24	(442-1728,et.magnis.dis@outlook.couk)	2023-02-07 00:00:00
78	45	(778-7357,sed.molestie@icloud.edu)	2022-05-05 00:00:00
79	16	(342-1115,leo@outlook.couk)	2022-05-17 00:00:00
80	95	(430-0949,aliquet.magna@protonmail.ca)	2022-05-06 00:00:00
1	\N	(296-9816,velit.eu.sem@icloud.com)	2023-06-19 00:00:00
25	\N	(503-1249,cras.eu@icloud.edu)	2023-03-06 00:00:00
81	56	(936-8389,vel@yahoo.org)	2021-09-05 00:00:00
82	22	(893-0667,tincidunt.vehicula@google.couk)	2021-08-23 00:00:00
83	59	(871-8490,justo.eu.arcu@aol.ca)	2022-05-14 00:00:00
84	10	(313-1923,odio@hotmail.ca)	2022-11-18 00:00:00
85	8	(191-3559,mus@yahoo.org)	2022-01-21 00:00:00
86	5	(667-7852,montes.nascetur@yahoo.edu)	2022-08-18 00:00:00
87	18	(585-3553,tellus@google.ca)	2021-12-22 00:00:00
88	6	(344-8175,ornare.egestas@icloud.couk)	2023-02-06 00:00:00
89	6	(326-7915,purus.maecenas.libero@aol.couk)	2021-12-24 00:00:00
90	89	(288-3768,aliquam.ultrices@yahoo.couk)	2023-02-27 00:00:00
91	23	(635-2241,sem.vitae@google.couk)	2022-04-03 00:00:00
92	24	(440-7744,sem.magna@outlook.edu)	2022-11-18 00:00:00
93	73	(343-6347,magna.cras.convallis@icloud.com)	2023-02-21 00:00:00
94	62	(312-3883,donec@outlook.edu)	2022-07-09 00:00:00
95	99	(375-7351,donec.sollicitudin.adipiscing@aol.ca)	2021-10-13 00:00:00
96	45	(760-6934,id.magna@aol.com)	2022-04-02 00:00:00
97	34	(403-3544,ante@outlook.couk)	2022-07-26 00:00:00
98	15	(575-5646,et.nunc@aol.net)	2022-02-10 00:00:00
99	46	(723-1552,ipsum@yahoo.org)	2022-04-03 00:00:00
100	94	(476-5182,amet@yahoo.couk)	2021-11-24 00:00:00
28	\N	(641-5767,quis.turpis.vitae@icloud.net)	2023-07-30 00:00:00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: vk_admin
--

COPY public.users (id, first_name, last_name, email, phone) FROM stdin;
21	Noble	Vincent	luctus@outlook.org	365-3886
1	Erin	Thomas	velit.eu.sem@icloud.com	296-9816
2	Simone	Shannon	quisque.purus.sapien@icloud.couk	269-7584
3	Baxter	Collier	ipsum.nunc.id@protonmail.edu	632-5791
4	Kiayada	Rojas	et.risus@protonmail.ca	527-6584
5	Darius	Banks	sit.amet.risus@protonmail.couk	867-5615
6	Hammett	Garrison	phasellus.fermentum.convallis@icloud.org	255-1975
7	Paula	Bean	sodales.mauris@hotmail.net	992-2378
8	Brendan	Whitney	donec@google.org	437-4645
9	Yasir	Horn	dolor@icloud.com	771-8392
10	Armando	Morris	taciti.sociosqu.ad@protonmail.org	357-8333
11	Elaine	Bentley	nunc.sed.orci@aol.org	834-7234
12	Lacota	Serrano	fusce.dolor.quam@protonmail.edu	428-8723
13	Fletcher	Hull	curabitur.consequat@yahoo.ca	336-2157
14	Ivory	Dale	lectus.sit@icloud.edu	285-1713
15	Tallulah	Padilla	integer.in@hotmail.couk	416-7654
16	Kellie	Lee	cras.dolor.dolor@yahoo.couk	484-2912
17	Miranda	Mcmahon	convallis.est@yahoo.com	778-5117
18	Russell	Whitehead	tellus@outlook.com	546-2337
19	Geoffrey	Gonzalez	justo@hotmail.net	412-2037
20	Ebony	Holt	sem.magna@outlook.ca	856-6976
22	Aileen	Townsend	hendrerit.consectetuer@outlook.couk	573-5659
23	Denton	Atkins	ut.molestie.in@yahoo.net	753-9499
24	Hunter	Gilbert	magna.malesuada@hotmail.edu	668-8169
25	Paki	Willis	cras.eu@icloud.edu	503-1249
26	Charde	Farmer	vitae.semper@aol.ca	623-7803
27	Chase	Rosa	sed@protonmail.org	735-0746
28	Elijah	Sullivan	quis.turpis.vitae@icloud.net	641-5767
29	Jordan	Mcdonald	sit.amet@google.couk	872-3172
30	Ursa	William	eu.eros@outlook.edu	775-3839
31	Brittany	James	urna.nec@icloud.net	441-1442
32	Christine	French	eleifend.egestas@protonmail.org	570-1513
33	Lev	Peterson	magna@hotmail.couk	310-0338
34	Jessamine	Nash	aenean.sed@outlook.org	272-5352
35	Olympia	Benson	vel@outlook.org	811-3808
36	Jonah	Daniel	in@aol.org	455-4624
37	Vera	Miranda	lacus@icloud.com	865-3760
38	Felix	Henson	a.enim.suspendisse@aol.ca	972-3106
39	Tarik	Slater	mauris@google.net	450-4760
40	Maxwell	Walsh	congue@outlook.org	578-4518
41	Vielka	Bowers	cursus.in@outlook.org	637-4443
42	Maite	Gallegos	iaculis.nec.eleifend@hotmail.couk	725-1214
43	Arden	Macdonald	in.lorem@icloud.edu	942-3418
44	Veronica	Conrad	condimentum.eget@outlook.org	880-7366
45	Mara	Chandler	elit@aol.org	412-4525
46	Ulla	Sheppard	semper@yahoo.couk	620-1692
47	Suki	Farley	enim.diam.vel@protonmail.com	462-8451
48	Moses	Solomon	lobortis@aol.couk	878-8714
49	Jamal	Hines	lacus.aliquam@hotmail.org	955-6707
50	Cole	Estrada	dui.nec.tempus@yahoo.edu	166-8662
51	Quemby	Munoz	dui.nec.urna@outlook.com	837-5417
52	Benedict	Mccarty	lorem.donec@outlook.edu	685-2666
53	Honorato	Ball	sagittis@google.com	295-7752
54	Remedios	Gibbs	adipiscing@yahoo.ca	808-7786
55	Orla	Gonzalez	sem.ut@outlook.edu	866-4262
56	Arden	Page	dolor.dapibus.gravida@hotmail.ca	696-2827
57	Adrian	Duffy	curabitur.sed.tortor@protonmail.ca	882-1601
58	Dieter	Harrington	molestie@hotmail.ca	240-5158
59	Candace	Wilson	egestas.fusce.aliquet@outlook.com	492-6104
60	Isabella	Cabrera	non.arcu@protonmail.net	471-5054
61	Aurora	Huff	cras.dolor@protonmail.net	154-2137
62	Brock	Good	tincidunt@hotmail.couk	626-7173
63	Alisa	Trevino	eu.lacus@google.net	763-1097
64	Travis	Baker	elit@google.ca	382-2711
65	Fitzgerald	Rice	nulla.aliquet.proin@protonmail.org	128-6615
66	Illana	Michael	euismod.mauris@google.couk	865-6324
67	Caesar	Vazquez	elit.pretium@aol.couk	273-4673
68	Dora	Burton	ut@icloud.org	531-3732
69	Jade	Holmes	convallis.dolor@outlook.edu	463-3158
70	Kelsie	Blake	ridiculus.mus@protonmail.ca	160-9300
71	Hakeem	Marquez	arcu.vestibulum.ante@aol.org	702-5995
72	Quinlan	Tanner	eu.dolor.egestas@yahoo.ca	905-8289
73	Alexandra	Pearson	arcu.vivamus.sit@protonmail.net	181-4185
74	Ferdinand	Burnett	rhoncus.proin@protonmail.couk	667-8865
75	Brynne	White	ante.bibendum@icloud.com	776-5123
76	Fallon	Head	lorem@yahoo.ca	551-3181
77	Maris	Fernandez	et.magnis.dis@outlook.couk	442-1728
78	Summer	Ortiz	sed.molestie@icloud.edu	778-7357
79	Kane	Blair	leo@outlook.couk	342-1115
80	Alvin	Griffin	aliquet.magna@protonmail.ca	430-0949
81	Heidi	Barrera	vel@yahoo.org	936-8389
82	Dominic	Mayo	tincidunt.vehicula@google.couk	893-0667
83	Timothy	Donaldson	justo.eu.arcu@aol.ca	871-8490
84	Erin	Vinson	odio@hotmail.ca	313-1923
85	Kibo	Harris	mus@yahoo.org	191-3559
86	Ina	Mccray	montes.nascetur@yahoo.edu	667-7852
87	Alisa	Woodward	tellus@google.ca	585-3553
88	Hedda	Mclaughlin	ornare.egestas@icloud.couk	344-8175
89	Brent	Clarke	purus.maecenas.libero@aol.couk	326-7915
90	Alisa	Barlow	aliquam.ultrices@yahoo.couk	288-3768
91	Ishmael	Rosa	sem.vitae@google.couk	635-2241
92	Ezra	Mcguire	sem.magna@outlook.edu	440-7744
93	Otto	Hyde	magna.cras.convallis@icloud.com	343-6347
94	Ariana	Irwin	donec@outlook.edu	312-3883
95	Gage	Alvarez	donec.sollicitudin.adipiscing@aol.ca	375-7351
96	Candice	Faulkner	id.magna@aol.com	760-6934
97	Suki	Hood	ante@outlook.couk	403-3544
98	Kirby	Simmons	et.nunc@aol.net	575-5646
99	Uriel	Bean	ipsum@yahoo.org	723-1552
100	Moses	Rowe	amet@yahoo.couk	476-5182
\.


--
-- Data for Name: video; Type: TABLE DATA; Schema: public; Owner: vk_admin
--

COPY public.video (id, url, owner_id, description, uploaded_at, size) FROM stdin;
136	http://google.com/user/110?str=se	22	eros turpis non enim. Mauris	2022-01-15 00:00:00	3242
137	http://wikipedia.org/fr?str=se	32	enim. Curabitur massa. Vestibulum accumsan neque et nunc.	2022-04-08 00:00:00	2617
138	http://guardian.co.uk/fr?k=0	79	mattis semper,	2022-11-24 00:00:00	9860
139	http://yahoo.com/en-us?g=1	59	Sed neque. Sed	2021-10-29 00:00:00	8520
140	https://walmart.com/settings?page=1&offset=1	71	urna. Ut	2023-06-08 00:00:00	4612
141	http://baidu.com/en-ca?gi=100	20	a, magna. Lorem ipsum dolor sit	2021-09-02 00:00:00	2196
142	https://guardian.co.uk/user/110?search=1	81	et, commodo at, libero. Morbi accumsan laoreet ipsum. Curabitur	2022-05-19 00:00:00	8275
143	https://zoom.us/sub?k=0	82	ut dolor dapibus gravida. Aliquam tincidunt,	2022-11-12 00:00:00	6731
144	https://reddit.com/en-us?page=1&offset=1	94	tempus mauris erat eget	2022-01-06 00:00:00	525
145	http://google.com/user/110?q=4	9	justo eu	2022-05-21 00:00:00	3037
146	https://whatsapp.com/sub?ab=441&aad=2	95	molestie arcu. Sed eu nibh vulputate	2023-07-03 00:00:00	8745
147	http://youtube.com/settings?page=1&offset=1	73	Cras sed	2023-04-22 00:00:00	1399
148	https://twitter.com/user/110?q=11	56	nec, diam. Duis mi enim, condimentum	2022-03-29 00:00:00	394
149	https://youtube.com/one?q=11	42	elit erat vitae risus. Duis a mi fringilla mi lacinia	2022-02-02 00:00:00	3411
150	https://wikipedia.org/sub?q=test	74	pellentesque a, facilisis non, bibendum	2022-05-18 00:00:00	2477
151	https://wikipedia.org/en-us?str=se	13	scelerisque neque sed sem	2021-09-24 00:00:00	4286
152	http://pinterest.com/fr?page=1&offset=1	57	nascetur ridiculus mus.	2021-10-12 00:00:00	8353
153	https://zoom.us/user/110?client=g	54	metus eu erat semper rutrum. Fusce	2022-07-08 00:00:00	5212
154	http://twitter.com/site?search=1&q=de	52	ornare sagittis felis. Donec tempor, est ac mattis	2023-05-27 00:00:00	374
155	http://pinterest.com/site?str=se	81	augue. Sed molestie. Sed id risus	2021-11-11 00:00:00	2518
156	https://yahoo.com/settings?page=1&offset=1	17	eu erat semper rutrum. Fusce dolor quam, elementum at, egestas	2023-01-15 00:00:00	9479
157	https://bbc.co.uk/sub?q=11	69	quis, tristique ac,	2021-09-21 00:00:00	342
158	http://yahoo.com/one?gi=100	57	egestas. Fusce aliquet magna a neque.	2022-11-30 00:00:00	3270
159	https://pinterest.com/sub/cars?gi=100	21	euismod enim. Etiam gravida molestie	2022-05-10 00:00:00	4621
160	https://cnn.com/en-ca?search=1	14	sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus	2023-03-23 00:00:00	6474
161	http://ebay.com/group/9?g=1	39	Duis a mi fringilla mi lacinia	2022-02-27 00:00:00	7856
162	https://twitter.com/group/9?search=1	64	adipiscing elit.	2023-04-17 00:00:00	893
163	http://facebook.com/one?q=test	95	mauris sagittis placerat. Cras dictum ultricies ligula. Nullam	2022-08-24 00:00:00	4723
164	http://facebook.com/user/110?client=g	57	ornare. Fusce mollis. Duis sit	2022-07-02 00:00:00	6459
165	https://whatsapp.com/en-ca?client=g	38	Suspendisse commodo tincidunt nibh.	2022-04-11 00:00:00	5710
166	http://twitter.com/fr?p=8	76	molestie pharetra nibh. Aliquam ornare, libero at auctor ullamcorper, nisl	2022-04-03 00:00:00	8005
167	https://google.com/sub?search=1&q=de	18	pede ac urna. Ut	2021-10-21 00:00:00	1158
168	https://google.com/settings?ab=441&aad=2	37	Curabitur dictum. Phasellus	2022-08-30 00:00:00	9090
169	https://nytimes.com/settings?p=8	74	ac	2021-11-16 00:00:00	5289
170	http://wikipedia.org/en-us?client=g	89	euismod est arcu ac orci. Ut semper pretium	2021-08-31 00:00:00	706
171	https://nytimes.com/user/110?q=test	40	Sed molestie. Sed id risus quis	2022-03-04 00:00:00	419
172	https://cnn.com/one?q=4	87	in felis. Nulla tempor augue ac ipsum. Phasellus	2023-05-26 00:00:00	8112
173	http://google.com/group/9?q=11	24	Aenean massa. Integer vitae nibh. Donec est mauris, rhoncus id,	2021-09-12 00:00:00	815
174	http://youtube.com/en-ca?ab=441&aad=2	82	leo. Morbi neque tellus, imperdiet non,	2023-02-22 00:00:00	6669
175	http://facebook.com/en-us?str=se	80	eget, venenatis a, magna. Lorem ipsum dolor sit	2022-11-04 00:00:00	2748
176	https://walmart.com/en-us?q=test	11	magna, malesuada vel,	2022-01-08 00:00:00	2709
177	http://naver.com/fr?search=1&q=de	75	Duis elementum, dui quis accumsan convallis, ante lectus	2023-06-18 00:00:00	6915
178	http://instagram.com/one?p=8	59	orci sem eget massa. Suspendisse eleifend. Cras	2021-09-11 00:00:00	7846
179	http://youtube.com/en-ca?gi=100	96	ipsum non arcu. Vivamus sit amet risus. Donec egestas. Aliquam	2021-11-27 00:00:00	5281
180	http://ebay.com/en-ca?search=1	100	purus. Duis elementum, dui quis accumsan convallis, ante	2021-08-10 00:00:00	3484
181	https://yahoo.com/settings?client=g	53	consequat purus.	2022-05-10 00:00:00	3326
182	http://guardian.co.uk/group/9?q=test	82	egestas nunc sed libero. Proin	2022-03-24 00:00:00	8449
183	https://nytimes.com/group/9?page=1&offset=1	9	adipiscing non, luctus sit amet, faucibus ut, nulla.	2023-03-24 00:00:00	7564
184	http://zoom.us/fr?search=1&q=de	94	quis massa. Mauris vestibulum, neque sed dictum	2023-05-21 00:00:00	3493
185	http://walmart.com/settings?search=1	14	et, eros.	2022-03-14 00:00:00	1008
186	https://instagram.com/en-us?search=1	8	neque. Nullam	2021-08-15 00:00:00	730
187	https://walmart.com/one?q=0	91	cursus. Integer mollis. Integer tincidunt aliquam arcu. Aliquam ultrices iaculis	2021-12-14 00:00:00	8145
188	http://baidu.com/en-us?str=se	70	quis lectus. Nullam suscipit,	2022-06-14 00:00:00	1739
189	https://facebook.com/group/9?p=8	82	bibendum. Donec felis orci,	2023-05-21 00:00:00	8720
190	https://reddit.com/group/9?q=0	67	non, hendrerit id, ante. Nunc mauris sapien,	2022-12-30 00:00:00	6733
191	http://nytimes.com/en-us?k=0	14	Integer sem elit, pharetra ut, pharetra sed,	2022-05-19 00:00:00	9028
192	http://wikipedia.org/site?search=1&q=de	36	erat neque	2022-03-15 00:00:00	4594
193	http://pinterest.com/en-us?q=11	87	molestie tortor nibh sit amet	2022-03-19 00:00:00	178
194	http://twitter.com/one?search=1&q=de	53	Aenean massa. Integer vitae	2022-04-04 00:00:00	8301
195	http://netflix.com/en-us?gi=100	82	et netus et malesuada fames	2021-09-09 00:00:00	8232
196	https://instagram.com/en-ca?ad=115	99	tempor	2022-11-11 00:00:00	5241
197	https://cnn.com/sub/cars?k=0	14	sed, facilisis vitae, orci. Phasellus dapibus quam quis diam.	2022-08-11 00:00:00	4384
198	http://cnn.com/settings?p=8	19	Vivamus rhoncus. Donec est. Nunc	2022-11-06 00:00:00	2618
199	http://ebay.com/en-us?q=test	78	Ut sagittis lobortis mauris. Suspendisse aliquet	2021-10-22 00:00:00	3001
200	https://nytimes.com/sub?p=8	89	lorem fringilla ornare placerat, orci lacus	2023-08-03 00:00:00	9673
201	https://whatsapp.com/sub/cars?k=0	75	Integer mollis. Integer tincidunt aliquam arcu.	2021-12-08 00:00:00	9339
202	http://walmart.com/site?gi=100	79	in, dolor. Fusce feugiat. Lorem ipsum dolor sit	2023-03-22 00:00:00	323
203	https://wikipedia.org/group/9?gi=100	94	morbi tristique senectus	2021-12-21 00:00:00	2660
204	http://whatsapp.com/sub/cars?g=1	11	mollis. Duis sit amet diam eu dolor egestas	2021-08-22 00:00:00	687
205	http://walmart.com/sub/cars?g=1	95	quis turpis	2021-10-14 00:00:00	3753
206	https://walmart.com/en-us?ad=115	10	eleifend non,	2021-12-25 00:00:00	8140
207	https://ebay.com/group/9?str=se	68	Duis dignissim	2022-10-01 00:00:00	3806
208	https://facebook.com/en-us?search=1	48	magnis dis	2023-07-13 00:00:00	1871
209	http://cnn.com/settings?k=0	30	ornare, lectus ante dictum	2023-02-23 00:00:00	2767
210	http://walmart.com/user/110?ab=441&aad=2	20	imperdiet dictum magna. Ut tincidunt	2022-07-05 00:00:00	3073
211	http://walmart.com/sub?k=0	44	torquent per conubia nostra, per inceptos hymenaeos. Mauris	2023-03-27 00:00:00	9038
212	https://ebay.com/sub/cars?ab=441&aad=2	88	orci. Ut sagittis lobortis mauris. Suspendisse aliquet molestie tellus.	2023-05-06 00:00:00	5869
213	http://cnn.com/user/110?gi=100	69	egestas blandit. Nam nulla	2023-03-08 00:00:00	5267
214	https://zoom.us/settings?gi=100	43	Quisque ac libero nec ligula	2021-09-16 00:00:00	5841
215	https://netflix.com/settings?str=se	37	sapien. Aenean massa. Integer vitae nibh. Donec est	2023-01-07 00:00:00	8866
216	https://bbc.co.uk/sub?ad=115	37	mi fringilla mi lacinia mattis. Integer	2021-10-01 00:00:00	6055
217	http://bbc.co.uk/en-ca?k=0	86	ligula. Nullam	2022-09-18 00:00:00	8062
218	https://bbc.co.uk/en-us?ad=115	17	ante dictum cursus. Nunc mauris elit,	2022-04-25 00:00:00	5427
219	https://instagram.com/sub?q=11	53	Nullam scelerisque neque sed sem	2023-05-24 00:00:00	4281
220	https://naver.com/one?q=4	47	tincidunt aliquam arcu. Aliquam ultrices iaculis odio. Nam	2022-07-20 00:00:00	3273
221	https://walmart.com/sub/cars?client=g	69	Phasellus vitae mauris sit amet lorem semper auctor. Mauris	2022-09-07 00:00:00	3362
222	http://ebay.com/group/9?q=11	94	sed dui. Fusce aliquam, enim nec tempus scelerisque, lorem	2022-12-05 00:00:00	2335
223	https://instagram.com/one?str=se	27	id, mollis nec, cursus a, enim. Suspendisse aliquet, sem	2023-03-11 00:00:00	5645
224	http://naver.com/sub?q=test	34	nec, cursus a, enim. Suspendisse aliquet, sem ut cursus	2021-08-25 00:00:00	9785
225	https://baidu.com/en-ca?search=1&q=de	31	pellentesque, tellus sem mollis dui, in sodales elit erat vitae	2021-08-08 00:00:00	2827
226	http://naver.com/en-ca?search=1&q=de	58	hendrerit consectetuer, cursus et, magna. Praesent interdum ligula eu enim.	2021-08-29 00:00:00	8755
227	https://wikipedia.org/sub?k=0	56	eu tellus. Phasellus elit pede, malesuada vel,	2023-01-04 00:00:00	6166
228	http://naver.com/one?p=8	40	magna. Sed	2021-10-02 00:00:00	7823
229	http://walmart.com/fr?ab=441&aad=2	41	molestie arcu. Sed eu nibh vulputate mauris sagittis	2021-08-02 00:00:00	1862
230	http://bbc.co.uk/fr?search=1	22	nisi magna sed dui. Fusce	2022-08-23 00:00:00	9134
231	https://whatsapp.com/site?q=11	39	turpis egestas. Aliquam fringilla cursus purus. Nullam scelerisque neque	2023-05-31 00:00:00	1648
232	https://twitter.com/fr?search=1&q=de	92	sed, hendrerit	2022-07-04 00:00:00	7772
233	http://zoom.us/sub/cars?q=4	51	In mi pede, nonummy ut, molestie in, tempus	2021-11-07 00:00:00	8351
234	http://facebook.com/fr?search=1&q=de	39	Nam	2022-08-29 00:00:00	4802
235	https://walmart.com/fr?q=4	77	fringilla purus mauris a nunc. In at pede. Cras	2023-01-26 00:00:00	8727
\.


--
-- Name: communities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vk_admin
--

SELECT pg_catalog.setval('public.communities_id_seq', 341, true);


--
-- Name: following_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vk_admin
--

SELECT pg_catalog.setval('public.following_id_seq', 100, true);


--
-- Name: friendship_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vk_admin
--

SELECT pg_catalog.setval('public.friendship_id_seq', 100, true);


--
-- Name: friendship_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vk_admin
--

SELECT pg_catalog.setval('public.friendship_statuses_id_seq', 5, true);


--
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vk_admin
--

SELECT pg_catalog.setval('public.messages_id_seq', 100, true);


--
-- Name: photo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vk_admin
--

SELECT pg_catalog.setval('public.photo_id_seq', 115, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vk_admin
--

SELECT pg_catalog.setval('public.users_id_seq', 100, true);


--
-- Name: video_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vk_admin
--

SELECT pg_catalog.setval('public.video_id_seq', 235, true);


--
-- Name: communities communities_name_key; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.communities
    ADD CONSTRAINT communities_name_key UNIQUE (name);


--
-- Name: communities communities_pkey; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.communities
    ADD CONSTRAINT communities_pkey PRIMARY KEY (id);


--
-- Name: communities_users communities_users_pkey; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.communities_users
    ADD CONSTRAINT communities_users_pkey PRIMARY KEY (community_id, user_id);


--
-- Name: following following_pkey; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.following
    ADD CONSTRAINT following_pkey PRIMARY KEY (id);


--
-- Name: friendship friendship_pkey; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.friendship
    ADD CONSTRAINT friendship_pkey PRIMARY KEY (id);


--
-- Name: friendship_statuses friendship_statuses_name_key; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.friendship_statuses
    ADD CONSTRAINT friendship_statuses_name_key UNIQUE (name);


--
-- Name: friendship_statuses friendship_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.friendship_statuses
    ADD CONSTRAINT friendship_statuses_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: photo photo_pkey; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_pkey PRIMARY KEY (id);


--
-- Name: photo photo_url_key; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_url_key UNIQUE (url);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: video video_pkey; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.video
    ADD CONSTRAINT video_pkey PRIMARY KEY (id);


--
-- Name: video video_url_key; Type: CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.video
    ADD CONSTRAINT video_url_key UNIQUE (url);


--
-- Name: profiles check_profiles_on_update; Type: TRIGGER; Schema: public; Owner: vk_admin
--

CREATE TRIGGER check_profiles_on_update BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_profiles_photo_trigger();


--
-- Name: communities communities_creator_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.communities
    ADD CONSTRAINT communities_creator_id_fk FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: communities_users communities_users_community_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.communities_users
    ADD CONSTRAINT communities_users_community_id_fk FOREIGN KEY (community_id) REFERENCES public.communities(id) ON DELETE CASCADE;


--
-- Name: communities_users communities_users_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.communities_users
    ADD CONSTRAINT communities_users_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: following following_follower_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.following
    ADD CONSTRAINT following_follower_id_fk FOREIGN KEY (follower_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: friendship friendship_requested_by_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.friendship
    ADD CONSTRAINT friendship_requested_by_user_id_fk FOREIGN KEY (requested_by_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: friendship friendship_requested_to_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.friendship
    ADD CONSTRAINT friendship_requested_to_user_id_fk FOREIGN KEY (requested_to_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: friendship friendship_status_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.friendship
    ADD CONSTRAINT friendship_status_id_fk FOREIGN KEY (status_id) REFERENCES public.friendship_statuses(id) ON DELETE CASCADE;


--
-- Name: messages messages_from_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_from_user_id_fk FOREIGN KEY (from_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: messages messages_to_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_to_user_id_fk FOREIGN KEY (to_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: photo photo_owner_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_owner_id_fk FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_main_photo_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_main_photo_id_fk FOREIGN KEY (main_photo_id) REFERENCES public.photo(id);


--
-- Name: profiles profiles_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: video video_owner_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: vk_admin
--

ALTER TABLE ONLY public.video
    ADD CONSTRAINT video_owner_id_fk FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: TABLE communities; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON TABLE public.communities TO analyst;
GRANT ALL ON TABLE public.communities TO tester;


--
-- Name: SEQUENCE communities_id_seq; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON SEQUENCE public.communities_id_seq TO analyst;
GRANT ALL ON SEQUENCE public.communities_id_seq TO tester;


--
-- Name: TABLE communities_users; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON TABLE public.communities_users TO analyst;
GRANT ALL ON TABLE public.communities_users TO tester;


--
-- Name: TABLE following; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON TABLE public.following TO analyst;
GRANT ALL ON TABLE public.following TO tester;


--
-- Name: SEQUENCE following_id_seq; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON SEQUENCE public.following_id_seq TO analyst;
GRANT ALL ON SEQUENCE public.following_id_seq TO tester;


--
-- Name: TABLE friendship; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON TABLE public.friendship TO analyst;
GRANT ALL ON TABLE public.friendship TO tester;


--
-- Name: SEQUENCE friendship_id_seq; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON SEQUENCE public.friendship_id_seq TO analyst;
GRANT ALL ON SEQUENCE public.friendship_id_seq TO tester;


--
-- Name: TABLE friendship_statuses; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON TABLE public.friendship_statuses TO analyst;
GRANT ALL ON TABLE public.friendship_statuses TO tester;


--
-- Name: SEQUENCE friendship_statuses_id_seq; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON SEQUENCE public.friendship_statuses_id_seq TO analyst;
GRANT ALL ON SEQUENCE public.friendship_statuses_id_seq TO tester;


--
-- Name: TABLE messages; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON TABLE public.messages TO analyst;
GRANT ALL ON TABLE public.messages TO tester;


--
-- Name: SEQUENCE messages_id_seq; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON SEQUENCE public.messages_id_seq TO analyst;
GRANT ALL ON SEQUENCE public.messages_id_seq TO tester;


--
-- Name: TABLE photo; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON TABLE public.photo TO analyst;
GRANT ALL ON TABLE public.photo TO tester;


--
-- Name: SEQUENCE photo_id_seq; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON SEQUENCE public.photo_id_seq TO analyst;
GRANT ALL ON SEQUENCE public.photo_id_seq TO tester;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON TABLE public.users TO analyst;
GRANT ALL ON TABLE public.users TO tester;


--
-- Name: SEQUENCE users_id_seq; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON SEQUENCE public.users_id_seq TO analyst;
GRANT ALL ON SEQUENCE public.users_id_seq TO tester;


--
-- Name: TABLE video; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON TABLE public.video TO analyst;
GRANT ALL ON TABLE public.video TO tester;


--
-- Name: SEQUENCE video_id_seq; Type: ACL; Schema: public; Owner: vk_admin
--

GRANT SELECT ON SEQUENCE public.video_id_seq TO analyst;
GRANT ALL ON SEQUENCE public.video_id_seq TO tester;


--
-- PostgreSQL database dump complete
--


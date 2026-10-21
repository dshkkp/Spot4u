--
-- PostgreSQL database dump
--

\restrict MNjzaiGhxELT3Mbxd0SOxMOOsZ9E7ZNfgGgdtgiqy9B5hsFLdJ3d8NnFZkDckdQ

-- Dumped from database version 13.22
-- Dumped by pg_dump version 18.2

-- Started on 2026-10-21 21:00:30

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 200 (class 1259 OID 57345)
-- Name: places; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.places (
    place_id text NOT NULL,
    name text NOT NULL,
    category text,
    address text,
    latitude double precision,
    longitude double precision,
    opening_hours text,
    rating numeric(3,2),
    review_count integer,
    avg_check_rub numeric(10,2),
    wifi boolean,
    sockets boolean,
    laptop_friendly boolean,
    student_discount boolean,
    website text,
    phone text,
    source text,
    last_updated date,
    CONSTRAINT places_avg_check_pos CHECK (((avg_check_rub IS NULL) OR (avg_check_rub >= (0)::numeric))),
    CONSTRAINT places_rating_range CHECK (((rating IS NULL) OR ((rating >= (0)::numeric) AND (rating <= (5)::numeric)))),
    CONSTRAINT places_review_count_pos CHECK (((review_count IS NULL) OR (review_count >= 0)))
);


ALTER TABLE public.places OWNER TO postgres;

--
-- TOC entry 2990 (class 0 OID 57345)
-- Dependencies: 200
-- Data for Name: places; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.places (place_id, name, category, address, latitude, longitude, opening_hours, rating, review_count, avg_check_rub, wifi, sockets, laptop_friendly, student_discount, website, phone, source, last_updated) FROM stdin;
2gis:70000001046248032	ВдвухШагах	coworking	Москва, проспект Волгоградский, 135 к3	55.706066	37.772403	Пн 09:00–22:00; Вт 09:00–22:00; Ср 09:00–22:00; Чт 09:00–22:00; Пт 09:00–22:00	3.60	2	\N	\N	t	t	\N	https://in2steps.ru	+7 (495) 543-44-59; +7 (495) 223-18-00	2GIS	2026-10-16
2gis:4504128908385599	Московский дом общественных организаций, коворкинг-центр для некоммерческих организаций и молодежи	coworking	Москва, 4-й Вешняковский проезд, 1 к1	55.718262	37.793339	Пн 10:00–21:00; Вт 10:00–21:00; Ср 10:00–21:00; Чт 10:00–21:00; Пт 10:00–21:00; Сб 10:00–21:00; Вс 10:00–17:45	5.00	6	\N	t	t	\N	\N	https://со-нко.москва	+7 (495) 657-65-42	2GIS + OSM	2026-10-16
2gis:4504127908776012	Библиотека №111, г. Москва	library	Москва, проспект Рязанский, 95 к2	55.715297	37.810445	Вт 12:00–22:00; Ср 12:00–22:00; Чт 12:00–22:00; Пт 12:00–22:00; Сб 12:00–22:00; Вс 12:00–20:00	4.60	8	\N	t	t	t	\N	https://xn--90aamkbbnf2a4b.xn--80adxpd9b2c.xn--p1ai/b111	+7 (495) 371-46-71	2GIS	2026-10-16
2gis:4504127915457067	Детская библиотека №88	library	Москва, Вешняковская улица, 24Б	55.720446	37.81752	Вт 12:00–21:00; Ср 12:00–21:00; Чт 12:00–21:00; Пт 12:00–21:00; Сб 12:00–21:00; Вс 12:00–20:00	5.00	4	\N	t	t	t	\N	https://xn------5cddl3bnj8adhigmkjgc2p.xn--p1ai/lib88	+7 (499) 373-65-51	2GIS	2026-10-16
2gis:4504127909006634	Библиотека №108	library	Москва, Привольная улица, 21	55.698043	37.84401	Вт 12:00–22:00; Ср 12:00–22:00; Чт 12:00–22:00; Пт 12:00–22:00; Сб 12:00–22:00; Вс 12:00–20:00	3.70	6	\N	t	t	t	\N	https://xn--90aamkbbnf2a4b.xn--80adxpd9b2c.xn--p1ai/b108	+7 (495) 705-73-99	2GIS	2026-10-16
2gis:4504127908455116	Библиотека №113, г. Москва	library	Москва, Саратовская улица, 1 к2	55.713888	37.731058	Вт 12:00–22:00; Ср 12:00–22:00; Чт 12:00–22:00; Пт 12:00–22:00; Сб 12:00–22:00; Вс 12:00–20:00	5.00	2	\N	t	t	t	\N	https://xn--90aamkbbnf2a4b.xn--80adxpd9b2c.xn--p1ai/b113	+7 499 1736297	2GIS + OSM	2026-10-16
2gis:70000001024796442	Библиотека №106, детское отделение	library	Москва, Шатурская улица, 49 к1	55.726933	37.773971	Вт 10:00–22:00; Ср 10:00–22:00; Чт 10:00–22:00; Пт 10:00–22:00; Сб 10:00–22:00; Вс 10:00–20:00	5.00	2	\N	t	t	t	\N	https://xn--80adxpd9b2c.xn--p1ai/	+7 (499) 171-23-52	2GIS + OSM	2026-10-16
2gis:4504127908418153	Библиотека №90 им. А. С. Неверова	library	Москва, ул. Молдагуловой, 3Б	55.723573	37.82151	Вт 12:00–20:00; Ср 12:00–20:00; Чт 12:00–20:00; Пт 12:00–20:00; Сб 12:00–20:00; Вс 12:00–20:00	5.00	4	\N	t	t	t	\N	https://xn------5cddl3bnj8adhigmkjgc2p.xn--p1ai/lib90	+7 (499) 374-95-30	2GIS + OSM + Web	2026-10-16
2gis:4504127908446554	Объединение культурных центров Юго-Восточного административного округа, библиотека №115	library	Москва, улица Фёдора Полетаева, 28	55.708624	37.78316	Вт 12:00–22:00; Ср 12:00–22:00; Чт 12:00–22:00; Пт 12:00–22:00; Сб 12:00–22:00; Вс 12:00–20:00	2.30	15	\N	t	t	t	\N	https://xn--90aamkbbnf2a4b.xn--80adxpd9b2c.xn--p1ai/b115	+7 (495) 379-83-91	2GIS	2026-10-16
2gis:70000001111168673	Центральная библиотека №106	library	Москва, 3-я Институтская улица, 15	55.722804	37.784053	Пн 08:30–17:30; Вт 08:30–17:30; Ср 08:30–17:30; Чт 08:30–17:30; Пт 08:30–16:15	\N	\N	\N	t	t	t	\N	https://xn--80adxpd9b2c.xn--p1ai/#popup:information	+7 (499) 170-61-97	2GIS	2026-10-16
2gis:4504127908806102	Центральная библиотека №106 (Зарайская)	library	Москва, Зарайская ул., 56А	55.727194	37.774271	Вт–Сб 10:00–22:00; Вс 10:00–20:00; Пн выходной	5.00	1	\N	t	t	t	\N	https://xn--90aamkbbnf2a4b.xn--80adxpd9b2c.xn--p1ai/b106-1	+7 (499) 170-61-97	2GIS + OSM + Web	2026-10-16
2gis:4504127908996900	Центральная библиотека №106 (Яснополянская)	library	Москва, Яснополянская ул., 3, корп. 2, стр. 1	55.722486	37.787542	Вт–Вс 12:00–20:00; Пн выходной	5.00	3	\N	t	t	t	\N	https://xn--90aamkbbnf2a4b.xn--80adxpd9b2c.xn--p1ai/b106-2	+7 (499) 170-98-37	2GIS + OSM + Web	2026-10-16
2gis:70000001088300885	Cofix	coffee_shop	Москва, Зеленодольская ул., вл. 42, Кузьминки Молл, 1 этаж	55.702198	37.764799	Ежедневно 10:00–22:00	4.70	24	\N	t	t	t	\N	https://cofix.global	+7 800 3508418	2GIS + OSM + Web	2026-10-16
2gis:70000001065178702	Cofix	coffee_shop	Москва, проспект Волгоградский, 82	55.704586	37.766955	Пн 07:00–22:00; Вт 07:00–22:00; Ср 07:00–22:00; Чт 07:00–22:00; Пт 07:00–22:00; Сб 08:00–22:00; Вс 08:00–22:00	4.90	51	\N	\N	\N	t	\N	https://cofix.global	8 800 350-84-18	2GIS	2026-10-16
2gis:70000001082655744	SeDelice	coffee_shop	Москва, улица Маршала Чуйкова, 3	55.704537	37.765428	Пн 07:00–22:00; Вт 07:00–22:00; Ср 07:00–22:00; Чт 07:00–22:00; Пт 07:00–22:00; Сб 08:00–22:00; Вс 09:00–22:00	4.40	18	700.00	t	f	t	\N	https://frenchbakery.ru	+7 (905) 580-99-33	2GIS	2026-10-16
2gis:70000001114790030	Дринкит	coffee_shop	Москва, улица Маршала Чуйкова, 3	55.704237	37.765042	Пн 08:00–22:00; Вт 08:00–22:00; Ср 08:00–22:00; Чт 08:00–22:00; Пт 08:00–22:00; Сб 08:00–22:00; Вс 08:00–22:00	5.00	2	400.00	t	t	t	\N	https://drinkit.ru	\N	2GIS	2026-10-16
2gis:70000001062527627	Каста Сопрано	coffee_shop	Люберцы (Люберцы городской округ, Московская обл.), Октябрьский проспект, 1 к1	55.699555	37.857674	Пн 10:00–23:00; Вт 10:00–23:00; Ср 10:00–23:00; Чт 10:00–23:00; Пт 10:00–23:00; Сб 10:00–23:00; Вс 10:00–23:00	5.00	10	300.00	t	\N	t	\N	https://castasoprano.clients.site	+7 (916) 120-33-37	2GIS	2026-10-16
2gis:4504128908413453	Шоколадница	coffee_shop	Москва, Жулебинский бульвар, 10/6	55.698297	37.85001	Mo-Th 08:00-23:00; Fr 08:00-24:00; Sa 00:00-24:00; Su 00:00-23:00	4.70	5	800.00	t	\N	t	\N	https://shoko.ru/	+7 915 4737709	2GIS + OSM	2026-10-16
2gis:70000001040979135	Chill pill coffee	coffee_shop	Москва, проспект Рязанский, 44	55.716175	37.791136	Пн 08:00–21:00; Вт 08:00–21:00; Ср 08:00–21:00; Чт 08:00–21:00; Пт 08:00–21:00; Сб 09:00–21:00; Вс 09:00–21:00	4.50	25	620.00	f	\N	t	\N	https://chill-pill-kofe.clients.site/	+7 (925) 022-50-00	2GIS	2026-10-16
2gis:70000001093476293	Кофе 20/21	coffee_shop	Москва, проспект Рязанский, 46 к3	55.717021	37.792287	Пн 08:00–20:00; Вт 08:00–20:00; Ср 08:00–20:00; Чт 08:00–20:00; Пт 08:00–20:00; Сб 08:00–20:00; Вс 08:00–20:00	5.00	2	690.00	t	\N	t	\N	kofe-bronx-rjazanskij-prospekt.clients.site	\n+7 (916) 797-65-65	2GIS	2026-10-16
2gis:70000001081043646	Солнцекофе	coffee_shop	Москва, 1-я Новокузьминская улица, 15/5	55.714954	37.789632	Пн 08:00–20:00; Вт 08:00–20:00; Ср 08:00–20:00; Чт 08:00–20:00; Пт 08:00–20:00; Сб 09:00–21:00; Вс 09:00–21:00	4.50	10	500.00	t	t	t	\N	https://solncecoffee.ru	+7 (903) 200-60-11; +7 (905) 555-71-71	2GIS	2026-10-16
2gis:70000001021124918	Шоколадница	coffee_shop	Москва, Рязанский проспект, 32/3, ТДЦ «Наска Плаза»	55.717823	37.785583	Пн–Пт 08:00–23:00; Сб–Вс 10:00–23:00	4.70	91	1000.00	t	\N	t	\N	http://shoko.ru	+7 985 3699843	2GIS + OSM + Web	2026-10-16
2gis:70000001055471997	Wiwa Coffee	coffee_shop	Москва, проспект Волгоградский, 53	55.709805	37.7328	Пн 08:00–23:00; Вт 08:00–23:00; Ср 08:00–23:00; Чт 08:00–23:00; Пт 08:00–23:00; Сб 08:00–23:00; Вс 08:00–23:00	4.40	24	350.00	t	t	t	\N	\N	+7 (925) 433-39-48	2GIS	2026-10-16
2gis:70000001110818935	Кофе лавка	coffee_shop	Москва, проспект Волгоградский, 57	55.709975	37.733636	Пн 08:00–20:30; Вт 08:00–20:30; Ср 08:00–20:30; Чт 08:00–20:30; Пт 08:00–20:30; Сб 09:00–20:30; Вс 09:00–20:30	5.00	2	\N	t	\N	t	\N	\nkofe-lavka.clients.site	+7 (926) 303-05-38	2GIS	2026-10-16
2gis:70000001109573318	не плачь, пей кофе.	coffee_shop	Москва, Волгоградский проспект, 61	55.710349	37.734722	Пн–Пт 08:00–22:00; Сб–Вс 09:00–21:00	4.90	14	700.00	t	\N	t	\N	\norder.neplach.com	=	2GIS + OSM + Web	2026-10-16
2gis:70000001103412405	Пряная тыква	coffee_shop	Москва, проспект Волгоградский, 51	55.70968	37.731939	Пн 08:30–21:00; Вт 08:30–21:00; Ср 08:30–21:00; Чт 08:30–21:00; Пт 08:30–21:00; Сб 08:30–21:00; Вс 08:30–21:00	4.50	4	300.00	\N	t	t	\N	https://kafeterij-prjanaja-tykva.clients.site/	+7 (967) 526-35-79	2GIS	2026-10-16
2gis:70000001080668131	Cofix	coffee_shop	Москва, 4-й Вешняковский проезд, 4	55.718357	37.79564	Mo-Fr 08:00-19:00; Sa 08:00-16:00	4.90	23	300.00	t	\N	t	\N	https://cofix.global	+7 800 3508418	2GIS + OSM	2026-10-16
2gis:70000001099950617	Surf Coffee	coffee_shop	Москва, улица Михайлова, 30а к1	55.7247462	37.7748317	Mo-Su 08:00-22:00	4.70	19	650.00	t	\N	t	\N	https://www.surfcoffee.ru	+7 919 9624894	2GIS + OSM	2026-10-16
2gis:70000001117230338	Дринкит	coffee_shop	Москва, Ферганская ул., 17	55.7063812	37.818776	Mo-Fr 07:30-22:00; Sa-Su 08:00-22:00	5.00	3	400.00	t	t	t	\N	https://drinkit.ru/	\N	2GIS + OSM + Web	2026-10-16
2gis:70000001087703431	Gagawa	cafe	Москва, Зеленодольская ул., 42, ТРЦ «Кузьминки Молл», 3 этаж	55.7018527	37.7650142	Mo-Su 10:00-22:00	4.60	34	500.00	t	\N	t	\N	https://gagawa.ru	+7 495 7954770;+7 903 1063249	2GIS + OSM + Web	2026-10-16
2gis:4504127908976472	Кампанелло	cafe	Москва, Зеленодольская ул., 43А	55.7026409	37.7662455	Пн 12:00–23:00; Вт 12:00–23:00; Ср 12:00–23:00; Чт 12:00–23:00; Пт 12:00–24:00; Сб 12:00–24:00; Вс 12:00–23:00	3.00	3	1500.00	t	\N	t	\N	https://campanello.ru	+7 (495) 532-05-55	2GIS + OSM + Web	2026-10-16
2gis:70000001095640478	Кулинарная лавка братьев Караваевых	cafe	Москва, Зеленодольская улица, вл42	55.700861	37.7642262	Mo-Su 10:00-22:00	4.60	32	\N	t	\N	t	\N	https://www.karavaevi.ru	+7 495 623-71-85	2GIS + OSM	2026-10-16
\.


--
-- TOC entry 2856 (class 2606 OID 57355)
-- Name: places places_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.places
    ADD CONSTRAINT places_pkey PRIMARY KEY (place_id);


--
-- TOC entry 2852 (class 1259 OID 57360)
-- Name: places_avg_check_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX places_avg_check_idx ON public.places USING btree (avg_check_rub);


--
-- TOC entry 2853 (class 1259 OID 57356)
-- Name: places_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX places_category_idx ON public.places USING btree (category);


--
-- TOC entry 2854 (class 1259 OID 57359)
-- Name: places_laptop_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX places_laptop_idx ON public.places USING btree (laptop_friendly) WHERE (laptop_friendly IS NOT NULL);


--
-- TOC entry 2857 (class 1259 OID 57361)
-- Name: places_rating_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX places_rating_idx ON public.places USING btree (rating DESC NULLS LAST);


--
-- TOC entry 2858 (class 1259 OID 57358)
-- Name: places_sockets_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX places_sockets_idx ON public.places USING btree (sockets) WHERE (sockets IS NOT NULL);


--
-- TOC entry 2859 (class 1259 OID 57357)
-- Name: places_wifi_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX places_wifi_idx ON public.places USING btree (wifi) WHERE (wifi IS NOT NULL);


--
-- TOC entry 2996 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2026-10-21 21:00:30

--
-- PostgreSQL database dump complete
--

\unrestrict MNjzaiGhxELT3Mbxd0SOxMOOsZ9E7ZNfgGgdtgiqy9B5hsFLdJ3d8NnFZkDckdQ


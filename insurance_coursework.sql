PGDMP                         z         	   insurance    14.5    14.5 p    ?           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            ?           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            ?           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            ?           1262    19469 	   insurance    DATABASE     f   CREATE DATABASE insurance WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Russian_Russia.1251';
    DROP DATABASE insurance;
                postgres    false                        3079    19810    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                   false            ?           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                        false    2                       1255    25020    delete_employee()    FUNCTION     ?   CREATE FUNCTION public.delete_employee() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM employee;
	DELETE FROM "user" WHERE employee.employee_id=="user".employee_id;
	COMMIT;
	RETURN new;
END;

$$;
 (   DROP FUNCTION public.delete_employee();
       public          postgres    false                       1255    29592    delete_policy(integer)    FUNCTION     ?   CREATE FUNCTION public.delete_policy(readble_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM "policy" WHERE "policy".policy_id=readble_id;
	RETURN;
END;

$$;
 8   DROP FUNCTION public.delete_policy(readble_id integer);
       public          postgres    false                       1255    19851    delete_policy_12_months()    FUNCTION     ?   CREATE FUNCTION public.delete_policy_12_months() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
DELETE FROM "policy" WHERE (DATE_PART('month', CURRENT_TIMESTAMP) - DATE_PART('month', policy.expire_date)) > 12;
RETURN NEW;
END;

$$;
 0   DROP FUNCTION public.delete_policy_12_months();
       public          postgres    false                       1255    29593    delete_policy_holder(integer) 	   PROCEDURE       CREATE PROCEDURE public.delete_policy_holder(IN readble_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM "policy" WHERE policy.policy_holder_id=readble_id;
	DELETE FROM policy_holder WHERE policy_holder.policy_holder_id=readble_id;
	COMMIT;
END;
$$;
 C   DROP PROCEDURE public.delete_policy_holder(IN readble_id integer);
       public          postgres    false            ?            1259    29857    policy    TABLE     x  CREATE TABLE public.policy (
    policy_id integer NOT NULL,
    issue_date timestamp without time zone NOT NULL,
    expire_date timestamp without time zone NOT NULL,
    sign_date date NOT NULL,
    purpose character varying(20) NOT NULL,
    has_trailer boolean NOT NULL,
    benefit money NOT NULL,
    is_approved boolean DEFAULT false NOT NULL,
    owner_id integer NOT NULL,
    driver_id integer NOT NULL,
    policy_holder_id integer NOT NULL,
    vin character varying(17) NOT NULL,
    policy_type_id integer NOT NULL,
    employee_id integer NOT NULL,
    CONSTRAINT policy_benefit_check CHECK ((benefit > money(0)))
);
    DROP TABLE public.policy;
       public         heap    postgres    false            ?           0    0    TABLE policy    ACL     q   GRANT SELECT,DELETE ON TABLE public.policy TO manager;
GRANT SELECT,INSERT ON TABLE public.policy TO specialist;
          public          postgres    false    227            ?           0    0    COLUMN policy.is_approved    ACL     =   GRANT UPDATE(is_approved) ON TABLE public.policy TO manager;
          public          postgres    false    227    3491                       1255    29902 T   get_policies_between_dates(timestamp without time zone, timestamp without time zone)    FUNCTION     >  CREATE FUNCTION public.get_policies_between_dates(from_date timestamp without time zone, to_date timestamp without time zone) RETURNS SETOF public.policy
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY (SELECT * FROM "policy"
			WHERE from_date <= policy.issue_date and policy.expire_date <= to_date);
			
END;
$$;
 }   DROP FUNCTION public.get_policies_between_dates(from_date timestamp without time zone, to_date timestamp without time zone);
       public          postgres    false    227                       1255    19809    hash_password()    FUNCTION       CREATE FUNCTION public.hash_password() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ -- триггер
BEGIN
    CREATE EXTENSION IF NOT EXISTS pgcrypto;
    update "user" set password = crypt(new.password, gen_salt('bf', 8)) WHERE (login = new.login);
    RETURN new;
END
$$;
 &   DROP FUNCTION public.hash_password();
       public          postgres    false                       1255    19803 `   save_statistic_to_csv(character varying, character varying, character varying, text, date, date)    FUNCTION     ?  CREATE FUNCTION public.save_statistic_to_csv(arg_surname character varying, arg_first_name character varying, arg_middle_name character varying, filepath text, start_period date, end_period date) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
all_actual_policies INTEGER; -- Общее кол-во проведённых заселений
all_appruved_chekins INTEGER;
statement TEXT;
BEGIN
	all_actual_policies = (SELECT COUNT(*) FROM policy
	WHERE expire_date <> NOW());
	statement := format('copy (SELECT %s AS all_actual_policies)
	to ''%s/tasks_statistic.csv'' with csv
	header;',
	all_actual_policies, filepath);
	EXECUTE statement;
END;
$$;
 ?   DROP FUNCTION public.save_statistic_to_csv(arg_surname character varying, arg_first_name character varying, arg_middle_name character varying, filepath text, start_period date, end_period date);
       public          postgres    false                       1255    27693 &   save_to_csv(integer, date, date, text) 	   PROCEDURE     ?  CREATE PROCEDURE public.save_to_csv(IN readble_id integer, IN start_date date, IN end_date date, IN filepath text)
    LANGUAGE plpgsql
    AS $$
DECLARE	
    all_policies_count INTEGER; 
    policies_per_employee INTEGER; 
BEGIN
    all_policies_count := (SELECT COUNT(*) FROM "policy" WHERE (issue_date >= start_date)  AND (issue_date <= end_date));

    policies_per_employee := (SELECT COUNT(*) FROM "policy" WHERE (readble_id=policy.employee_id));


    EXECUTE format('copy (SELECT %s AS all_policies_count,
                                      %s AS policies_per_employee)
                                      to ''%s/policy_statistic.csv'' with csv header;',
                        all_policies_count, policies_per_employee, filepath);
END;
$$;
 r   DROP PROCEDURE public.save_to_csv(IN readble_id integer, IN start_date date, IN end_date date, IN filepath text);
       public          postgres    false                       1255    19848    set_model_full_name()    FUNCTION     ?   CREATE FUNCTION public.set_model_full_name() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ -- триггер
    BEGIN
        NEW.model_full_name = CONCAT(NEW.brand, ' ', NEW.model);
        RETURN NEW;
    END;
$$;
 ,   DROP FUNCTION public.set_model_full_name();
       public          postgres    false            ?            1259    29784    car    TABLE     ?  CREATE TABLE public.car (
    vin character varying(17) NOT NULL,
    model_full_name character varying(100) NOT NULL,
    production_date date NOT NULL,
    production_country character varying(100) NOT NULL,
    engine_number character varying(30) NOT NULL,
    color character varying(20) NOT NULL,
    engine_power smallint NOT NULL,
    weight smallint NOT NULL,
    owner_id integer NOT NULL
);
    DROP TABLE public.car;
       public         heap    postgres    false            ?           0    0 	   TABLE car    ACL     d   GRANT SELECT ON TABLE public.car TO manager;
GRANT SELECT,INSERT ON TABLE public.car TO specialist;
          public          postgres    false    217            ?            1259    29757    policy_holder    TABLE     ?   CREATE TABLE public.policy_holder (
    policy_holder_id integer NOT NULL,
    full_name character varying(150) NOT NULL,
    passport character varying(10) NOT NULL,
    phone_number character varying(10) NOT NULL
);
 !   DROP TABLE public.policy_holder;
       public         heap    postgres    false            ?           0    0    TABLE policy_holder    ACL     x   GRANT SELECT ON TABLE public.policy_holder TO manager;
GRANT SELECT,INSERT ON TABLE public.policy_holder TO specialist;
          public          postgres    false    213            ?            1259    29897    carswithfinishingpolicies    VIEW     o  CREATE VIEW public.carswithfinishingpolicies AS
 SELECT policy_holder.full_name,
    policy_holder.phone_number,
    policy.issue_date,
    policy.expire_date
   FROM (public.policy
     JOIN public.policy_holder USING (policy_holder_id))
  WHERE ((date_part('month'::text, policy.expire_date) - date_part('month'::text, CURRENT_TIMESTAMP)) < (2)::double precision);
 ,   DROP VIEW public.carswithfinishingpolicies;
       public          postgres    false    227    213    227    227    213    213            ?            1259    29796    crv    TABLE     ?   CREATE TABLE public.crv (
    series_number_crv character varying(10) NOT NULL,
    issue_date date NOT NULL,
    issue_organization character varying(150) NOT NULL,
    vin character varying(17) NOT NULL
);
    DROP TABLE public.crv;
       public         heap    postgres    false            ?           0    0 	   TABLE crv    ACL     d   GRANT SELECT ON TABLE public.crv TO manager;
GRANT SELECT,INSERT ON TABLE public.crv TO specialist;
          public          postgres    false    218            ?            1259    29769    driver    TABLE       CREATE TABLE public.driver (
    driver_id integer NOT NULL,
    full_name character varying(150) NOT NULL,
    passport character varying(10) NOT NULL,
    phone_number character varying(10) NOT NULL,
    series_number_license character varying(10) NOT NULL
);
    DROP TABLE public.driver;
       public         heap    postgres    false            ?           0    0    TABLE driver    ACL     j   GRANT SELECT ON TABLE public.driver TO manager;
GRANT SELECT,INSERT ON TABLE public.driver TO specialist;
          public          postgres    false    216            ?            1259    29768    driver_driver_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.driver_driver_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.driver_driver_id_seq;
       public          postgres    false    216            ?           0    0    driver_driver_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.driver_driver_id_seq OWNED BY public.driver.driver_id;
          public          postgres    false    215            ?            1259    29763    driver_license    TABLE       CREATE TABLE public.driver_license (
    series_number_license character varying(10) NOT NULL,
    issue_date date NOT NULL,
    expire_date date NOT NULL,
    issue_organization character varying(150) NOT NULL,
    region character varying(50) NOT NULL
);
 "   DROP TABLE public.driver_license;
       public         heap    postgres    false            ?           0    0    TABLE driver_license    ACL     z   GRANT SELECT ON TABLE public.driver_license TO manager;
GRANT SELECT,INSERT ON TABLE public.driver_license TO specialist;
          public          postgres    false    214            ?            1259    29827    employee    TABLE       CREATE TABLE public.employee (
    employee_id integer NOT NULL,
    full_name character varying(150) NOT NULL,
    passport character varying(10) NOT NULL,
    phone_number character varying(10) NOT NULL,
    email character varying(50) NOT NULL,
    position_id integer NOT NULL
);
    DROP TABLE public.employee;
       public         heap    postgres    false            ?           0    0    TABLE employee    ACL     n   GRANT SELECT,INSERT ON TABLE public.employee TO manager;
GRANT SELECT ON TABLE public.employee TO specialist;
          public          postgres    false    224            ?            1259    29826    employee_employee_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.employee_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.employee_employee_id_seq;
       public          postgres    false    224            ?           0    0    employee_employee_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.employee_employee_id_seq OWNED BY public.employee.employee_id;
          public          postgres    false    223            ?            1259    29750    owner    TABLE     ?   CREATE TABLE public.owner (
    owner_id integer NOT NULL,
    full_name character varying(150) NOT NULL,
    passport character varying(10) NOT NULL,
    phone_number character varying(10) NOT NULL
);
    DROP TABLE public.owner;
       public         heap    postgres    false            ?           0    0    TABLE owner    ACL     h   GRANT SELECT ON TABLE public.owner TO manager;
GRANT SELECT,INSERT ON TABLE public.owner TO specialist;
          public          postgres    false    211            ?            1259    29749    owner_owner_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.owner_owner_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.owner_owner_id_seq;
       public          postgres    false    211            ?           0    0    owner_owner_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.owner_owner_id_seq OWNED BY public.owner.owner_id;
          public          postgres    false    210            ?            1259    29756 "   policy_holder_policy_holder_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.policy_holder_policy_holder_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.policy_holder_policy_holder_id_seq;
       public          postgres    false    213            ?           0    0 "   policy_holder_policy_holder_id_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE public.policy_holder_policy_holder_id_seq OWNED BY public.policy_holder.policy_holder_id;
          public          postgres    false    212            ?            1259    29856    policy_policy_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.policy_policy_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.policy_policy_id_seq;
       public          postgres    false    227            ?           0    0    policy_policy_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.policy_policy_id_seq OWNED BY public.policy.policy_id;
          public          postgres    false    226            ?            1259    29809    policy_type    TABLE     ~   CREATE TABLE public.policy_type (
    policy_type_id integer NOT NULL,
    policy_type_name character varying(20) NOT NULL
);
    DROP TABLE public.policy_type;
       public         heap    postgres    false            ?            1259    29808    policy_type_policy_type_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.policy_type_policy_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.policy_type_policy_type_id_seq;
       public          postgres    false    220            ?           0    0    policy_type_policy_type_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.policy_type_policy_type_id_seq OWNED BY public.policy_type.policy_type_id;
          public          postgres    false    219            ?            1259    29818    position    TABLE     w   CREATE TABLE public."position" (
    position_id integer NOT NULL,
    position_name character varying(50) NOT NULL
);
    DROP TABLE public."position";
       public         heap    postgres    false            ?           0    0    TABLE "position"    ACL     r   GRANT SELECT,INSERT ON TABLE public."position" TO manager;
GRANT SELECT ON TABLE public."position" TO specialist;
          public          postgres    false    222            ?            1259    29817    position_position_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.position_position_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.position_position_id_seq;
       public          postgres    false    222            ?           0    0    position_position_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.position_position_id_seq OWNED BY public."position".position_id;
          public          postgres    false    221            ?            1259    29846    user    TABLE     ?   CREATE TABLE public."user" (
    login character varying(50) NOT NULL,
    password character varying(100) NOT NULL,
    role character varying(20) NOT NULL,
    employee_id integer NOT NULL
);
    DROP TABLE public."user";
       public         heap    postgres    false            ?           2604    29772    driver driver_id    DEFAULT     t   ALTER TABLE ONLY public.driver ALTER COLUMN driver_id SET DEFAULT nextval('public.driver_driver_id_seq'::regclass);
 ?   ALTER TABLE public.driver ALTER COLUMN driver_id DROP DEFAULT;
       public          postgres    false    216    215    216            ?           2604    29830    employee employee_id    DEFAULT     |   ALTER TABLE ONLY public.employee ALTER COLUMN employee_id SET DEFAULT nextval('public.employee_employee_id_seq'::regclass);
 C   ALTER TABLE public.employee ALTER COLUMN employee_id DROP DEFAULT;
       public          postgres    false    223    224    224            ?           2604    29753    owner owner_id    DEFAULT     p   ALTER TABLE ONLY public.owner ALTER COLUMN owner_id SET DEFAULT nextval('public.owner_owner_id_seq'::regclass);
 =   ALTER TABLE public.owner ALTER COLUMN owner_id DROP DEFAULT;
       public          postgres    false    210    211    211            ?           2604    29860    policy policy_id    DEFAULT     t   ALTER TABLE ONLY public.policy ALTER COLUMN policy_id SET DEFAULT nextval('public.policy_policy_id_seq'::regclass);
 ?   ALTER TABLE public.policy ALTER COLUMN policy_id DROP DEFAULT;
       public          postgres    false    227    226    227            ?           2604    29760    policy_holder policy_holder_id    DEFAULT     ?   ALTER TABLE ONLY public.policy_holder ALTER COLUMN policy_holder_id SET DEFAULT nextval('public.policy_holder_policy_holder_id_seq'::regclass);
 M   ALTER TABLE public.policy_holder ALTER COLUMN policy_holder_id DROP DEFAULT;
       public          postgres    false    212    213    213            ?           2604    29812    policy_type policy_type_id    DEFAULT     ?   ALTER TABLE ONLY public.policy_type ALTER COLUMN policy_type_id SET DEFAULT nextval('public.policy_type_policy_type_id_seq'::regclass);
 I   ALTER TABLE public.policy_type ALTER COLUMN policy_type_id DROP DEFAULT;
       public          postgres    false    220    219    220            ?           2604    29821    position position_id    DEFAULT     ~   ALTER TABLE ONLY public."position" ALTER COLUMN position_id SET DEFAULT nextval('public.position_position_id_seq'::regclass);
 E   ALTER TABLE public."position" ALTER COLUMN position_id DROP DEFAULT;
       public          postgres    false    221    222    222            ?          0    29784    car 
   TABLE DATA           ?   COPY public.car (vin, model_full_name, production_date, production_country, engine_number, color, engine_power, weight, owner_id) FROM stdin;
    public          postgres    false    217   ?       ?          0    29796    crv 
   TABLE DATA           U   COPY public.crv (series_number_crv, issue_date, issue_organization, vin) FROM stdin;
    public          postgres    false    218   ?       ?          0    29769    driver 
   TABLE DATA           e   COPY public.driver (driver_id, full_name, passport, phone_number, series_number_license) FROM stdin;
    public          postgres    false    216   ??       ?          0    29763    driver_license 
   TABLE DATA           t   COPY public.driver_license (series_number_license, issue_date, expire_date, issue_organization, region) FROM stdin;
    public          postgres    false    214   x?       ?          0    29827    employee 
   TABLE DATA           f   COPY public.employee (employee_id, full_name, passport, phone_number, email, position_id) FROM stdin;
    public          postgres    false    224   *?       ?          0    29750    owner 
   TABLE DATA           L   COPY public.owner (owner_id, full_name, passport, phone_number) FROM stdin;
    public          postgres    false    211   F?       ?          0    29857    policy 
   TABLE DATA           ?   COPY public.policy (policy_id, issue_date, expire_date, sign_date, purpose, has_trailer, benefit, is_approved, owner_id, driver_id, policy_holder_id, vin, policy_type_id, employee_id) FROM stdin;
    public          postgres    false    227   ?       ?          0    29757    policy_holder 
   TABLE DATA           \   COPY public.policy_holder (policy_holder_id, full_name, passport, phone_number) FROM stdin;
    public          postgres    false    213   r?       ?          0    29809    policy_type 
   TABLE DATA           G   COPY public.policy_type (policy_type_id, policy_type_name) FROM stdin;
    public          postgres    false    220   ,?       ?          0    29818    position 
   TABLE DATA           @   COPY public."position" (position_id, position_name) FROM stdin;
    public          postgres    false    222   b?       ?          0    29846    user 
   TABLE DATA           D   COPY public."user" (login, password, role, employee_id) FROM stdin;
    public          postgres    false    225   ??       ?           0    0    driver_driver_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.driver_driver_id_seq', 3, true);
          public          postgres    false    215            ?           0    0    employee_employee_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.employee_employee_id_seq', 3, true);
          public          postgres    false    223            ?           0    0    owner_owner_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.owner_owner_id_seq', 3, true);
          public          postgres    false    210            ?           0    0 "   policy_holder_policy_holder_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.policy_holder_policy_holder_id_seq', 3, true);
          public          postgres    false    212            ?           0    0    policy_policy_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.policy_policy_id_seq', 4, true);
          public          postgres    false    226            ?           0    0    policy_type_policy_type_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.policy_type_policy_type_id_seq', 1, false);
          public          postgres    false    219            ?           0    0    position_position_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.position_position_id_seq', 2, true);
          public          postgres    false    221            ?           2606    29790    car car_engine_number_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_engine_number_key UNIQUE (engine_number);
 C   ALTER TABLE ONLY public.car DROP CONSTRAINT car_engine_number_key;
       public            postgres    false    217            ?           2606    29788    car car_pkey 
   CONSTRAINT     K   ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_pkey PRIMARY KEY (vin);
 6   ALTER TABLE ONLY public.car DROP CONSTRAINT car_pkey;
       public            postgres    false    217            ?           2606    29800    crv crv_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.crv
    ADD CONSTRAINT crv_pkey PRIMARY KEY (series_number_crv);
 6   ALTER TABLE ONLY public.crv DROP CONSTRAINT crv_pkey;
       public            postgres    false    218            ?           2606    29802    crv crv_vin_key 
   CONSTRAINT     I   ALTER TABLE ONLY public.crv
    ADD CONSTRAINT crv_vin_key UNIQUE (vin);
 9   ALTER TABLE ONLY public.crv DROP CONSTRAINT crv_vin_key;
       public            postgres    false    218            ?           2606    29767 "   driver_license driver_license_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY public.driver_license
    ADD CONSTRAINT driver_license_pkey PRIMARY KEY (series_number_license);
 L   ALTER TABLE ONLY public.driver_license DROP CONSTRAINT driver_license_pkey;
       public            postgres    false    214            ?           2606    29776    driver driver_passport_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.driver
    ADD CONSTRAINT driver_passport_key UNIQUE (passport);
 D   ALTER TABLE ONLY public.driver DROP CONSTRAINT driver_passport_key;
       public            postgres    false    216            ?           2606    29778    driver driver_phone_number_key 
   CONSTRAINT     a   ALTER TABLE ONLY public.driver
    ADD CONSTRAINT driver_phone_number_key UNIQUE (phone_number);
 H   ALTER TABLE ONLY public.driver DROP CONSTRAINT driver_phone_number_key;
       public            postgres    false    216            ?           2606    29774    driver driver_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.driver
    ADD CONSTRAINT driver_pkey PRIMARY KEY (driver_id);
 <   ALTER TABLE ONLY public.driver DROP CONSTRAINT driver_pkey;
       public            postgres    false    216            ?           2606    29840    employee employee_email_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_email_key UNIQUE (email);
 E   ALTER TABLE ONLY public.employee DROP CONSTRAINT employee_email_key;
       public            postgres    false    224            ?           2606    29834    employee employee_full_name_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_full_name_key UNIQUE (full_name);
 I   ALTER TABLE ONLY public.employee DROP CONSTRAINT employee_full_name_key;
       public            postgres    false    224            ?           2606    29836    employee employee_passport_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_passport_key UNIQUE (passport);
 H   ALTER TABLE ONLY public.employee DROP CONSTRAINT employee_passport_key;
       public            postgres    false    224            ?           2606    29838 "   employee employee_phone_number_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_phone_number_key UNIQUE (phone_number);
 L   ALTER TABLE ONLY public.employee DROP CONSTRAINT employee_phone_number_key;
       public            postgres    false    224            ?           2606    29832    employee employee_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);
 @   ALTER TABLE ONLY public.employee DROP CONSTRAINT employee_pkey;
       public            postgres    false    224            ?           2606    29755    owner owner_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.owner
    ADD CONSTRAINT owner_pkey PRIMARY KEY (owner_id);
 :   ALTER TABLE ONLY public.owner DROP CONSTRAINT owner_pkey;
       public            postgres    false    211            ?           2606    29762     policy_holder policy_holder_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.policy_holder
    ADD CONSTRAINT policy_holder_pkey PRIMARY KEY (policy_holder_id);
 J   ALTER TABLE ONLY public.policy_holder DROP CONSTRAINT policy_holder_pkey;
       public            postgres    false    213            ?           2606    29863    policy policy_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.policy
    ADD CONSTRAINT policy_pkey PRIMARY KEY (policy_id);
 <   ALTER TABLE ONLY public.policy DROP CONSTRAINT policy_pkey;
       public            postgres    false    227            ?           2606    29814    policy_type policy_type_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.policy_type
    ADD CONSTRAINT policy_type_pkey PRIMARY KEY (policy_type_id);
 F   ALTER TABLE ONLY public.policy_type DROP CONSTRAINT policy_type_pkey;
       public            postgres    false    220            ?           2606    29816 ,   policy_type policy_type_policy_type_name_key 
   CONSTRAINT     s   ALTER TABLE ONLY public.policy_type
    ADD CONSTRAINT policy_type_policy_type_name_key UNIQUE (policy_type_name);
 V   ALTER TABLE ONLY public.policy_type DROP CONSTRAINT policy_type_policy_type_name_key;
       public            postgres    false    220            ?           2606    29823    position position_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public."position"
    ADD CONSTRAINT position_pkey PRIMARY KEY (position_id);
 B   ALTER TABLE ONLY public."position" DROP CONSTRAINT position_pkey;
       public            postgres    false    222            ?           2606    29825 #   position position_position_name_key 
   CONSTRAINT     i   ALTER TABLE ONLY public."position"
    ADD CONSTRAINT position_position_name_key UNIQUE (position_name);
 O   ALTER TABLE ONLY public."position" DROP CONSTRAINT position_position_name_key;
       public            postgres    false    222            ?           2606    29850    user user_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (login);
 :   ALTER TABLE ONLY public."user" DROP CONSTRAINT user_pkey;
       public            postgres    false    225            ?           2620    29903    user hash_pass    TRIGGER     m   CREATE TRIGGER hash_pass AFTER INSERT ON public."user" FOR EACH ROW EXECUTE FUNCTION public.hash_password();
 )   DROP TRIGGER hash_pass ON public."user";
       public          postgres    false    279    225            ?           2620    29904    policy trigger_delete_policy    TRIGGER     ?   CREATE TRIGGER trigger_delete_policy BEFORE INSERT ON public.policy FOR EACH ROW EXECUTE FUNCTION public.delete_policy_12_months();
 5   DROP TRIGGER trigger_delete_policy ON public.policy;
       public          postgres    false    276    227            ?           2606    29791    car car_owner_id_fkey    FK CONSTRAINT     {   ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.owner(owner_id);
 ?   ALTER TABLE ONLY public.car DROP CONSTRAINT car_owner_id_fkey;
       public          postgres    false    211    217    3270            ?           2606    29803    crv crv_vin_fkey    FK CONSTRAINT     j   ALTER TABLE ONLY public.crv
    ADD CONSTRAINT crv_vin_fkey FOREIGN KEY (vin) REFERENCES public.car(vin);
 :   ALTER TABLE ONLY public.crv DROP CONSTRAINT crv_vin_fkey;
       public          postgres    false    217    218    3284            ?           2606    29779 (   driver driver_series_number_license_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY public.driver
    ADD CONSTRAINT driver_series_number_license_fkey FOREIGN KEY (series_number_license) REFERENCES public.driver_license(series_number_license);
 R   ALTER TABLE ONLY public.driver DROP CONSTRAINT driver_series_number_license_fkey;
       public          postgres    false    214    216    3274            ?           2606    29841 "   employee employee_position_id_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_position_id_fkey FOREIGN KEY (position_id) REFERENCES public."position"(position_id);
 L   ALTER TABLE ONLY public.employee DROP CONSTRAINT employee_position_id_fkey;
       public          postgres    false    222    3294    224            ?           2606    29869    policy policy_driver_id_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY public.policy
    ADD CONSTRAINT policy_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.driver(driver_id);
 F   ALTER TABLE ONLY public.policy DROP CONSTRAINT policy_driver_id_fkey;
       public          postgres    false    227    3280    216            ?           2606    29889    policy policy_employee_id_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY public.policy
    ADD CONSTRAINT policy_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);
 H   ALTER TABLE ONLY public.policy DROP CONSTRAINT policy_employee_id_fkey;
       public          postgres    false    3306    224    227            ?           2606    29864    policy policy_owner_id_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY public.policy
    ADD CONSTRAINT policy_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.owner(owner_id);
 E   ALTER TABLE ONLY public.policy DROP CONSTRAINT policy_owner_id_fkey;
       public          postgres    false    227    211    3270            ?           2606    29874 #   policy policy_policy_holder_id_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY public.policy
    ADD CONSTRAINT policy_policy_holder_id_fkey FOREIGN KEY (policy_holder_id) REFERENCES public.policy_holder(policy_holder_id);
 M   ALTER TABLE ONLY public.policy DROP CONSTRAINT policy_policy_holder_id_fkey;
       public          postgres    false    227    213    3272            ?           2606    29884 !   policy policy_policy_type_id_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY public.policy
    ADD CONSTRAINT policy_policy_type_id_fkey FOREIGN KEY (policy_type_id) REFERENCES public.policy_type(policy_type_id);
 K   ALTER TABLE ONLY public.policy DROP CONSTRAINT policy_policy_type_id_fkey;
       public          postgres    false    220    227    3290            ?           2606    29879    policy policy_vin_fkey    FK CONSTRAINT     p   ALTER TABLE ONLY public.policy
    ADD CONSTRAINT policy_vin_fkey FOREIGN KEY (vin) REFERENCES public.car(vin);
 @   ALTER TABLE ONLY public.policy DROP CONSTRAINT policy_vin_fkey;
       public          postgres    false    217    3284    227            ?           2606    29851    user user_employee_id_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);
 F   ALTER TABLE ONLY public."user" DROP CONSTRAINT user_employee_id_fkey;
       public          postgres    false    3306    224    225            ?           0    29857    policy    ROW SECURITY     4   ALTER TABLE public.policy ENABLE ROW LEVEL SECURITY;          public          postgres    false    227            ?           3256    29896 #   policy update_policy_for_specialist    POLICY     ?   CREATE POLICY update_policy_for_specialist ON public.policy FOR UPDATE TO specialist USING (true) WITH CHECK ((is_approved = false));
 ;   DROP POLICY update_policy_for_specialist ON public.policy;
       public          postgres    false    227    227            ?   ?   x?U??JQ?z?)?+3??Z?{?4"!??͂ i? ??T?6aA???0?F?ja?a??}Cɤ?0Ν???W?????_d???܁F?%?8?7?????]~??????o????)qB?#)7lR?M???"]Q?Q{??gE??_????????????X[?5b????????????xJ?"ĉ?ud\?M1j???Ų?m??D???Q???W?He/k?]/uu???(?nz      ?   ?   x?eͻ?0 ?ڞ????sZ_?tQD"3?H?"<=?x?]?XA))???G???$tv?>?xRa΂_ɴ?? ??i?i??ro47????????ġ ??Z?v??_??uPηc??~z8      ?   ?   x?U???0?s2 '??t?.??ĕ*?J??e???p??ɑ??/???'ƺń?Nq?{?u?wY?6wpIB	?)??rN???TK$????b?w;/?x4???z?d?????κ??????
?#?@,??K??ib??5?l??Y7`2x?m?>,????6?ͯ????9?dі_??????.7??      ?   ?   x?M??	?@??ni`?d??lz?????A? ??15???Ye!0???'♈jq;&f[??X??+n??C?	??)?p??X0?7"?&?HUꬨ,5?????2?qZ??>?3-޹???9??D?XrNqC?|?y??Kh-?=??p???}n????^?      ?     x?U?AN?0D??)r?*?'?q??@
UZ???X???=?B?RIi??????"????5??????ӎ>??}?j?Ӝ6????p~????????>C/imO8??X?!K?T\?DL???|?5?4g??Ua????????L?????؟????|z?D??\;?¶????u??S??PƑ?Y? 3Q????r4ͪ?qͥ???+?;??!?;?????c?W?QS?L?a$d?R?:LE*X???X_???4@??>B
?t?y?lP??      ?   ?   x?m??	?@??o?H????b1z/"Q???-,1B?&??lG???q??|o*?	??#^h
??????}?+??A?L?d?q^y?i??·RHBͭ6??gb?Kޣ??f??1?'?w???\$m*????Q???-?Ɛ????N}r7?_?X??????i
̳?T?˅?0{??      ?   Z   x?3?4202?54?5?P00?#??1?:??/???~a???[9K8---????10P?r!????????????????$????? xn?      ?   ?   x?5???0D?v? e???B1?pD $č?$HA!?a?k+9y??v<??F?a9`@????:A_?????(`ʎ?gŜ???&Vl?5ˡ?µ???6ϒ>?1??E?b_?*qMAqt?"[?^h???sʛ??\b?4JL/?_??u
?C??)J=r%??~???? |?      ?   &   x?3??0???.L?0?ˈ??, s!??????? kU      ?   $   x?3??M?KLO-?2?.HM?L??,.?????? z??      ?   ?   x?e??rC@ @?k?#?*?4?*	%!+B~:?1?E???%ѧozי????????????ʊ???<?RJ?@3y9Kv?r?-?D?c??
7xZ;ay=??jq??B·??Mċ?ew??7׎?:?P?????6Ŭ??h?xE_??(??4?ߵ*??_???d yc??_??????w????! ??5(n{???Ы?s4?z?mv;?La???vK??fԡ?k+,???X??H?	??7>?@P?oI?_j`f5     
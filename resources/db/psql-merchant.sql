CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS public.tb_payment_status
(
    id SERIAL,
    name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT tb_payment_status_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.tb_payment_status
    OWNER to backend_user;

CREATE TABLE IF NOT EXISTS public.tb_payment_model_type
(
    id SERIAL,
    name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT tb_payment_model_type_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.tb_payment_model_type
    OWNER to backend_user;

CREATE TABLE IF NOT EXISTS public.tb_transaction_status
(
    id SERIAL,
    name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT tb_transaction_status_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.tb_transaction_status
    OWNER to backend_user;

CREATE TABLE IF NOT EXISTS public.tb_transaction_type
(
    id SERIAL,
    name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT tb_transaction_type_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.tb_transaction_type
    OWNER to backend_user;

CREATE TABLE IF NOT EXISTS public.tb_payment_models
(
    id uuid NOT NULL DEFAULT uuid_generate_v1mc(),
    "merchantID" uuid NOT NULL,
    title character varying(255) COLLATE pg_catalog."default" NOT NULL,
    description character varying(255) COLLATE pg_catalog."default" NOT NULL,
    amount bigint NOT NULL,
    "initialPaymentAmount" bigint NOT NULL,
    "trialPeriod" bigint DEFAULT 0,
    currency character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "numberOfPayments" integer NOT NULL,
    frequency integer NOT NULL,
    "typeID" integer NOT NULL,
    "networkID" integer DEFAULT 0,
    "automatedCashOut" boolean DEFAULT FALSE,
    "cashOutFrequency" integer DEFAULT 1,
    CONSTRAINT tb_payment_models_pkey PRIMARY KEY (id),
    CONSTRAINT type_id_id_fkey FOREIGN KEY ("typeID")
        REFERENCES public.tb_payment_model_type (id)
        ON UPDATE CASCADE
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.tb_payment_models
    OWNER to backend_user;

CREATE TABLE IF NOT EXISTS public.tb_payments
(
    id uuid NOT NULL DEFAULT uuid_generate_v1mc(),
    "hdWalletIndex" integer NOT NULL default 0,
    "pullPaymentModelID" uuid NOT NULL,
    "numberOfPayments" integer NOT NULL,
    "nextPaymentDate" bigint NOT NULL,
    "lastPaymentDate" bigint DEFAULT 0,
    "startTimestamp" bigint NOT NULL,
    "customerAddress" character varying(255) COLLATE pg_catalog."default",
    "merchantAddress" character varying(255) COLLATE pg_catalog."default",
    "pullPaymentAddress" character varying(255) COLLATE pg_catalog."default",
    "statusID" integer DEFAULT 1,
    "userID" character varying(255) DEFAULT NULL,
    UNIQUE ("customerAddress", "pullPaymentModelID"),
    CONSTRAINT tb_payments_pkey PRIMARY KEY (id),
    CONSTRAINT payment_model_id_id_fkey FOREIGN KEY ("pullPaymentModelID")
        REFERENCES public.tb_payment_models (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT status_id_id_fkey FOREIGN KEY ("statusID")
        REFERENCES public.tb_payment_status (id)
        ON UPDATE CASCADE
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.tb_payments
    OWNER to backend_user;

CREATE TABLE IF NOT EXISTS public.tb_blockchain_transactions
(
    id uuid NOT NULL DEFAULT uuid_generate_v1mc(),
    hash character varying(255) COLLATE pg_catalog."default" UNIQUE,
    "statusID" integer DEFAULT 1,
    "typeID" integer DEFAULT 1,
    "paymentID" uuid NOT NULL,
    timestamp bigint,
    CONSTRAINT tb_blockchain_transactions_pkey PRIMARY KEY (id),
    CONSTRAINT status_id_id_fkey FOREIGN KEY ("statusID")
        REFERENCES public.tb_transaction_status (id)
        ON UPDATE CASCADE,
    CONSTRAINT type_id_id_fkey FOREIGN KEY ("typeID")
        REFERENCES public.tb_transaction_type (id)
        ON UPDATE CASCADE,
    CONSTRAINT payment_id_id_fkey FOREIGN KEY ("paymentID")
        REFERENCES public.tb_payments (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.tb_blockchain_transactions
    OWNER to backend_user;

INSERT INTO public.tb_payment_model_type("name") VALUES ('push');
INSERT INTO public.tb_payment_model_type("name") VALUES ('singlePull');
INSERT INTO public.tb_payment_model_type("name") VALUES ('recurringPull');
INSERT INTO public.tb_payment_model_type("name") VALUES ('recurringWithInitial');
INSERT INTO public.tb_payment_model_type("name") VALUES ('recurringWithTrial');
INSERT INTO public.tb_payment_model_type("name") VALUES ('recurringWithTrialAndInitial');

INSERT INTO public.tb_payment_status("name") VALUES ('initial');
INSERT INTO public.tb_payment_status("name") VALUES ('running');
INSERT INTO public.tb_payment_status("name") VALUES ('stopped');
INSERT INTO public.tb_payment_status("name") VALUES ('cancelled');
INSERT INTO public.tb_payment_status("name") VALUES ('done');

INSERT INTO public.tb_transaction_type("name") VALUES ('register');
INSERT INTO public.tb_transaction_type("name") VALUES ('initial');
INSERT INTO public.tb_transaction_type("name") VALUES ('execute');
INSERT INTO public.tb_transaction_type("name") VALUES ('cancel');

INSERT INTO public.tb_transaction_status("name") VALUES ('pending');
INSERT INTO public.tb_transaction_status("name") VALUES ('failed');
INSERT INTO public.tb_transaction_status("name") VALUES ('success');
-- FUNCTION: public.fc_create_payment_model(uuid, text, text, bigint, bigint, bigint, text, integer, integer, integer, integer, boolean, integer);

-- DROP FUNCTION public.fc_create_payment_model(uuid, text, text, bigint, bigint, bigint, text, integer, integer, integer, integer, boolean, integer);

CREATE OR REPLACE FUNCTION public.fc_create_payment_model(
    _merchantID uuid,
	_title text,
	_description text,
	_amount bigint,
	_initialPaymentAmount bigint,
    _trialPeriod bigint,
	_currency text,
	_numberOfPayments integer,
    _frequency integer,
	_typeID integer,
	_networkID integer,
    _automatedCashOut boolean default false,
    _cashOutFrequency integer default 1)
    RETURNS tb_payment_models
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE 
tb_payment_models public.tb_payment_models;
BEGIN
INSERT INTO public.tb_payment_models(
        "merchantID",
        title, 
        description, 
        amount,
        "initialPaymentAmount", 
        "trialPeriod",
        currency, 
        "numberOfPayments", 
        frequency, 
        "typeID", 
        "networkID",
        "automatedCashOut",
        "cashOutFrequency")
	VALUES (
        _merchantID,
        _title, 
        _description, 
        _amount,
        _initialPaymentAmount,
        _trialPeriod,
        _currency, 
        _numberOfPayments, 
        _frequency, 
        _typeID, 
        _networkID,
        _automatedCashOut,
        _cashOutFrequency)
    RETURNING * INTO tb_payment_models;
RETURN "tb_payment_models";
END

$BODY$;

ALTER FUNCTION public.fc_create_payment_model(uuid, text, text, bigint, bigint, bigint, text, integer, integer, integer, integer, boolean, integer)
    OWNER TO backend_user;

-- FUNCTION: public.fc_update_payment_model(uuid, text, text, bigint, bigint, bigint, text, integer, integer, integer, integer, boolean, integer);

-- DROP FUNCTION public.fc_update_payment_model(uuid, text, text, bigint, bigint, bigint, text, integer, integer, integer, integer, boolean, integer);

CREATE OR REPLACE FUNCTION public.fc_update_payment_model(
	_id uuid,
	_title text,
	_description text,
	_amount bigint,
	_initialPaymentAmount bigint,
	_trialPeriod bigint,
	_currency text,
	_numberOfPayments integer,
	_frequency integer,
    _typeID integer,
	_networkID integer,
	_automatedCashOut boolean,
	_cashOutFrequency integer)
    RETURNS tb_payment_models
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE
tb_payment_models public.tb_payment_models;
tb_temp public.tb_payment_models;
BEGIN

SELECT * FROM public.tb_payment_models WHERE id=_id INTO tb_temp;

IF _title IS NULL OR _title = ''
THEN
	_title = tb_temp.title;
END IF;
IF _description IS NULL OR _description = ''
THEN
	_description = tb_temp.description;
END IF;
IF _amount IS NULL
THEN
	_amount = tb_temp.amount;
END IF;
IF _initialPaymentAmount IS NULL
THEN
	_initialPaymentAmount = tb_temp."initialPaymentAmount";
END IF;
IF _trialPeriod IS NULL
THEN
	_trialPeriod = tb_temp."trialPeriod";
END IF;
IF _currency IS NULL OR _currency = ''
THEN
	_currency = tb_temp.currency;
END IF;
IF _numberOfPayments IS NULL
THEN
	_numberOfPayments = tb_temp."numberOfPayments";
END IF;
IF _frequency IS NULL
THEN
	_frequency = tb_temp.frequency;
END IF;
IF _typeID IS NULL
THEN
	_typeID = tb_temp."typeID";
END IF;
IF _networkID IS NULL
THEN
	_networkID = tb_temp."networkID";
END IF;
IF _automatedCashOut IS NULL
THEN
	_automatedCashOut = tb_temp."automatedCashOut";
END IF;
IF _cashOutFrequency IS NULL
THEN
	_cashOutFrequency = tb_temp."cashOutFrequency";
END IF;

UPDATE public.tb_payment_models SET
	title = _title, 
    description = _description, 
    amount = _amount,
	"initialPaymentAmount" = _initialPaymentAmount, 
	"trialPeriod" = _trialPeriod, 
    currency = _currency, 
	"numberOfPayments" = _numberOfPayments, 
	frequency = _frequency, 
	"typeID" = _typeID,
    "networkID" = _networkID,
	"automatedCashOut" = _automatedCashOut,
	"cashOutFrequency" = _cashOutFrequency
    WHERE id = _id RETURNING * INTO tb_payment_models;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'SQL Query failed. Reason: payment_with_provided_id_not_found.';
    END IF;

	RETURN tb_payment_models;
END

$BODY$;

ALTER FUNCTION public.fc_update_payment_model(uuid, text, text, bigint, bigint, bigint, text, integer, integer, integer, integer, boolean, integer)
    OWNER TO backend_user;

-- FUNCTION: public.fc_delete_payment_model(uuid)

-- DROP FUNCTION public.fc_delete_payment_model(uuid);

CREATE OR REPLACE FUNCTION public.fc_delete_payment_model(
	_id uuid)
    RETURNS BOOLEAN
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$


BEGIN
  DELETE FROM public.tb_payment_models WHERE id = _id;
  RETURN FOUND;
END;

$BODY$;

ALTER FUNCTION public.fc_delete_payment_model(uuid)
    OWNER TO backend_user;

-- FUNCTION: public.fc_get_payment_model_by_id(uuid)

-- DROP FUNCTION public.fc_get_payment_model_by_id(uuid);

CREATE OR REPLACE FUNCTION public.fc_get_payment_model_by_id(
	_id uuid)
    RETURNS tb_payment_models
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE
	tb_payment_models public.tb_payment_models;
BEGIN
	SELECT * FROM public.tb_payment_models WHERE id = _id INTO tb_payment_models;

    RETURN tb_payment_models;
END

$BODY$;

ALTER FUNCTION public.fc_get_payment_model_by_id(uuid)
    OWNER TO backend_user;

-- FUNCTION: public.fc_get_all_payment_models()

-- DROP FUNCTION public.fc_get_all_payment_models();

CREATE OR REPLACE FUNCTION public.fc_get_all_payment_models()
    RETURNS SETOF tb_payment_models
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

DECLARE 
	tb_payment_models public.tb_payment_models;
BEGIN
	RETURN QUERY
	SELECT * FROM public.tb_payment_models;

END

$BODY$;

ALTER FUNCTION public.fc_get_all_payment_models()
    OWNER TO backend_user;
-- FUNCTION: public.fc_create_payment(integer, uuid, integer, bigint, bigint, text, text, text, text);

-- DROP FUNCTION public.fc_create_payment(integer, uuid, integer, bigint, bigint, text, text, text, text);

CREATE OR REPLACE FUNCTION public.fc_create_payment(
	_hdWalletIndex integer,
	_pullPaymentModelID uuid,
    _numberOfPayments integer,
	_nextPaymentDate bigint,
	_startTimestamp bigint,
	_customerAddress text,
    _merchantAddress text,
    _pullPaymentAddress text,
	_userID text)
    RETURNS tb_payments
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE 
tb_payments public.tb_payments;
BEGIN
INSERT INTO public.tb_payments(
        "hdWalletIndex", 
        "pullPaymentModelID",
        "numberOfPayments",
        "nextPaymentDate", 
        "startTimestamp", 
        "customerAddress", 
        "merchantAddress", 
        "pullPaymentAddress",
        "userID")
	VALUES (
        _hdWalletIndex, 
        _pullPaymentModelID,
        _numberOfPayments,
        _nextPaymentDate, 
        _startTimestamp, 
        _customerAddress, 
        _merchantAddress, 
        _pullPaymentAddress, 
        _userID) 
    RETURNING * INTO tb_payments;
RETURN tb_payments;
END

$BODY$;

ALTER FUNCTION public.fc_create_payment(integer, uuid, integer, bigint, bigint, text, text, text, text)
    OWNER TO backend_user;

-- FUNCTION: public.fc_update_payment(uuid, integer, integer, bigint, bigint, bigint, text, integer, text);

-- DROP FUNCTION public.fc_update_payment(uuid, integer, integer, bigint, bigint, bigint, text, integer, text);

CREATE OR REPLACE FUNCTION public.fc_update_payment(
	_id uuid,
	_hdWalletIndex integer,
    _numberOfPayments integer,
	_nextPaymentDate bigint,
	_lastPaymentDate bigint,
	_startTimestamp bigint,
	_merchantAddress text,
	_statusID integer,
	_userID text)
    RETURNS tb_payments
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE
tb_payments public.tb_payments;
tb_temp public.tb_payments;
BEGIN

SELECT * FROM public.tb_payments WHERE id=_id INTO tb_temp;

IF _hdWalletIndex IS NULL
THEN
	_hdWalletIndex = tb_temp."hdWalletIndex";
END IF;
IF _numberOfPayments IS NULL
THEN
	_numberOfPayments = tb_temp."numberOfPayments";
END IF;
IF _nextPaymentDate IS NULL
THEN
	_nextPaymentDate = tb_temp."nextPaymentDate";
END IF;
IF _lastPaymentDate IS NULL
THEN
	_lastPaymentDate = tb_temp."lastPaymentDate";
END IF;
IF _startTimestamp IS NULL
THEN
	_startTimestamp = tb_temp."startTimestamp";
END IF;
IF _merchantAddress IS NULL OR _merchantAddress = ''
THEN
	_merchantAddress = tb_temp."merchantAddress";
END IF;
IF _statusID IS NULL
THEN
	_statusID = tb_temp."statusID";
END IF;
IF _userID IS NULL OR _userID = ''
THEN
	_userID = tb_temp."userID";
END IF;

UPDATE public.tb_payments SET
	"hdWalletIndex" = _hdWalletIndex, 
    "numberOfPayments" = _numberOfPayments, 
    "nextPaymentDate" = _nextPaymentDate, 
    "lastPaymentDate" = _lastPaymentDate, 
	"startTimestamp" = _startTimestamp, 
	"merchantAddress" = _merchantAddress, 
    "statusID" = _statusID,
	"userID" = _userID
    WHERE id = _id RETURNING * INTO tb_payments;

	IF NOT FOUND THEN
      RAISE EXCEPTION 'SQL Query failed. Reason: contract_with_provided_id_not_found.';
    END IF;

	RETURN tb_payments;
END

$BODY$;

ALTER FUNCTION public.fc_update_payment(uuid, integer, integer, bigint, bigint, bigint, text, integer, text)
    OWNER TO backend_user;

-- FUNCTION: public.fn_get_payment_count_by_customer_and_payment_model_id(uuid)

-- DROP FUNCTION public.fc_delete_payment(uuid);

CREATE OR REPLACE FUNCTION public.fc_delete_payment(
	_id uuid)
    RETURNS BOOLEAN
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$


BEGIN
  DELETE FROM public.tb_payments WHERE id = _id;
  RETURN FOUND;
END;

$BODY$;

ALTER FUNCTION public.fc_delete_payment(uuid)
    OWNER TO backend_user;

-- FUNCTION: public.fc_get_enums(uuid)

-- DROP FUNCTION public.fc_get_enums(uuid);

CREATE OR REPLACE FUNCTION public.fc_get_enums(
	_table text)
    RETURNS TABLE (
        id integer,
        name character varying (255)
    )
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

BEGIN

    IF _table = 'tb_payment_status' THEN
        RETURN QUERY
        SELECT * FROM public.tb_payment_status;
    ELSIF _table = 'tb_payment_model_type' THEN
        RETURN QUERY
        SELECT * FROM public.tb_payment_model_type;
    ELSIF _table = 'tb_transaction_status' THEN
        RETURN QUERY
        SELECT * FROM public.tb_transaction_status;
    ELSIF _table = 'tb_transaction_type' THEN
        RETURN QUERY
        SELECT * FROM public.tb_transaction_type;
    END IF;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'SQL Query failed. Reason: invalid_table_name.';
    END IF;

END

$BODY$;

ALTER FUNCTION public.fc_get_enums(text)
    OWNER TO backend_user;

-- FUNCTION: public.fc_get_payment_by_id(uuid)

-- DROP FUNCTION public.fc_get_payment_by_id(uuid);

CREATE OR REPLACE FUNCTION public.fc_get_payment_by_id(_id uuid)
    RETURNS TABLE (
        id uuid,
        title character varying (255),
        "merchantID" uuid,
        description character varying (255),
        amount bigint,
        "initialPaymentAmount" bigint,
        "initialNumberOfPayments" integer,
        "trialPeriod" bigint,
        currency character varying (255),
        "hdWalletIndex" integer,
        "numberOfPayments" integer,
        frequency integer,
        type character varying (255),
        status character varying (255),
        "networkID" integer,
        "nextPaymentDate" bigint,
        "lastPaymentDate" bigint,
        "startTimestamp" bigint,
        "customerAddress" character varying (255),
        "merchantAddress" character varying (255),
        "pullPaymentAddress" character varying (255),
        "automatedCashOut" boolean,
        "cashOutFrequency" integer,
        "userID" character varying (255)
    )
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

BEGIN

    RETURN 
    QUERY (SELECT 
        public.tb_payments.id as id,
        public.tb_payment_models.title as title,
        public.tb_payment_models."merchantID" as merchantID,
        public.tb_payment_models.description as description,
        public.tb_payment_models.amount as amount,
        public.tb_payment_models."initialPaymentAmount" as initialPaymentAmount,
        public.tb_payment_models."numberOfPayments" as initialNumberOfPayments,
        public.tb_payment_models."trialPeriod" as trialPeriod,
        public.tb_payment_models.currency as currency,
        public.tb_payments."hdWalletIndex" as hdWalletIndex,
        public.tb_payments."numberOfPayments" as numberOfPayments,
        public.tb_payment_models.frequency as frequency,
        public.tb_payment_model_type.name as type,
        public.tb_payment_status.name as status,
        public.tb_payment_models."networkID" as networkID,
        public.tb_payments."nextPaymentDate" as nextPaymentDate,
        public.tb_payments."lastPaymentDate" as lastPaymentDate,
        public.tb_payments."startTimestamp" as startTimestamp,
        public.tb_payments."customerAddress" as customerAddress,
        public.tb_payments."merchantAddress" as merchantAddress,
        public.tb_payments."pullPaymentAddress" as pullPaymentAddress,
        public.tb_payment_models."automatedCashOut" as automatedCashOut,
        public.tb_payment_models."cashOutFrequency" as cashOutFrequency,
        public.tb_payments."userID" as userID
    FROM (public.tb_payments
    JOIN public.tb_payment_models ON public.tb_payments."pullPaymentModelID" = public.tb_payment_models.id
    JOIN public.tb_payment_model_type ON public.tb_payment_models."typeID" = public.tb_payment_model_type.id
    JOIN public.tb_payment_status ON public.tb_payments."statusID" = public.tb_payment_status.id)
    WHERE public.tb_payments.id = _id
    LIMIT 1);

--    IF NOT FOUND THEN
--      RAISE EXCEPTION 'SQL Query failed. Reason: contract_with_provided_id_not_found.';
--    END IF;
END

$BODY$;

ALTER FUNCTION public.fc_get_payment_by_id(uuid)
    OWNER TO backend_user;

-- -- FUNCTION: public.fc_get_payment_contract(uuid)

-- -- DROP FUNCTION public.fc_get_payment_contract(uuid);
-- FUNCTION: public.fc_get_payment_by_ids()

-- DROP FUNCTION public.fc_get_payment_by_ids();

CREATE OR REPLACE FUNCTION public.fc_get_payment_by_ids()
    RETURNS TABLE (
        id uuid,
        title character varying (255),
        "merchantID" uuid,
        description character varying (255),
        amount bigint,
        "initialPaymentAmount" bigint,
        "initialNumberOfPayments" integer,
        "trialPeriod" bigint,
        currency character varying (255),
        "hdWalletIndex" integer,
        "numberOfPayments" integer,
        frequency integer,
        type character varying (255),
        status character varying (255),
        "networkID" integer,
        "nextPaymentDate" bigint,
        "lastPaymentDate" bigint,
        "startTimestamp" bigint,
        "customerAddress" character varying (255),
        "merchantAddress" character varying (255),
        "pullPaymentAddress" character varying (255),
        "automatedCashOut" boolean,
        "cashOutFrequency" integer,
        "userID" character varying (255)
    )
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

BEGIN

    RETURN 
    QUERY (SELECT 
        public.tb_payments.id as id,
        public.tb_payment_models.title as title,
        public.tb_payment_models."merchantID" as merchantID,
        public.tb_payment_models.description as description,
        public.tb_payment_models.amount as amount,
        public.tb_payment_models."initialPaymentAmount" as initialPaymentAmount,
        public.tb_payment_models."numberOfPayments" as initialNumberOfPayments,
        public.tb_payment_models."trialPeriod" as trialPeriod,
        public.tb_payment_models.currency as currency,
        public.tb_payments."hdWalletIndex" as hdWalletIndex,
        public.tb_payments."numberOfPayments" as numberOfPayments,
        public.tb_payment_models.frequency as frequency,
        public.tb_payment_model_type.name as type,
        public.tb_payment_status.name as status,
        public.tb_payment_models."networkID" as networkID,
        public.tb_payments."nextPaymentDate" as nextPaymentDate,
        public.tb_payments."lastPaymentDate" as lastPaymentDate,
        public.tb_payments."startTimestamp" as startTimestamp,
        public.tb_payments."customerAddress" as customerAddress,
        public.tb_payments."merchantAddress" as merchantAddress,
        public.tb_payments."pullPaymentAddress" as pullPaymentAddress,
        public.tb_payment_models."automatedCashOut" as automatedCashOut,
        public.tb_payment_models."cashOutFrequency" as cashOutFrequency,
        public.tb_payments."userID" as userID
    FROM (public.tb_payments
    JOIN public.tb_payment_models ON public.tb_payments."pullPaymentModelID" = public.tb_payment_models.id
    JOIN public.tb_payment_model_type ON public.tb_payment_models."typeID" = public.tb_payment_model_type.id
    JOIN public.tb_payment_status ON public.tb_payments."statusID" = public.tb_payment_status.id));

END

$BODY$;

ALTER FUNCTION public.fc_get_payment_by_ids()
    OWNER TO backend_user;

-- -- FUNCTION: public.fc_get_payment_contracts()

-- -- DROP FUNCTION public.fc_get_payment_contracts();



-- ALTER FUNCTION public.fc_get_payment_contracts()
--     OWNER TO backend_user;

-- FUNCTION: public.fn_get_payment_count_by_customer_and_payment_model_id(text, uuid)

-- DROP FUNCTION public.fn_get_payment_count_by_customer_and_payment_model_id(text, uuid);

CREATE OR REPLACE FUNCTION public.fn_get_payment_count_by_customer_and_payment_model_id(
    _customerAddress text,
	_pullPaymentModelID uuid)
    RETURNS int
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE _count int;

BEGIN
    SELECT COUNT(*)::int
    FROM public.tb_payments
    WHERE public.tb_payments."pullPaymentModelID" = _pullPaymentModelID
    AND public.tb_payments."customerAddress" = _customerAddress
    INTO _count;

    RETURN _count;
END

$BODY$;

ALTER FUNCTION public.fn_get_payment_count_by_customer_and_payment_model_id(text, uuid)
    OWNER TO backend_user;


-- FUNCTION: public.fn_get_payment_by_customer_and_payment_model_id(text, uuid)

-- DROP FUNCTION public.fn_get_payment_by_customer_and_payment_model_id(text, uuid);

CREATE OR REPLACE FUNCTION public.fn_get_payment_by_customer_and_payment_model_id(
    _customerAddress text,
	_pullPaymentModelID uuid)
    RETURNS tb_payments
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE tb_payments public.tb_payments;

BEGIN
    SELECT *
    FROM public.tb_payments
    WHERE public.tb_payments."customerAddress" = _customerAddress
    AND public.tb_payments."pullPaymentModelID" = _pullPaymentModelID
    INTO tb_payments;

    RETURN tb_payments;
END

$BODY$;

ALTER FUNCTION public.fn_get_payment_by_customer_and_payment_model_id(text, uuid)
    OWNER TO backend_user;


-- FUNCTION: public.fc_create_transaction(text, integer, uuid, bigint);

-- DROP FUNCTION public.fc_create_transaction(text, integer, uuid, bigint);

CREATE OR REPLACE FUNCTION public.fc_create_transaction(
	_hash text,
    _typeID integer,
    _paymentID uuid,
	_timestamp bigint)
    RETURNS tb_blockchain_transactions
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE 
tb_blockchain_transactions public.tb_blockchain_transactions;
BEGIN
INSERT INTO public.tb_blockchain_transactions(
        hash, 
        "typeID",
        "paymentID",
        timestamp)
	VALUES (
        _hash, 
        _typeID,
        _paymentID,
        _timestamp) 
    RETURNING * INTO tb_blockchain_transactions;
RETURN tb_blockchain_transactions;
END

$BODY$;

ALTER FUNCTION public.fc_create_transaction(text, integer, uuid, bigint)
    OWNER TO backend_user;

-- FUNCTION: public.fc_update_transaction(text, integer);

-- DROP FUNCTION public.fc_update_transaction(text, integer);

CREATE OR REPLACE FUNCTION public.fc_update_transaction(
	_hash text,
	_statusID integer)
    RETURNS tb_blockchain_transactions
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE
tb_blockchain_transactions public.tb_blockchain_transactions;
BEGIN

	UPDATE public.tb_blockchain_transactions SET "statusID" = _statusID
    WHERE hash = _hash RETURNING * INTO tb_blockchain_transactions;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'SQL Query failed. Reason: transaction_with_provided_hash_not_found.';
    END IF;

	RETURN tb_blockchain_transactions;

	
END

$BODY$;

ALTER FUNCTION public.fc_update_transaction(text, integer)
    OWNER TO backend_user;

-- FUNCTION: public.fc_delete_transaction(text)

-- DROP FUNCTION public.fc_delete_transaction(text);

CREATE OR REPLACE FUNCTION public.fc_delete_transaction(
	_hash text)
    RETURNS BOOLEAN
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$


BEGIN
  DELETE FROM public.tb_blockchain_transactions WHERE hash = _hash;
  RETURN FOUND;
END;

$BODY$;

ALTER FUNCTION public.fc_delete_transaction(text)
    OWNER TO backend_user;

-- FUNCTION: public.fc_get_transaction(text)

-- DROP FUNCTION public.fc_get_transaction(text);

CREATE OR REPLACE FUNCTION public.fc_get_transaction(
	_hash text)
    RETURNS TABLE (
        id uuid,
        hash character varying (255),
        status character varying (255),
        type character varying (255),
        "paymentID" uuid,
        "timestamp" bigint
    )
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

BEGIN

    RETURN 
    QUERY (SELECT 
        public.tb_blockchain_transactions.id as id,
        public.tb_blockchain_transactions.hash as hash,
        public.tb_transaction_status.name as status,
        public.tb_transaction_type.name as type,
        public.tb_blockchain_transactions."paymentID" as "paymentID",
        public.tb_blockchain_transactions."timestamp" as "timestamp"
    FROM (public.tb_blockchain_transactions 
    JOIN public.tb_transaction_status ON public.tb_blockchain_transactions."statusID" = public.tb_transaction_status.id
    JOIN public.tb_transaction_type ON public.tb_blockchain_transactions."typeID" = public.tb_transaction_type.id)
    WHERE public.tb_blockchain_transactions.hash = _hash
    LIMIT 1);

    IF NOT FOUND THEN
      RAISE EXCEPTION 'SQL Query failed. Reason: transaction_with_provided_hash_not_found.';
    END IF;
END

$BODY$;

ALTER FUNCTION public.fc_get_transaction(text)
    OWNER TO backend_user;

-- FUNCTION: public.fc_get_transactions_by_payment_id(uuid, integer, integer)

-- DROP FUNCTION public.fc_get_transactions_by_payment_id(uuid, integer, integer);

CREATE OR REPLACE FUNCTION public.fc_get_transactions_by_payment_id(
	_paymentID uuid,
    _statusID integer,
    _typeID integer)
    RETURNS TABLE (
        id uuid,
        hash character varying (255),
        status character varying (255),
        type character varying (255),
        "paymentID" uuid,
        "timestamp" bigint
    )
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

BEGIN

IF _statusID IS NULL
THEN
	_statusID = 0;
END IF;
IF _typeID IS NULL
THEN
	_typeID = 0;
END IF;

    RETURN 
    QUERY (SELECT 
        public.tb_blockchain_transactions.id as id,
        public.tb_blockchain_transactions.hash as hash,
        public.tb_transaction_status.name as status,
        public.tb_transaction_type.name as type,
        public.tb_blockchain_transactions."paymentID" as "paymentID",
        public.tb_blockchain_transactions."timestamp" as "timestamp"
    FROM (public.tb_blockchain_transactions 
    JOIN public.tb_transaction_status ON public.tb_blockchain_transactions."statusID" = public.tb_transaction_status.id
    JOIN public.tb_transaction_type ON public.tb_blockchain_transactions."typeID" = public.tb_transaction_type.id)
    WHERE public.tb_blockchain_transactions."paymentID" = _paymentID
    AND ( CASE WHEN _statusID > 0 THEN public.tb_blockchain_transactions."statusID" ELSE _statusID END) = _statusID
    AND ( CASE WHEN _typeID > 0 THEN public.tb_blockchain_transactions."typeID" ELSE _typeID END) = _typeID);

    IF NOT FOUND THEN
      RAISE EXCEPTION 'SQL Query failed. Reason: transaction_with_provided_parameters_not_found.';
    END IF;
END

$BODY$;

ALTER FUNCTION public.fc_get_transactions_by_payment_id(uuid, integer, integer)
    OWNER TO backend_user;

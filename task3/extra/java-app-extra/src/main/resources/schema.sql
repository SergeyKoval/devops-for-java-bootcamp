CREATE TABLE public.accounts
(
    id   integer NOT NULL,
    name character varying
);

ALTER TABLE public.accounts
    OWNER TO postgres;

INSERT INTO public.accounts (id, name)
    VALUES (1, 'account1');

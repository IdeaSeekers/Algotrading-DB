CREATE TABLE IF NOT EXISTS Strategies (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    description TEXT
);

CREATE TABLE IF NOT EXISTS DoubleHyperparameters (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    default_value DOUBLE PRECISION,
    description TEXT
);

CREATE TABLE IF NOT EXISTS IntHyperparameters (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    default_value INT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS IntHyperparametersOfStrategies (
    rel_id SERIAL PRIMARY KEY,
    strategy_id INT REFERENCES Strategies (id),
    parameter_id INT REFERENCES IntHyperparameters (id)
);

CREATE TABLE IF NOT EXISTS DoubleHyperparametersOfStrategies (
    rel_id SERIAL PRIMARY KEY,
    strategy_id INT REFERENCES Strategies (id),
    parameter_id INT REFERENCES DoubleHyperparameters (id)
);

CREATE TABLE IF NOT EXISTS Bots (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    description TEXT,
    strategy_id INT REFERENCES Strategies (id)
);

CREATE TABLE IF NOT EXISTS IntBotHyperparameters  (
    rel_id SERIAL PRIMARY KEY,
    value INT,
    bot_id INT REFERENCES Bots(id),
    parameter_id INT REFERENCES IntHyperparametersOfStrategies (rel_id)
);

CREATE TABLE IF NOT EXISTS DoubleBotHyperparameters  (
    rel_id SERIAL PRIMARY KEY,
    value DOUBLE PRECISION,
    bot_id INT REFERENCES Bots(id),
    parameter_id INT REFERENCES DoubleHyperparametersOfStrategies (rel_id)  
);


------------------------------------------------------------------------------------------------------------------------------------------
--
--                                                        CREATIONS
--
------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION create_strategy(strategy_name VARCHAR, strategy_description TEXT)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO Strategies(name, description) VALUES (strategy_name, strategy_description);
END;
$$;

CREATE FUNCTION create_bot(bot_name VARCHAR, bot_desctiption TEXT, strategy_id INT)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO Bots(name, description, strategy_id) VALUES (bot_name, bot_desctiption, strategy_id);
END;
$$;

CREATE FUNCTION create_int_parameter(param_name VARCHAR, param_description TEXT, default_param_value INT)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO IntHyperparameters(name, description, default_value) VALUES (param_name, param_description, default_param_value);
END;
$$;

CREATE FUNCTION create_double_parameter(param_name VARCHAR, param_description TEXT, default_param_value DOUBLE PRECISION)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO DoubleHyperparameters(name, description, default_value) VALUES (param_name, param_description, default_param_value);
END;
$$;


------------------------------------------------------------------------------------------------------------------------------------------
--
--                                                        PARAMETERS ADD
--
------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION add_int_parameter(param_id INT, strat_id INT)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO IntHyperparametersOfStrategies(parameter_id, strategy_id) VALUES (param_id, strat_id);
END;
$$;

CREATE FUNCTION add_double_parameter(param_id INT, strat_id INT)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO DoubleHyperparametersOfStrategies(parameter_id, strategy_id) VALUES (param_id, strat_id);
END;
$$;

------------------------------------------------------------------------------------------------------------------------------------------
--
--                                                        PARAMETERS SET
--
------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION set_double_parameter(param_id INT, cur_bot_id INT, new_value DOUBLE PRECISION)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO DoubleBotHyperparameters (value, bot_id, parameter_id) 
    VALUES (new_value, cur_bot_id, param_id)
    ON CONFLICT (bot_id, parameter_id) DO UPDATE
    SET value = new_value;
END;
$$;

CREATE FUNCTION set_int_parameter(param_id INT, cur_bot_id INT, new_value INT)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO IntBotHyperparameters (value, bot_id, parameter_id) 
    VALUES (new_value, cur_bot_id, param_id)
    ON CONFLICT (bot_id, parameter_id) DO UPDATE
    SET value = new_value;
END;
$$;

------------------------------------------------------------------------------------------------------------------------------------------
--
--                                                        PARAMETERS GET
--
------------------------------------------------------------------------------------------------------------------------------------------
-- TODO DEFAULTS
CREATE FUNCTION get_int_parameter(param_id INT, cur_bot_id INT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    val INT;
BEGIN
   IF EXISTS ( SELECT value INTO val FROM DoubleBotHyperparameters WHERE parameter_id = param_id AND bot_id = cur_bot_id ) THEN
        RETURN val;
   END IF;

   RETURN 0;
END;
$$;

CREATE FUNCTION get_double_parameter(param_id INT, cur_bot_id INT)
RETURNS DOUBLE PRECISION
LANGUAGE plpgsql
AS
$$
DECLARE
    val INT;
BEGIN
    
   IF EXISTS ( SELECT value INTO val FROM DoubleBotHyperparameters WHERE parameter_id = param_id AND bot_id = cur_bot_id ) THEN
        RETURN val;
   END IF;

   RETURN 0;
END;
$$;

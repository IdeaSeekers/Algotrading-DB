DROP DATABASE IF EXISTS Algotrading;
CREATE DATABASE Algotrading;

\c algotrading

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

CREATE TABLE IF NOT EXISTS StringHyperparameters (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    default_value Text,
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

CREATE TABLE IF NOT EXISTS StringHyperparametersOfStrategies (
    rel_id SERIAL PRIMARY KEY,
    strategy_id INT REFERENCES Strategies (id),
    parameter_id INT REFERENCES StringHyperparameters (id)
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
    parameter_id INT REFERENCES IntHyperparametersOfStrategies (rel_id),
    UNIQUE (bot_id, parameter_id)
);

CREATE TABLE IF NOT EXISTS DoubleBotHyperparameters  (
    rel_id SERIAL PRIMARY KEY,
    value DOUBLE PRECISION,
    bot_id INT REFERENCES Bots(id),
    parameter_id INT REFERENCES DoubleHyperparametersOfStrategies (rel_id),
    UNIQUE (bot_id, parameter_id)
);

CREATE TABLE IF NOT EXISTS StringBotHyperparameters  (
    rel_id SERIAL PRIMARY KEY,
    value INT,
    bot_id INT REFERENCES Bots(id),
    parameter_id INT REFERENCES StringHyperparametersOfStrategies (rel_id),
    UNIQUE (bot_id, parameter_id)
);

CREATE TABLE IF NOT EXISTS OperationType (
    id SERIAL PRIMARY KEY,
    name VARCHAR
);

CREATE TABLE IF NOT EXISTS BotsOperations (
    rel_id SERIAL PRIMARY KEY,
    bot_id INT REFERENCES Bots(id),
    op_id INT REFERENCES OperationType(id),

    stock_id INT,
    stock_count INT,
    stock_cost DOUBLE PRECISION,
    op_time TIMESTAMP
);

INSERT INTO OperationType(name) VALUES ('buy'), ('sell');


------------------------------------------------------------------------------------------------------------------------------------------
--
--                                                        CREATIONS
--
------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION create_strategy(strategy_name VARCHAR, strategy_description TEXT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    result INT;
BEGIN
   INSERT INTO Strategies(name, description) VALUES (strategy_name, strategy_description) RETURNING id INTO result;
   RETURN result;
END;
$$;

CREATE FUNCTION create_bot(bot_name VARCHAR, bot_desctiption TEXT, strategy_id INT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    result INT;
BEGIN
   INSERT INTO Bots(name, description, strategy_id) VALUES (bot_name, bot_desctiption, strategy_id) RETURNING id INTO result;
   RETURN result;
END;
$$;

CREATE FUNCTION create_int_parameter(param_name VARCHAR, param_description TEXT, default_param_value INT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    result INT;
BEGIN
   INSERT INTO IntHyperparameters(name, description, default_value) VALUES (param_name, param_description, default_param_value) RETURNING id INTO result;
   RETURN result;
END;
$$;

CREATE FUNCTION create_double_parameter(param_name VARCHAR, param_description TEXT, default_param_value DOUBLE PRECISION)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    result INT;
BEGIN
   INSERT INTO DoubleHyperparameters(name, description, default_value) VALUES (param_name, param_description, default_param_value) RETURNING id INTO result;
   RETURN result;
END;
$$;

CREATE FUNCTION create_string_parameter(param_name VARCHAR, param_description TEXT, default_param_value TEXT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    result INT;
BEGIN
   INSERT INTO StringHyperparameters(name, description, default_value) VALUES (param_name, param_description, default_param_value) RETURNING id INTO result;
   RETURN result;
END;
$$;

------------------------------------------------------------------------------------------------------------------------------------------
--
--                                                        PARAMETERS ADD
--
------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION add_int_parameter(param_id INT, strat_id INT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    ret INT;
BEGIN
   INSERT INTO IntHyperparametersOfStrategies(parameter_id, strategy_id) VALUES (param_id, strat_id) RETURNING rel_id INTO ret;
   RETURN ret;
END;
$$;

CREATE FUNCTION add_double_parameter(param_id INT, strat_id INT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    ret INT;
BEGIN
   INSERT INTO DoubleHyperparametersOfStrategies(parameter_id, strategy_id) VALUES (param_id, strat_id) RETURNING rel_id INTO ret;
   RETURN ret;
END;
$$;

CREATE FUNCTION add_string_parameter(param_id INT, strat_id INT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    ret INT;
BEGIN
   INSERT INTO StringHyperparametersOfStrategies(parameter_id, strategy_id) VALUES (param_id, strat_id) RETURNING rel_id INTO ret;
   RETURN ret;
END;
$$;

------------------------------------------------------------------------------------------------------------------------------------------
--
--                                                        PARAMETERS SET
--
------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION set_double_parameter(rel_param_id INT, cur_bot_id INT, new_value DOUBLE PRECISION)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO DoubleBotHyperparameters (value, bot_id, parameter_id) 
    VALUES (new_value, cur_bot_id, rel_param_id)
    ON CONFLICT (bot_id, parameter_id) DO UPDATE
    SET value = new_value;
    RETURN;
END;
$$;

CREATE FUNCTION set_int_parameter(rel_param_id INT, cur_bot_id INT, new_value INT)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO IntBotHyperparameters (value, bot_id, parameter_id) 
    VALUES (new_value, cur_bot_id, rel_param_id)
    ON CONFLICT (bot_id, parameter_id) DO UPDATE
    SET value = new_value;
    RETURN;
END;
$$;

CREATE FUNCTION set_string_parameter(rel_param_id INT, cur_bot_id INT, new_value TEXT)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO StringBotHyperparameters (value, bot_id, parameter_id) 
    VALUES (new_value, cur_bot_id, rel_param_id)
    ON CONFLICT (bot_id, parameter_id) DO UPDATE
    SET value = new_value;
    RETURN;
END;
$$;

------------------------------------------------------------------------------------------------------------------------------------------
--
--                                                        BOTS GET
--
------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION get_bot_strategy(cur_bot_id INT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
BEGIN
   RETURN (SELECT strategy_id FROM Bots WHERE id = cur_bot_id);
END;
$$;

CREATE FUNCTION get_bots_by_strategy(strat_id INT)
RETURNS TABLE (bot_id INT)
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY (SELECT id FROM Bots WHERE strategy_id = strat_id);
END;
$$;

------------------------------------------------------------------------------------------------------------------------------------------
--
--                                                        PARAMETERS GET  (TODO MAX)
--
------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION get_int_parameter(param_id INT, cur_bot_id INT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    default_val INT;
BEGIN
    default_val = (SELECT default_value 
         FROM IntHyperparameters 
         WHERE id = (
            SELECT parameter_id 
            FROM IntHyperparametersOfStrategies 
            WHERE strategy_id = (SELECT get_bot_strategy(cur_bot_id))
            )
        );
    RETURN (SELECT case count(*) when 0 then default_val else MAX(value) end FROM IntBotHyperparameters WHERE parameter_id = param_id AND bot_id = cur_bot_id);    
END;
$$;

CREATE FUNCTION get_double_parameter(param_id INT, cur_bot_id INT)
RETURNS DOUBLE PRECISION
LANGUAGE plpgsql
AS
$$
DECLARE
    default_val INT;
BEGIN
   default_val = (SELECT default_value 
         FROM DoubleHyperparameters 
         WHERE id = (
            SELECT parameter_id 
            FROM DoubleHyperparametersOfStrategies 
            WHERE strategy_id = (SELECT get_bot_strategy(cur_bot_id))
            )
        );
    RETURN (SELECT case count(*) when 0 then default_val else MAX(value) end FROM DoubleBotHyperparameters WHERE parameter_id = param_id AND bot_id = cur_bot_id);   
END;
$$;

CREATE FUNCTION get_string_parameter(param_id INT, cur_bot_id INT)
RETURNS TEXT
LANGUAGE plpgsql
AS
$$
DECLARE
    default_val INT;
BEGIN
    default_val = (SELECT default_value 
         FROM StringHyperparameters 
         WHERE id = (
            SELECT parameter_id 
            FROM StringHyperparametersOfStrategies 
            WHERE strategy_id = (SELECT get_bot_strategy(cur_bot_id))
            )
        );
    RETURN (SELECT case count(*) when 0 then default_val else MAX(value) end FROM StringBotHyperparameters WHERE parameter_id = param_id AND bot_id = cur_bot_id);    
END;
$$;

------------------------------------------------------------------------------------------------------------------------------------------
--
--                                                        OPERATIONS
--
------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION add_operation(bot_id INT, op_id INT, stock_id INT, stock_count INT, stock_cost DOUBLE PRECISION, op_time TIMESTAMP)
RETURNS void
LANGUAGE plpgsql
AS
$$
DECLARE
    bot_id_ INT;
    op_id_ INT;
BEGIN
    bot_id_ = (SELECT id FROM Bots WHERE id = bot_id);
    op_id_ = (SELECT id FROM OperationType WHERE id = op_id);
    INSERT INTO BotsOperations(bot_id, op_id, stock_id, stock_count, stock_cost, op_time) VALUES (bot_id_, op_id_, stock_id, stock_count, stock_cost, op_time);
    RETURN;
END;
$$;

CREATE FUNCTION get_operations(cur_bot_id INT)
RETURNS TABLE(_op_id INT, _stock_id INT, _stock_count INT, _stock_cost DOUBLE PRECISION, _op_time TIMESTAMP)
LANGUAGE plpgsql
AS
$$
BEGIN
   RETURN QUERY (SELECT op_id, stock_id, stock_count, stock_cost, op_time FROM BotsOperations WHERE bot_id = cur_bot_id);

END;
$$;

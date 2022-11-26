DROP DATABASE IF EXISTS algotrading;
CREATE DATABASE algotrading;

\c algotrading

CREATE TABLE IF NOT EXISTS Bots (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    strategy_id INT
);

CREATE TABLE IF NOT EXISTS IntBotHyperparameters  (
    value INT,
    bot_id INT,
    parameter_id INT,
    PRIMARY KEY (bot_id, parameter_id)
);

CREATE TABLE IF NOT EXISTS DoubleBotHyperparameters  (
    value DOUBLE PRECISION,
    bot_id INT,
    parameter_id INT,
    PRIMARY KEY (bot_id, parameter_id)
);

CREATE TABLE IF NOT EXISTS StringBotHyperparameters  (
    value VARCHAR,
    bot_id INT,
    parameter_id INT,
    PRIMARY KEY (bot_id, parameter_id)
);

CREATE TABLE IF NOT EXISTS OperationType (
    id SERIAL PRIMARY KEY,
    name VARCHAR
);

CREATE TABLE IF NOT EXISTS BotsOperations (
    rel_id SERIAL PRIMARY KEY,
    bot_id INT REFERENCES Bots(id),
    op_id INT REFERENCES OperationType(id),
    bot_balance DOUBLE PRECISION,
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

CREATE FUNCTION create_bot(bot_name VARCHAR, strategy_id INT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
    result INT;
BEGIN
   INSERT INTO Bots(name, strategy_id) VALUES (bot_name, strategy_id) RETURNING id INTO result;
   RETURN result;
END;
$$;

------------------------------------------------------------------------------------------------------------------------------------------
--
--                                                        PARAMETERS SET
--
------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION set_double_parameter(cur_bot_id INT, param_id INT, new_value DOUBLE PRECISION)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO DoubleBotHyperparameters (value, bot_id, parameter_id) 
    VALUES (new_value, cur_bot_id, param_id)
    ON CONFLICT (bot_id, parameter_id) DO UPDATE
    SET value = new_value;
    RETURN;
END;
$$;

CREATE FUNCTION set_int_parameter(cur_bot_id INT, param_id INT, new_value INT)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO IntBotHyperparameters (value, bot_id, parameter_id) 
    VALUES (new_value, cur_bot_id, param_id)
    ON CONFLICT (bot_id, parameter_id) DO UPDATE
    SET value = new_value;
    RETURN;
END;
$$;

CREATE FUNCTION set_string_parameter(cur_bot_id INT, param_id INT, new_value VARCHAR)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
   INSERT INTO StringBotHyperparameters (value, bot_id, parameter_id) 
    VALUES (new_value, cur_bot_id, param_id)
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

CREATE FUNCTION get_all_bots()
RETURNS TABLE (bot_id INT)
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY (SELECT id FROM Bots);
END;
$$;

CREATE FUNCTION get_bot_name(bot_id INT)
RETURNS VARCHAR
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN (SELECT name FROM Bots WHERE id = bot_id);
END;
$$;

------------------------------------------------------------------------------------------------------------------------------------------
--
--                                                        PARAMETERS GET  (TODO MAX)
--
------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION get_int_parameter(cur_bot_id INT, param_id INT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN (SELECT value end FROM IntBotHyperparameters WHERE parameter_id = param_id AND bot_id = cur_bot_id);    
END;
$$;

CREATE FUNCTION get_double_parameter(cur_bot_id INT, param_id INT)
RETURNS DOUBLE PRECISION
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN (SELECT value end FROM DoubleBotHyperparameters WHERE parameter_id = param_id AND bot_id = cur_bot_id);    
END;
$$;

CREATE FUNCTION get_string_parameter(cur_bot_id INT, param_id INT)
RETURNS VARCHAR
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN (SELECT value end FROM StringBotHyperparameters WHERE parameter_id = param_id AND bot_id = cur_bot_id);    
END;
$$;

------------------------------------------------------------------------------------------------------------------------------------------
--
--                                                        OPERATIONS
--
------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION add_operation(bot_id INT, op_id INT, cur_bot_balance DOUBLE PRECISION, stock_id INT, stock_count INT, stock_cost DOUBLE PRECISION, op_time TIMESTAMP)
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
    INSERT INTO BotsOperations(bot_id, op_id, bot_balance, stock_id, stock_count, stock_cost, op_time) VALUES (bot_id_, op_id_, cur_bot_balance, stock_id, stock_count, stock_cost, op_time);
    RETURN;
END;
$$;

CREATE FUNCTION get_operations(cur_bot_id INT)
RETURNS TABLE(_op_id INT, _stock_id INT, _stock_count INT, _stock_cost DOUBLE PRECISION, _op_time TIMESTAMP)
LANGUAGE plpgsql
AS
$$
BEGIN
   RETURN QUERY (SELECT op_id, bot_balance, stock_id, stock_count, stock_cost, op_time FROM BotsOperations WHERE bot_id = cur_bot_id);

END;
$$;

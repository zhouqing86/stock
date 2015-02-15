
-- DROP DATABASE if exists stocks;
CREATE DATABASE IF NOT EXISTS stocks;
use stocks;

CREATE TABLE IF NOT EXISTS stock(
  id int(12) NOT NULL,
  name varchar(32),
  code varchar(8),
  market varchar(4),
  business varchar(16),
  create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY  (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS transaction(
    id int(32) NOT NULL auto_increment,
    stock_id int(12) NOT NULL, 
    open decimal(10,2),
	closeprev decimal(10,2),
	close decimal(10,2),
	High decimal(10,2),
	Low decimal(10,2),
	amount int(32),
	volume int(32),
	buy1amount int(16),
	buy1price decimal(10,2),
	buy2amount int(16),
	buy2price decimal(10,2),
	buy3amount int(16),
	buy3price decimal(10,2),
	buy4amount int(16),
	buy4price decimal(10,2),
	buy5amount int(16),
	buy5price decimal(10,2),
	sell1amount int(16),
	sell1price decimal(10,2),
	sell2amount int(16),
	sell2price decimal(10,2),
	sell3amount int(16),
	sell3price decimal(10,2),
	sell4amount int(16),
	sell4price decimal(10,2),
	sell5amount int(16),
	sell5price decimal(10,2),
	date DATE,
	time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY  (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE IF NOT EXISTS PREFIX_fmdj_custompacks_product (
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	id_product INT NOT NULL,
	active BOOLEAN NOT NULL,
	UNIQUE KEY (id_product)
);

CREATE TABLE IF NOT EXISTS PREFIX_fmdj_custompacks_optgroup (
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	id_pack INT NOT NULL,
	optgroup VARCHAR(256) NOT NULL,
	opttype VARCHAR(64) NOT NULL,
	position INT NOT NULL,
	KEY (id_pack, optgroup),
	UNIQUE KEY (id_pack, optgroup)
);

CREATE TABLE IF NOT EXISTS PREFIX_fmdj_custompacks_component (
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	id_optgroup INT NOT NULL,
	id_product INT NOT NULL,
	KEY (id_optgroup, id_product),
	UNIQUE KEY (id_optgroup, id_product)
);
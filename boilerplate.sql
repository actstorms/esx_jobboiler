INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_boiler', 'boiler', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_boiler', 'boiler', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_boiler', 'boiler', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('boiler','boiler')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('boiler',0,'recruit','Recruit',20,'{}','{}'),
	('boiler',4,'boss','boss',100,'{}','{}')
;

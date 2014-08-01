
CREATE TABLE `devices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  ip varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


CREATE TABLE `interfaces` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  device int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

ALTER TABLE  `interfaces` ADD INDEX (  `device` );

ALTER TABLE  `interfaces` ADD FOREIGN KEY (  `device` ) REFERENCES  `test`.`devices` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

SET FOREIGN_KEY_CHECKS=0;
truncate devices;
SET FOREIGN_KEY_CHECKS=1;

delete from devices; 
alter table devices auto_increment 1;
delete from interfaces; 
alter table interfaces auto_increment 1;

/*
 *      Procedure Name  :  usp_cursor_example
 *      Database/Schema :  foo
 *
 *      Description:
 *          An example of a MySQL stored procedure that uses a cursor
 *
 *
 *      Tables Impacted :
 *         foo.friend_status - read-only
 *         DDL? - None
 *         DML? - Only Selects
 *
 *      Params:
 *         name_in - the name of the friend to search for
 *
 *      Revision History:
 *
 *         Date:          Id:        Comment:
 *         2009/03/01     asaleh    Original
 *
 *    Copyright (c) 2013 Angelo Saleh
 *    Can be resused under terms of the 'MIT license'.
 *
 *    To test:
 *      - Multiple records: call foo.usp_cursor_example('John');
 *      - One record:       call foo.usp_cursor_example('Julie');
 *      - Zero records:     call foo.usp_cursor_example('Waldo');
 *
 */

delimiter //
drop procedure if exists sp_insert_devices;
create procedure sp_insert_devices (ending_msn varchar(500))
proc_label:BEGIN
 declare v_max int unsigned default 255;
 declare v_counter int unsigned default 1;

  start transaction;
  while v_counter <= v_max do
    insert into devices values (v_counter,concat('device',v_counter),concat('172.16.16.',v_counter));
    set v_counter=v_counter+1;
  end while;
  commit;

  select ending_msn;
  
  LEAVE proc_label;

  insert into interfaces values(1,'interface of test',1);

  select 'segundo mensaje';

end //
delimiter ;


insert into interfaces select null,concat('interface loopback of ',name,' - ',ip),id from devices;


DELIMITER $$
DROP function IF EXISTS func_insert_interfaces$$
CREATE FUNCTION func_insert_interfaces (s CHAR(50), inter INT) RETURNS CHAR(150) DETERMINISTIC
BEGIN
 
 DECLARE id_dev INTEGER;
 DECLARE ip_dev TEXT;
 DECLARE flag INTEGER DEFAULT 0;

 DECLARE inter_counter INTEGER DEFAULT 1;
 
 DECLARE curs1 CURSOR FOR SELECT id,ip FROM devices;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET flag = 1;

 OPEN curs1;

 the_loop: LOOP
  FETCH curs1 INTO id_dev,ip_dev;
  
  IF flag THEN
    CLOSE curs1;
    LEAVE the_loop;
  END IF;
  
  WHILE inter_counter <= inter DO
  	insert into interfaces values(null,concat('interface ',inter_counter,' del device ',ip_dev),id_dev);
    set inter_counter=inter_counter+1;
  END WHILE;
  
  set inter_counter=1;

 END LOOP the_loop;

 RETURN CONCAT('Hello, ',s,' ingresadas de a ',inter,' por device!');

END$$
DELIMITER ;

SELECT d.name, d.ip, i.name
FROM devices d 
JOIN interfaces i ON i.device=d.id;

SELECT d.name, d.ip, i.name
FROM devices d 
LEFT JOIN interfaces i ON i.device=d.id;

SELECT d.name, d.ip
FROM devices d 
WHERE d.id NOT IN (SELECT device from interfaces where device =d.id);

SELECT d.name, d.ip, group_concat(i.name SEPARATOR '\n')
FROM devices d 
JOIN interfaces i ON i.device=d.id
GROUP BY d.id;

SELECT d.name, d.ip, group_concat(i.name SEPARATOR '\n')
FROM devices d 
LEFT JOIN interfaces i ON i.device=d.id
GROUP BY d.id;

create table tmp_interfaces select * from interfaces;

update interfaces i JOIN devices d ON d.id=i.device AND i.name like '%loop%' set i.name=concat('Loopback ',d.ip);
	
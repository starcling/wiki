DELIMITER $$
CREATE DEFINER=`MYSQL_USER`@`localhost` PROCEDURE `get_account`(
  IN key_address VARCHAR(300)
)
BEGIN
  SELECT address, privateKey FROM account
  WHERE address = key_address;
END $$
DELIMITER ;
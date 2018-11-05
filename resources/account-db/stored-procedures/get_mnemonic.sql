DELIMITER $$
CREATE DEFINER=`MYSQL_USER`@`localhost` PROCEDURE `get_mnemonic`(
  IN _id VARCHAR(255)
)
BEGIN
  SELECT mnemonic FROM mnemonics
  WHERE id = _id;
END $$
DELIMITER ;
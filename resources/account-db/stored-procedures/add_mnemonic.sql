DELIMITER $$
CREATE DEFINER=`MYSQL_USER`@`localhost` PROCEDURE `add_mnemonic`(
  IN id VARCHAR(255), 
  IN mnemonic VARCHAR(2000)
)
BEGIN
INSERT INTO mnemonics (id, mnemonic) VALUES(id, mnemonic);
END $$
DELIMITER ;
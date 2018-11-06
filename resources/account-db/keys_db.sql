USE  'keys_db';

/***CREATING ALL TABLES*/
CREATE TABLE account (
  id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
  address VARCHAR (100) UNIQUENOT NULL,
  privateKey VARCHAR (2000) NULL
);

CREATE TABLE mnemonics
(
  id VARCHAR(255) PRIMARY KEY NOT NULL,
  mnemonic VARCHAR(2000) UNIQUE NOT NULL
);

DELIMITER $$
CREATE DEFINER=`keys_user` PROCEDURE `add_account`
(
  IN address VARCHAR (300), 
  IN pKey VARCHAR (300)
)
BEGIN
  INSERT INTO account
    (address, privateKey)
  VALUES(address, pKey);
END
$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`keys_user` PROCEDURE `add_mnemonic`
(
  IN id VARCHAR (255), 
  IN mnemonic VARCHAR (2000)
)
BEGIN
  INSERT INTO mnemonics
    (id, mnemonic)
  VALUES(id, mnemonic);
END
$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`keys_user` PROCEDURE `get_account`
(
  IN key_address VARCHAR (300)
)
BEGIN
  SELECT address, privateKey
  FROM account
  WHERE address = key_address;
END
$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`keys_user` PROCEDURE `get_mnemonic`
(
  IN _id VARCHAR (255)
)
BEGIN
  SELECT *
  FROM mnemonics
  WHERE id = _id;
END
$$
DELIMITER ;

DELIMITER ;;
CREATE DEFINER=`keys_user` PROCEDURE `get_private_key_from_address`
(
  IN accountAddress VARCHAR (300)
)
BEGIN
  DECLARE accountKey VARCHAR   (1000);

set @accountKey = (select privateKey
from account
where address = accountAddress);
if @accountKey is null 
  then 
    signal sqlstate '02000'
    set message_textc= 'Provided address is not found in the account table';
  end
if;

SELECT @accountKey;
END;;
DELIMITER ;



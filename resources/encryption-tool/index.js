var AWS = require('aws-sdk');
AWS.config.update({region: 'eu-west-1' });
var kms = new AWS.KMS();
require('dotenv').config()

const privateKeyParams = {
  KeyId: process.env.AWS_KEY_ID,
  Plaintext: process.env.MERCHANT_PRIVATE_KEY
};

const mnemonicParams = {
  KeyId: process.env.AWS_KEY_ID,
  Plaintext: process.env.MERCHANT_MNEMONIC_PHRASE
};

const init = async () => {
  let privateKeyCipher, 
      mnemonicCipher;
  try{
    privateKeyCipher = (await kms.encrypt(privateKeyParams).promise()).CiphertextBlob.toString('base64');
  }catch(err) {
    console.log(`Error encrypting the private keys, ${err.message}`);
  }
  try {
    mnemonicCipher = (await kms.encrypt(mnemonicParams).promise()).CiphertextBlob.toString('base64');
  }catch(err) {
    console.log(`Error encrypting the mnemonic ${err.message}`);
  }

  console.log(`Encrypted data: 


******************************************************************

PrivateKey: ${privateKeyCipher}

AddAccount call: 

CALL add_account('${process.env.MERCHANT_ADDRESS}', '${privateKeyCipher}');

------------------------------------------------------------------

Mnemonic: ${mnemonicCipher}

AddMnemonic call: 

CALL add_mnemonic('${process.env.MERCHANT_MNEMONIC_ID}', '${mnemonicCipher}');

******************************************************************
  `);
}


init();
  


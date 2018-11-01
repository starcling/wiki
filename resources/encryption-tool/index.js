var AWS = require('aws-sdk');
AWS.config.update({region: 'eu-west-1' });
var kms = new AWS.KMS();
require('dotenv').config()
const config = require('./config');
const params = config.getConfig();

if(!params) {
  return console.error('No parmaters available for current aws profile');
}

const privateKeyParams = {
  KeyId: params.KeyId,
  Plaintext: params.privateKey
};

const mnemonicParams = {
  KeyId: params.KeyId,
  Plaintext: params.mnemonic
};
console.log(`Starting encryption for ${process.env.AWS_PROFILE} profile`);

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

Profile: ${process.env.AWS_PROFILE.toUpperCase()}

******************************************************************

PrivateKey: ${privateKeyCipher}

AddAccount call: 

CALL add_account('${params.account}', '${privateKeyCipher}');

------------------------------------------------------------------

Mnemonic: ${mnemonicCipher}

AddMnemonic call: 

CALL add_mnemonic('${params.mnemonicId}', '${mnemonicCipher}');

******************************************************************
  `);
}


init();
  


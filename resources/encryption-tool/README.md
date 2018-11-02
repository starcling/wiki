# Encryption tool
Private keys and mnemonics encryption tool that is used to encrypt sensitive data  stored in the MySql database. 

In order to safelly store merchant private keys and mnemonics we need to encrypt data before storing it in the database. This tools is used to easily encrypt this data using the AWS KMS. 

## Instructions

Before using the tool make sure you create the AWS account and get access data. You can read about setting the credentials in Node.js: 
* [Setting credentials in Node](https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-credentials-node.html), 
* [Configuring the SDK for JavaScript](https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-credentials-node.html)
* [Loading credentials in Node.js](https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/loading-node-credentials-environment.html)

We are storing credentials in the `~./aws/credentials` file in the following format: 
```
[default]
aws_access_key_id = [AWS_ACCESS_KEY_ID]
aws_secret_access_key = [AWS_SECRED_ACCESS_KEY]
region = [REGION_OF_THE_KMS_KEY]
```
Once we have AWS credentials in the place, we are able to use AWS API from the Node.js module. 

Next step is to create KMS encryption key and add it to the `.env` file. 

Create `.env` file and following data: 
```
AWS_KEY_ID=[ID OF THE  KMS KEY]
MERCHANT_ADDRESS=[MERCHANT ADDRESS]
MERCHANT_PRIVATE_KEY=[MERCHANT PRIVATE KEY]
MERCHANT_MNEMONIC_ID=[MNEMONIC IDENTIFIER]
MERCHANT_MNEMONIC_PHRASE=[MNEMONIC PHRASE]
```
* `MERCHANT ADDRESS`: Public address of the merchant's account
* `MERCHANT PRIVATE KEY`: Private key of the merchant's account. This information should be kept private, as it provides access to all the funds stored in the merchants account. 
* `MNEMONIC IDENTIFIER`: Mnemonic identifier. This can have any value, and is used to access the mnemonic on the merchant backedn. It is important to keep not of this value, as it will be used to setup the merchant backend. 
* `MNEMONIC PHRASE`: Merchant account mnemonic phrase. It is used to retreive merchant's account. It is important to keep it secred as it give's access to the merchant account and funds. 

**Content of the .env file should be kept in the safe place as it provides access to merchant funds!**

In order to use the tool you need to have Node.js and Node Package Manager (NPM) installed. Check how to install [Node.js](https://nodejs.org/en/download/package-manager/) and [NPM](https://www.npmjs.com/get-npm) on your system.

After you have Node.js and NPM install, go to the folder where you downloaded the encryption module and run: 
``` 
 npm install 
 ```
 This will isntall all the neccessary dependencies for running the tool. 

Then encrypt data by running: 
```
npm run encryption
```
This will create `encrypted_data.txt` file in the `encrypted_keys` folder.

This is the example of the output file: 

```
 
Encrypted data: 

******************************************************************

PrivateKey: 12345678abcdefg

AddAccount call: 

CALL add_account('0x1111122223333', '12345678abcdefg');

------------------------------------------------------------------

Mnemonic: 12345678abcdefg

AddMnemonic call: 

CALL add_mnemonic('mnemonic_phrase_prod', '12345678abcdefg');

******************************************************************
  
```
The content of this can than be used to initialize the encrypted private keys database of the merchant backend. 

# Encryption tool
Private keys and mnemonics encryption tool that is used to encrypt sensitive data  stored in the MySql database. 

In order to safelly store merchant private keys and mnemonics we need to encrypt data before storing it in the database. This tools is used to easily encrypt this data using the AWS KMS. 

## Instructions

Before using the tool make sure you create the AWS account and get access data. You can read about setting the credentials in Node.js ![here](https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-credentials-node.html)

The tool uses AWS SDK for Node.js. In order to use the sdk, you need to get user credentials from aws. After getting the credentials store them in the ~./
Create `.env` file and following data: 

```
AWS_KEY_ID=[AWS KEY ID]
MERCHANT_ADDRESS=[MERCHANT ADDRESS]
MERCHANT_PRIVATE_KEY=[MERCHANT PRIVATE KEY]
MERCHANT_MNEMONIC_ID=[MNEMONIC IDENTIFIER]
MERCHANT_MNEMONIC=[MNEMONIC]
```


Before using the tool we need to have following information: 

* asw_key_id
- 
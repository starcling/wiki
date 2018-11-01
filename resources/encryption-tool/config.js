//require('dotenv').config()
const roles = {
  'pre-prod-core-test-iam': {
    privateKey: process.env.PREPROD_CORE_TEST_PRIVATE_KEY,
    KeyId: process.env.PREPROD_CORE_TEST_AWS_KEY_ID,
    mnemonic: process.env.PREPROD_CORE_TEST_MNEMONIC,
    mnemonicId: process.env.PREPROD_CORE_TEST_MNEMONIC_ID,
    account: process.env.PREPROD_CORE_TEST_ACCOUNT_ADDRESS
  },
  'pre-prod-core-main-iam': {
    privateKey: process.env.PREPROD_CORE_MAIN_PRIVATE_KEY,
    KeyId: process.env.PREPROD_CORE_MAIN_AWS_KEY_ID,
    mnemonic: process.env.PREPROD_CORE_MAIN_MNEMONIC,
    mnemonicId: process.env.PREPROD_CORE_MAIN_MNEMONIC_ID,
    account: process.env.PREPROD_CORE_MAIN_ACCOUNT_ADDRESS
  },
  'pre-prod-merchant-test-iam': {
    privateKey: process.env.PREPROD_MERCHANT_TEST_PRIVATE_KEY,
    KeyId: process.env.PREPROD_MERCHANT_TEST_AWS_KEY_ID,
    mnemonic: process.env.PREPROD_MERCHANT_TEST_MNEMONIC,
    mnemonicId: process.env.PREPROD_MERCHANT_TEST_MNEMONIC_ID,
    account: process.env.PREPROD_MERCHANT_TEST_ACCOUNT_ADDRESS
  },
  'pre-prod-merchant-main-iam': {
    privateKey: process.env.PREPROD_MERCHANT_MAIN_PRIVATE_KEY,
    KeyId: process.env.PREPROD_MERCHANT_MAIN_AWS_KEY_ID,
    mnemonic: process.env.PREPROD_MERCHANT_MAIN_MNEMONIC,
    mnemonicId: process.env.PREPROD_MERCHANT_MAIN_MNEMONIC_ID,
    account: process.env.PREPROD_MERCHANT_MAIN_ACCOUNT_ADDRESS
  },
  'prod-core-test-iam': {
    privateKey: process.env.PROD_CORE_TEST_PRIVATE_KEY,
    KeyId: process.env.PROD_CORE_TEST_AWS_KEY_ID,
    mnemonic: process.env.PROD_CORE_TEST_MNEMONIC,
    mnemonicId: process.env.PROD_CORE_TEST_MNEMONIC_ID,
    account: process.env.PROD_CORE_TEST_ACCOUNT_ADDRESS
  },
  'prod-core-main-iam': {
    privateKey: process.env.PROD_CORE_MAIN_PRIVATE_KEY,
    KeyId: process.env.PROD_CORE_MAIN_AWS_KEY_ID,
    mnemonic: process.env.PROD_CORE_MAIN_MNEMONIC,
    mnemonicId: process.env.PROD_CORE_MAIN_MNEMONIC_ID,
    account: process.env.PROD_CORE_MAIN_ACCOUNT_ADDRESS
  },
  'prod-merchant-test-iam': {
    privateKey: process.env.PROD_MERCHANT_TEST_PRIVATE_KEY,
    KeyId: process.env.PROD_MERCHANT_TEST_AWS_KEY_ID,
    mnemonic: process.env.PROD_MERCHANT_TEST_MNEMONIC,
    mnemonicId: process.env.PROD_MERCHANT_TEST_MNEMONIC_ID,
    account: process.env.PROD_MERCHANT_TEST_ACCOUNT_ADDRESS
  },
  'prod-merchant-main-iam': {
    privateKey: process.env.PROD_MERCHANT_MAIN_PRIVATE_KEY,
    KeyId: process.env.PROD_MERCHANT_MAIN_AWS_KEY_ID,
    mnemonic: process.env.PROD_MERCHANT_MAIN_MNEMONIC,
    mnemonicId: process.env.PROD_MERCHANT_MAIN_MNEMONIC_ID,
    account: process.env.PROD_MERCHANT_MAIN_ACCOUNT_ADDRESS
  }

}

module.exports = {
  getConfig() {
    if(process.env.AWS_PROFILE && roles[process.env.AWS_PROFILE]) {
      return roles[process.env.AWS_PROFILE];
    }

    return false;
  }
}
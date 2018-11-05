# PumaPay Pull Payment Protocol Wiki
The PumaPay Pull Payment protocol allows recurring payment to occur over the Ethereum Blockchain.

## Table of content
- [Ecosystem Components](#ecosystem-components)
    - [PumaPay Core](#pumapay-core)
    - [PumaPay SDK](#pumapay-sdk)
    - [PumaPay Merchant Backend](#pumapay-merchant-backend)
    - [PumaPay Wallet App](#pumapay-wallet-app)
    - [PumaPay Faucet](#pumapay-faucet)
- [Blockchain Components](#blockchain-components)
    - [PumaPay Token](#pumapay-token)
    - [PumaPay Pull Payment](#pumapay-pull-payment)
- [PumaPay Core](#pumapay-core)
- [Merchant Backend](#merchant-backend)
    - [Util Components](#util-components)
        - [HD Wallet](#hd-wallet)
        - [Treasury Account](#treasury-account)
        - [Gas Account](#gas-account)
        - [PullPayment Account](#pullpayment-account)
        - [Cashing out ETH and PMA](#cashing-out-eth-and-pma)
        - [Funding ETH](#funding-eth)
    - [Technical Components](#technical-components)
        - [NodeJS](#nodejs)
        - [PostgreSQL Database](#postgresql-database)
        - [MySQL Database](#mysql-database)
        - [Redis](#redis)
- [Pull Payments in detail](#pull-payments-in-detail)
    - [Billing models](#billing-models)
    - [Pull Payments](#pull-payments)
    - [Pull Payments registration flow](#pull-payments-registration-flow)
- [Merchant Integration Guide](#merchant-integration-guide)
    - [Register with PumaPay as trusted merchant](#register-with-pumapay-as-trusted-merchant)
    - [Setting up NodeJS Server](#setting-up-nodejs-server)
    - [Setting up PostgreSQL Database](#setting-up-postgresql-database)
    - [Setting up MySQL Database](#setting-up-mysql-database)


## Ecosystem Components
### PumaPay Core
The core is our custom framework and heart of our system.
Our PumaPay Core allows the governance, control and utilisation of our PullPayment protocol.
### PumaPay SDK
The SDK module gives functionality to any third party integrator to allow execution of PullPayments.
### PumaPay Merchant Backend
The Merchant backend consists of a set of APIs that the merchant can use to connect to the rest of the
PumaPay ecosystem. It also allows the merchant to have an overview of their billing models, subscriptions and blockchain transactions.
### PumaPay Wallet App
Our mobile wallet app is used by consumers that hold PMA tokens to allow them to hold and transfer PMA, ETH and other ERC-20 tokens.
It allows the consumers to subscribe to PullPayments models specified by merchants, cancel their subscriptions and monitor the blockchain transactions
related with their PullPayments.

[![GooglePlay](https://pumapay.io/wp-content/uploads/2018/06/googleplaybtn.png)](https://play.google.com/store/apps/details?id=com.pumapay.pumawallet)
[![AppleStore](https://pumapay.io/wp-content/uploads/2018/06/appstorebtn.png)](https://itunes.apple.com/app/id1376601366)

### PumaPay Faucet
The faucet is a component that provides test PMA tokens for testing. It essentially drip feeds the tokens to users so that
they have a source of tokens for testing purposes and play around with our PullPayment protocol.
You can find the PMA faucet [here](https://faucet.pumapay.io/).

## Blockchain Components
### PumaPay Token
The [PumaPay token](https://etherscan.io/token/0x846c66cf71c43f80403b51fe3906b3599d63336f) is based on
the [ERC-20 Token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) developed in Solidity
and deployed on the Ethereum network on our TGE which occurred on May 7th 2018.
### PumaPay Pull Payment
The PumaPay Pull Payment Protocol supports an advanced "pull" mechanism, which allows users to not only push
tokens from one wallet to another but to also pull funds from other wallets after prior authorization has been given.

Our Pull Payment Protocol currently supports the following PullPayments:
* Single Pull Payment - Example: One time payment of $5.00
* Recurring Pull Payment (Fixed amount) - Example: Monthly subscription of $12.99
* Recurring Pull Payment with trial period - Example: Free trial of 15 days and monthly subscription of $20.00
* Recurring Pull Payment with initial payment - Example: $3.00 for 3 days and weekly subscription of $10.00

The first version of our protocol has a semi-decentralized approach in order to reduce the gas fees that are
involved with setting the PMA/Fiat rates on the blockchain and eliminate the customer gas fees for registering and
cancelling PullPayments, which are currently taken care of by PumaPay through the smart contract.

You can find detailed description of the smart contracts utilizing the PullPayment protocol [here](https://github.com/pumapayio/pumapay-token/).

## PumaPay Core
The PumaPay Core is our custom framework and heart of our system, which allows the governance, control and utilisation of our PullPayment protocol.
It consists of a set of APIs that allow for the communication between the PumaPay ecosystem components to put the PullPayment protocol into action.
Currently few APIs are publicly available that allow the merchant to register with and retrieve their merchant ID and their API key that will be used
for secure communication with our core server.

[PumaPay Core API Documentation](https://precore.pumapay.io/api/v2/doc/api/#)

## Merchant Backend
The v2.0 of the PumaPay PullPayment protocol on the merchant side consists of a set of APIs that the merchant
can use to connect to the rest of the PumaPay ecosystem.
All the relevant core functionality is provided by the PumaPay [merchant SDK](https://github.com/pumapayio/merchant.sdk).

### Util Components
#### HD wallet
##### What is an HD Wallet
HD Wallets, or Hierarchical Deterministic wallets use 12-word master seed keys. Each time this seed is appended by a counter at the end and is used to derive seemingly unlimited new addresses hierarchically and sequentially.
HD wallets generate a hierarchical tree-like structure of keys which start from the seed master key based on [BIP 32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki). When you restore an HD wallet using the seed key, the wallet goes ahead and drives all the private keys of the tree using BIP 32.

##### How is it used in the PumaPay Merchant backend
The merchant backend needs to execute PullPayments on the Ethereum network. Each payment has a different PullPayment account address (merchant address that is allowed to execute a PullPayment) since having only one address executing all the PullPayments will be very slow if the number of customer and PullPayments is high.
For that same reason, the current version of our protocol does not support multiple PullPayments for the same customer address and the same merchant address. Hence we decided to use an HD-Wallet which has unlimited addresses and use a different address for each PullPayment.

We made a distinction between the address at index 0 (treasury/gas account from now on) of the HD-Wallet and the rest of the addresses (PullPayment accounts from now on) in such a way that the treasury account will hold most of the ETH and PMA of the HD-Wallet. The ETH from the treasury account will be used for funding the PullPayment accounts with enough ETH to pay for the gas fees throughout the whole lifecycle of the PullPayment and the PMA will be cashed-out from the PullPayment accounts to the treasury account based on the logic of the billing model.

#### Treasury Account
The treasury account is the account at index 0 of the HD Wallet. Its main purpose is to keep the most of the funds of the HD-Wallet to one address and to collect the PMA tokens from the PullPayments.  
Check [cashing out](#cashing-out-eth-and-pma) for more details.
#### Gas Account
The gas account is also the account at index 0 of the HD Wallet. Even though the main purpose stays the same the idea of the gas account is to
fund the PullPayment accounts with the respective amount of ETH that will be spent as gas fees for the execution of the PullPayments.  
Check [Funding ETH](#funding-eth) for more details.
#### PullPayment Account
The PullPayment account can be any other account of the HD Wallet higher than index 1. The PullPayment account is used to create an 1-to-1 relationship between a billing model and a customer address.

#### Cashing out ETH and PMA
The idea behind funding and cashing out is to keep the most of the funds of the HD-Wallet to one address i.e. treasury account. For this reason, we have implemented the cash-out functionality (transfer) of ETH and PMA from the PullPayment accounts to the treasury account.  

The cash-out takes place based on the logic of the billing model and more specifically to `automatedCashOut` which needs to be set to `true` and the `cashOutFrequency` which should be an `integer greater or equal to 1` if the `automatedCashOut == true`.

Cashing out can take place:
1. On every PullPayment execution,
2. After certain amount of PullPayment executions as specified in the logic of the billing model,
3. At the end of the PullPayment i.e. all the PullPayment executions have taken place,
4. On PullPayment cancellation by the customer

**Example:**  
If `automatedCashOut == true && cashOutFrequency == 1`, it implies that there should be an automated transfer of PMA from the PullPayment account to the treasury account after every execution. When the PullPayment is finished i.e. all the executions took place, all the PMA and ETH left in the PullPayment account will be transferred to the treasury account.

If `automatedCashOut == false` the `cashOutFrequency` should be 0 and the merchant will need to manually transfer the ETH and PMA from the PullPayment account to another address or keep them there.

#### Funding ETH
Each PullPayment account needs to hold enough ETH to pay for the Ethereum transaction fees (gas) when executing a PullPayment. For this reason, whenever a new PullPayment is registered on the blockchain enough ETH are transferred from the gas account to the PullPayment account to allow for all the executions of the PullPayment lifecycle to take place.  
The following mathematical formula is used to calculate the amount of ETH to be transferred for gas.

![Algorithm](https://latex.codecogs.com/svg.latex?1.3\ast((\sum_{n=0}^{a}PullPaymentExecutionFee&plus;TransferFeeForPMA)&plus;TransferFeeForETH))

a = number of payments

PullPaymentExecutionFee = Maximum gas fee that was used in the previous executions

TransferFeeForPMA = Gas fee estimation based on a regular ERC20 transfer transaction

TransferFeeForETH = Gas fee estimation based on a regular ETH transfer transaction


### Technical Components
#### NodeJS
The NodeJS server uses the merchant SDK as a singleton and provides a list of API methods that are used to specify their own
billing models, to register the PullPayments of their customers as well as executing and monitoring the
blockchain transactions related with the PullPayments.

#### PostgreSQL Database
The PostgreSQL database stores the billing models, the PullPayments and the Ethereum transactions.

![Merchant Backend Database](assets/MerchantBackendDB.png)

#### MySQL Database
MySQL database is an encrypted database used for encrypting the HD wallet with the Ethereum addresses that the merchant uses on their end
for executing PullPayments on the blockchain, for funding the PullPayment account addresses with ETH to pay for gas and cashing
out PMA and ETH to a treasury account on their end.
<!--DB model to be provided-->

#### Redis
Redis in-memory data structure store is used for storing information related to the PullPayment account address that will be
executing the PullPayment and for storing the maximum gas used for a PullPayment transaction.

## Pull Payments in detail
An example of the available APIs that the merchants will have in their disposal after setting up their backend server can be found [here](https://prembackend.pumapay.io/api/v2/doc/api/#)

### Billing Models
A merchant can create and manage their billing models within their system. That can be done through the API methods that the merchants have in their backend system.
### Pull Payments
PullPayments are actual payments or subscriptions that the customer has registered to. Each PullPayment is related with a billing model that the merchant has defined.

### Pull Payments registration flow
A customer can subscribe with a merchant through the following flow:
1. The merchant needs to create a billing model through the API methods that the merchants have in their backend system.
2. The payload for the QR code related with a billing model can be generated through the SDK and can be provided to the customer for scanning it with the PumaPay wallet app.
3. By scanning the QR code from the PumaPay wallet app, the customer will be able to see all the details for that PullPayment as specified in the billing model.
4. If the customer agrees to subscribe the the PullPayment, a new PullPayment will be created in the merchant backend linked to the billing model.
5. The wallet signs the registration of the PullPayment and send it to the PumaPay core for transmitting the transaction to the blockchain.
6. Once the PumaPay core retrieves the transaction hash, it updates the merchant backend through an API. The merchant backend monitors the transaction hash until it retrieves the transaction receipt.
7. If the transaction receipt is successful, funding of the PullPayment account takes place and a scheduler is in place to execute the PullPayment based on the start time and the frequency of the PullPayment.
8. After the PullPayment ends the cash-out of ETH and PMA from the PullPayment account to the treasury account will take place.

## Merchant Integration Guide
#### Register with PumaPay as trusted merchant
The first thing that the merchant needs to do is to register through the PumaPay core APIs with the API call, possibly through Postman, in order to retrieve their `API key` and their `merchantID` that is essential for setting up their NodeJS server.

**Note:** An Ansible script which will ease the merchant backend setup is on the final stages of development and will be published soon.

1.	A merchant should register through our core api `/api/v2/user/register`  by providing all the relevant details as specified in
the API documentation. In the registration response, the merchant will get their `merchantID` that will be used for setting up the Node server.
It is important to make note of the `merchantID`. The merchant will also receive an email with a verification link that is used to verify the email address.

*Please note, that specified password must have at least 1 uppercase letter, at least 1 lowercase, at least 1 number and at least 1 special character.*

2.	After the email verification, the merchant should login to the core `/api/v2/login/user` by using the email and password.
The login return thes
merchant's `pma-user-token` that should be used to access the `API key`.

3.	 The `pma-user-token` needs to be added to the header of the `API key` request `api/v2/generate-api-key`.
The response gives the `pma-api-key` that is used to communicate to the core server from the backend server.

#### KYC Procedure
To become fully authorised merchant, you need to go through the KYC procedure. After registration and verification of your email address, an email will be sent describing our KYC procedure in detail and requesting the relevant documents.
Please make sure to encrypt all of your documents before sending and provide us with the decryption key.
The encryption/decryption tool we suggest is PGP Desktop.
Please send the encrypted list of required documents to kyc@pumapay.io

##### Verification process
1.	We are running the documents through our internal Verification process
2.	Once approved, we are changing the Merchant’s status to Verified
3.	Merchant can continue and receives API keys.

**Important:** The `API key` and the `merchantID` **should be noted down** since they will be used later for
setting up the Merchant NodeJS server.

#### Setting up NodeJS Server
For setting up the NodeJS server, PumaPay has a docker image of the merchant backend that can be used for easy and
fast setup by the merchants.

1. Retrieve Merchant Backend Docker image
The docker image is currently in our private docker registry and verified merchants will be granted access.
Once registered you can request access by sending an email to docker@pumapay.io that includes your merchant ID, and your docker hub username/email.

Once granted access to the docker registry you can login and pull the docker image from there.

```
docker login
# use your credentials
docker-compose pull
```

Once you get the docker image you should modify the docker-compose example file that can be found in
our [here](resources).

2. Docker configuration
```
- NODE_ENV=development                          # development for testnet / production for mainnet
- HOST=localhost                                # server host
- PORT=3000                                     # server port
- CORE_API_URL=https://stgcore.pumapay.io/core  # PumaPay core URL
- MERCHANT_URL=http://localhost:3000            # Merchant server URL
- PGHOST=postgres_merchant                      # PostgreSQL db host
- PGUSER=db_user                                # PostgreSQL db user
- PGPASSWORD=db_pass                            # PostgreSQL db password
- PGDATABASE=db_name                            # PostgreSQL db name
- PGPORT=5432                                   # PostgreSQL db port
- REDIS_PORT=6379                               # Redis Port
- REDIS_HOST=merchant_redis                     # Redis Host
- REDIS_TOKEN=123456789                         # Redis token - AWS Setup
- ETH_NETWORK=3                                 # Ethereum network - 3 for testnet / 1 for mainnet
- KEY_DB_HOST=db_host                           # MySQL db host
- KEY_DB_USER=db_user                           # MySQL db user
- KEY_DB_PASS=db_pass                           # MySQL db password
- KEY_DB=db_name                                # MySQL db name
- KEY_DB_PORT=3306                              # MySQL db port
- MNEMONIC_ID=mnemonic_phrase_id                # Mnemonic phrase ID - as stored in MySQL db from the SQL script
- BALANCE_MONITOR_INTERVAL=21600000             # Time interval in seconds to monitor the balance of the bank wallet account
- BALANCE_CHECK_THRESHOLD=0.1                   # Threshold which will send an email notifcation to the email provided
- SENDGRID_API_KEY=RETRIEVE_ONE_FROM_SENDGRID   # SendGrid API key - is used for sending emails related with wallet balances
- BALANCE_CHECK_EMAIL=test@test.test            # Receiver email for the balance checker - testing environment
- BALANCE_CHECK_EMAIL_PROD=test@test.test       # Receiver email for the balance checker - production environment
- CORE_API_KEY=API_KEY_RETRIEVED_FROM_CORE      # API key retrieved after registering to PumaPay core server
- MERCHANT_ID=MERCHANT_ID_RETRIEVED_FROM_CORE   # Merchant ID as retrieved from PumaPay core after registration
```

#### Setting up PostgreSQL Database
Install the PostgreSQL Database, preferably on the separate server, and make sure you have the secure connection to the server running the Node project. Create a user and a database, and add credentials to the docker-compose enviroment variables (`PGHOST, PGUSER, PGPASSWORD, PGDATABASE, PGPORT`).

Grant all privilages to the created user over the database that is going to be used by the backend.

All the PostgreSQL DB scripts for setting up the PostgreSQL database can be found [here](resources/db).

Before runing the script  make sure  to edit each script and set the correct `PGUSER`. For example:
```
The SQL scripts can run as provided but it is highly recommended that database user is changed according to the
PostgeSQL database that the merchant has setup.
Example:
```sql
ALTER TABLE public.tb_payment_status
    OWNER to local_user;
```
should become
```
ALTER TABLE public.tb_payment_status
    OWNER to your_username;
```

Than the scripts can be ran one by one or merged into a single script using the tools like Gulp.

After successfully running the scripts, you should have the database ready.

#### Setting up MySQL Database

It is recommended not to use the root user.  Before initializing the database, please create a user and add the username to the `KEY_DB_USER` variable in the docker-compose file.
After adding the user, create a database, name as you like, and add the database name to the `KEY_DB` variable in the docker-compose file.
Make sure to grant all the privileges to the new user over the created database.

Preferably mysql instance will run on separate server, that talks to the Node server over secure connection.
Connection details of the mysql connection should be included in the docker-compose file (`KEY_DB_HOST, KEY_DB_USER, KEY_DB_PASS, KEY_DB_PORT, KEY_DB`)

Make sure that the mysql version supports `keyring_file.so` and `keyring_udf.so` plugin as it is used to encrypt the data.

After you created the user and the databse, you can run initialization scripts that can be found [here](resources/account-db).
Before starting the intialization make sure to replace all occurences of the example user name (`db_service`) with the username you created and used to create the database.
You need to change this in all the scripts. After this is done, you can run initialization scripts.

The initialization should be done in the following order.
* First add stored procedures from [here](resources/account-db/stored-procedures).

* Populate  database by running the scripts from [here](resources/account-db/init)

In order to add the account data the merchant needs to edit  the `/account-db/init/add_data.sql` script and addits own mnemonic and account details. This information is going to be encrypted in the database, so it is recomended that after the server has started you delete the content of these files.

All the MySQL DB scripts for setting up the MySQL database can be found [here](resources/account-db).
The merchant will need to add their encryption key to the configuration files inside the `init` folder, by executing the following SQL script:
```sql
call add_table_keys('ENCRYPTION_KEY_DEFINED_BY_MERCHANT');
```
In addition the merchants need to add their mnemonic phrase of their HD wallet.
Note that the mnemonicID should be the same as specified in the docker compose file, and represented in a form of a string.
```sql
CALL add_mnemonic('mnemonic_phrase_id', 'merchants hd wallet generated twelve word mnemonic phrase should be placed here', 'ENCRYPTION_KEY_DEFINED_BY_MERCHANT');
```

#### Setting up the Redis instance
Merchant backend needs to connect to a Redis instance through the host and port provided in the docker-compose file  (`REDIS_PORT` and `REDIS_HOST`).
The instance can be either created on the same server as the Node server, or on a different server instance.
Recommended approach is to have all the different tiers running on a separate servers, which means ideally Redis would start on a server that is opened to the server on which the
Node project is running.

#### Start docker containers
Once the merchant backend system and all configurations are in place you can start the nodeJS server, which will start and automatically download all of the missing dependencies
```
# Start the node js server
docker-compose up -d
# Check the logs of the running containers
docker-compose logs -f
# Stop and remove the running containers
docker-compose down
```
More commands for docker and docker-compose can be found [here](https://docs.docker.com/compose/reference/)

#### Server Details
Your merchant backend server is now running on `http:localhost:3000`

You can check all the available APIs on `http:localhost:3000/api/v2/doc/api/#`



The complete PumaPay API V2 calls documentation <a href="assets/PumaPayMerchantBackendAPIGuide.pdf" target="_blank">here</a> and the swagger version of it <a href="https://prembackend.pumapay.io/api/v2/doc/api/#" target="_blank">here</a>.

Extended integration guide can be found [here](https://pumapay.io/docs/Merchant-Integration-Guide-1.pdf).

# PumaPay Pull Payment Protocol Wiki
The PumaPay Pull Payment protocol allows allows recurring payment to occur over the Ethereum Blockchain.

## Table of content
- [Ecosystem Components](#ecosystem-components)
    - [PumaPay Core](#pumapay-core)
    - [PumaPay SDK](#pumapay-sdk)
    - [PumaPay Merchant Backend](#pumapay-merchant-backend)
    - [PumaPay Wallet](#pumapay-wallet)
    - [PumaPay Faucet](#pumapay-faucet)
- [Blockchain Components](#blockchain-components)
    - [PumaPay Token](#pumapay-token)
    - [PumaPay Pull Payment](#pumapay-pull-payment)
- [Merchant Backend](#merchant-backend)
    - [NodeJS](#nodejs)
    - [PostgreSQL Database](#postgresql-database)
    - [MySQL Database](#mysql-database)
    - [Redis](#redis)
- [Merchant Integration Guide](#merchant-integration-guide)
    - [Register with PumaPay as trusted merchant](#register-with-pumapay-as-trusted-merchant)
    - [Setting up NodeJS Server](#setting-up-nodejs-server)
    - [Setting up PostgreSQL Database](#setting-up-postgresql-database)
    - [Setting up MySQL Database](#setting-up-mysql-database)


## Ecosystem Components
### PumaPay Core
The core is our custom framework and heart of our system.
Our PumaPay Core allows the governance, control and utilisation of our pull payment protocol.
### PumaPay SDK
The SDK module gives functionality to any third party integrator to allow execution of pull payments.
### PumaPay Merchant Backend
The Merchant backend consists of a set of APIs that the merchant can use to connect to the rest of the
PumaPay ecosystem.
### PumaPay Wallet
Wallet allows users who possess PMA to make pull payments with merchants that have registered and are using the
PumaPay pull payment protocol.
### PumaPay Faucet
The faucet is a component that provides test PMA tokens to development users, so that they can test their pull payments
after they have integrated with the PumaPay ecosytem. It essentially drip feeds the tokens to users so that
they have a source of tokens for testing purposes. These test tokens enable testnet users to play with and test the execution
of their pull payment models on the testnet.
You can find the PMA faucet [here](https://faucet.pumapay.io/).

## Blockchain Components
### PumaPay Token
The [PumaPay token](https://github.com/pumapayio/pumapay-token/blob/master/contracts/PumaPayToken.sol) is based on
the [ERC-20 Token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) developed in Solidity
and deployed on the Ethereum network on our TGE which occurred on May 7th 2018.
### PumaPay Pull Payment
The PumaPay Pull Payment Protocol supports an advanced "pull" mechanism, which allows users to not only push
tokens from one wallet to another but to also pull funds from other wallets after prior authorization has been given.

Our Pull Payment Protocol currently supports a variety of payment models such as:
* Single Pull Payment
* Recurring Pull Payment (Fixed amount)
* Recurring Pull Payment with initial payment
* Recurring Pull Payment with trial period
* Recurring Pull Payment with initial payment and trial period

The first version of our protocol has a semi-decentralized approach in order to reduce the gas fees that are
involved with setting the PMA/Fiat rates on the blockchain and eliminate the customer costs for registering and
cancelling pull payments, which are currently taken care of by PumaPay through the smart contract.

You can find detailed description of the smart contracts utilizing the pull payment protocol [here](https://github.com/pumapayio/pumapay-token/).

## PumaPay Wallet
Sign Pull Payment retrieved by the merchant in the form of QR code.

## Merchant Backend
The v2.0 of the PumaPay pull payment protocol on the merchant side consists of a set of APIs that the merchant
can use to connect to the rest of the PumaPay ecosystem.
All the relevant functionality is provided by the PumaPay [merchant SDK](https://github.com/pumapayio/merchant.sdk).

### NodeJS
The NodeJS server uses the merchant SDK as a singleton and provides a list of API that are used to write their own
pull payment models, to register the pull payments of their customers as well as executing and to monitor the
blockchain transactions related with the pull payments.

### PostgreSQL Database
The PostgreSQL database stores the pull payment models, the pull payments and the Ethereum transactions.
<!--DB model to be provided-->
![Merchant Backend Database](MerchantBackendDB.png)

### MySQL Database
MySQL database is an encrypted database used for encrypting the HD wallet with the Ethereum addresses that the merchant uses on their end
for executing pull payments on the blockchain, for funding the executor addresses with ETH to pay for gas and cashing
out PMA and ETH to a bank account on their end.

<!--More details regarding funding can be found [here](funding-eth) and for cashing [here](cashing-out-eth-and-pma).-->
<!--DB model to be provided-->

### Redis
Redis in-memory data structure store is used for storing information related to the executor address that will be
the executor of the pull payment and for storing the maximum gas used for a pull payment transaction.

<!--### Funding ETH-->

<!--### Cashing out ETH and PMA-->

## Merchant Integration Guide
#### Register with PumaPay as trusted merchant
The first thing that the merchant needs to do is to register through the PumaPay core APIs with the API call, possibly through Postman, in order to retrieve their
`API key` and their `merchantID` that is essential for setting up their NodeJS server.

[PumaPay Core API Documentation](https://stgcore.pumapay.io/core/api/v2/doc/api/#)

THe main core URL is [https://stgcore/pumapay.io/](https://stgcore/pumapay.io/):
1.	A merchant can register through `/api/v2/user/register` API call, added to the previous URL and by providing all the relevant details in the API calls body, as specified in the API documentation. On registration the merchant needs to verify the email address.

    *Please note, that specified password must have at least 1 uppercase letter, at least 1 lowercase, at least 1 number and at least 1 special character.*

2.	By using the email and password used for registration the merchant can login through `/api/v2/login/user` and
retrieve their `merchantID` and a JSON Web Token (JWT) among other details.
3.	 The JWT can be used for retrieving the API key from `api/v2/generate-api-key`.

**Important:** The `API key` and the `merchantID` **should be noted down** since they will be used later for
setting up the Merchant NodeJS server.


#### Setting up NodeJS Server
For setting up the NodeJS server, PumaPay has a docker image of the merchant backend that can be used for easy and
fast setup by the merchants.
1. Retrieve Merchant Backend Docker image
The docker image is currently in our private docker registry and verified merchants will be granted access.
Once registered you can request access by sending an email to developers@pumapay.io that includes your merchant ID.

Once granted access to the docker registry you can login and pull the docker image from there.
```
docker login
# use your credentials
docker-compose pull
```

Once you get the docker image you can modify the docker-compose file example that can be found in
our [GitHub](https://github.com/pumapayio/server-config-merchant/blob/master/docker-compose.example.yml).

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
All the PostgeSQL DB scripts for setting up the PostgreSQL database can be found [here](https://github.com/pumapayio/server-config-merchant/tree/master/resources/db).

The SQL scripts can run as provided but it is highly recommended that database user is changed according to the
PostgeSQL database that the merchant has setup.
Example:
```sql
ALTER TABLE public.tb_payment_status
    OWNER to local_user;
## Should change to
ALTER TABLE public.tb_payment_status
    OWNER to user_specified_in_docker_compose_file;
```

#### Setting up MySQL Database
All the MySQL DB scripts for setting up the MySQL database can be found [here](https://github.com/pumapayio/server-config-merchant/tree/master/resources/account-db), inside the `init` folder.
The merchant will need to add their encryption key by executing the following SQL script:
```sql
call add_table_keys('ENCRYPTION_KEY_DEFINED_BY_MERCHANT');
```
In addition the merchants need to add their mnemonic phrase of their HD wallet.
Note that the mnemonicID should be the same as specified in the docker compose file, and represented in a form of a string.
```sql
CALL add_mnemonic('mnemonic_phrase_id', 'merchants hd wallet generated twelve word mnemonic phrase should be placed here', 'ENCRYPTION_KEY_DEFINED_BY_MERCHANT');
```

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

**Note:** An ansible script which will ease the merchant backend setup is on the final stages of development and will be published soon 

#### Server Details
Your merchant backend server is now running on `http:localhost:3000`

You can check all the available APIs on `http:localhost:3000/api/v2/doc/api/#`

As well as the complete PumaPay API V2 calls documentation can be found [here](https://stgmbackend.pumapay.io/merchant/api/v2/doc/api/#/Pull%20Payment%20Models/post_api_v2_pull_payment_models_)




# Ethereum 2.0 setup

This repository provides a basic setup to run an [Ethereum 2.0](https://docs.ethhub.io/ethereum-roadmap/ethereum-2.0/eth-2.0-client-architecture/) Beacon node and Validator client with some monitoring on the side. _This is just a way to get a feel for how everything works together, a playground of sorts, in **no way is this a production ready setup**_

## Run it

Once you have [Docker Compose](https://docs.docker.com/compose/) installed, run
```bash
make createGrpcTlsKeys                          # Creates TLS keys for secure gRPC connections between beacon and validators
make createValidatorKey VALIDATOR_INSTANCE=1    # Creates a shard withdrawal and private key for validator 1, the password is "secret"
make createValidatorKey VALIDATOR_INSTANCE=2    # Creates a shard withdrawal and private key for validator 2, the password is "secret"
docker-compose up -d                            # Creates your environment
```

The beacon node will now start pulling in the beacon chain, this'll take a while. You can monitor the progress and get an estimation of when this is done by running `docker-compose logs -f beacon`.

Once the beacon node is up-to-date, the validator nodes can be initialized. The instructions were given when you executed `make createValidatorKey` above.

## Environment

The following containers will be started:
* **Beacon node**: starts pulling in the Ethereum beacon chain that is needed for the validator client. The beacond chaing will be persisted between restarts in `var/beacon`.
* **2 Validator clients**: the bread and butter of Ethereum 2.0, equivalent to a miner on Ethereum 1.0. The keystore will be persisted in `secrets/keystore-1` (and `-2`) and the validator database in `var/validator-1` (and `-2`).
* **cAdvisor**: Monitors resource usage on all the containers
* **InfluxDB**: Storage for monitoring data done by cAdvisor
* **Grafana**: Tool to make pretty graphs from the monitoring data in InfluxDB, exposed on port 3001, see section below for more details.

## Grafana

To get a feel for how many resources the nodes consume, you can go to [the system dashboard](http://localhost:3001/d/system/system?orgId=1). This dashboard can't be edited or deleted but you can create your own dashboards and they will be persisted between container restarts. The `default` data source is already configured to point to the InfluxDB container.

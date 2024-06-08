# quickstart-hashicorp-vault

This is a sample project to initialise a [HashiCorp Vault](https://www.vaultproject.io/) instance with a PKI Instance and generate some secrets that can be used by the ForgerRock Identity Platform.

It uses [HashiCorp Terraform](https://www.terraform.io/) to provision the PKI and secrets so that they can be quickly and easily rotated.

Secrets are generated in the `volumes/secrets` folder, but this can be easily changed to use Docker Volumes if required.

Config for both Vault and Terraform are initially baked into the container, but can be modified and attached without rebuilding as the folders are mounted to the running containers. Terraform state is also local, meaning you could rerun the Terraform plan from within a running container thus allowing quick and easy updates and testing without having to rebuid containers.

## Execution

The following describes how to run the sample.

### Vault Init

The following command will start a HashiCorp Vault instance and initiliase it so that you can enter the token in the [HashiCorp Vault UI](http://localhost:8200)

```console
docker-compose up qhcv-vault-init
```

returns

```console
qhcv-vault-init  | VAULT_TOKEN=hvs.w6DjJSVMZ72AEHExfStRU4tL
```

It also available via

```console
cat volumes/vault/keys.json | jq .root_token -r
```

returns

```console
hvs.w6DjJSVMZ72AEHExfStRU4tL
```

### Terraform Apply

The following command will perform a Terraform apply to the running HashiCorp Vault instance. It will grab and configure the `VAUL_TOKEN` from the value saved in the previous run.
**Note:** If HashiCorp Vault is not running it will start and initiliase it and that service will remaing running in the background.

```console
docker-compose run qhcv-terraform
```

The state file will be stored in the [`volumes/terraform`](volumes/terraform) folder and the secrets in the [`volumes/secrets`](volumes/secrets) folder.

### Shutdown and cleanup

To shutdown and cleanup issue the following (depending on OS)

```console
docker-compose down
rm -rf volumes
```

```powershell
docker-compose down
rm -r -force volumes
```

## Explanation

### Vault Config

The Vault container extends an existing HashiCorp Vault container to add

- [docker/vault/init/vault-init.sh](docker/vault/init/vault-init.sh)
- [docker/vault/config/vault-server.json](docker/vault/config/vault-server.json)
- [docker/vault/config/vault-agent.json](docker/vault/config/vault-agent.json)

The configs are basics to show how to get the solution running, but can be extended with your specific needs.

### Vault Init

The init script depends on HashiCorp running and checks to see if the Vault has been previously unsealed as the file [volumes/vault/keys.json](volumes/vault/keys.json). If it has not been unsealed it will issue a request to 

- initiliase the vault with a single `secret` and store the details in `keys.json`
- unseal the Vault, using that single `secret`.

**Note:** This is not a production solution as the secrets are not safely stored and should only be used for Local Development purposes. 

### Terraforms Config

The Vault container extends an existing HashiCorp Vault container to add

- Plugins needed to perform the management of the Vault and secrets.
- [docker/terraform/scripts/init-vault.sh](docker/terraform/scripts/init-vault.sh)

  Performs the core operations of the script.

- [docker/terraform/init/_terraform.tf](docker/terraform/init/_terraform.tf)

  Details about the required providers and their configuguration.

- [docker/terraform/init/certificate_clients.tf](docker/terraform/init/certificate_clients.tf)

    Configuration of any Client Certificates needed.

- [docker/terraform/init/certificates_tls.tf](docker/terraform/init/certificates_tls.tf)

Configuration of any TLS Certificates

- [docker/terraform/init/variables.tf](docker/terraform/init/variables.tf)

    Variables used in the plan.

- [docker/terraform/init/vault.tf](docker/terraform/init/vault.tf)

  The core Vault configuration of PKI
  It creates
  
  - Root Certificate Authority
  - Intermeddiate Certificate Authority 
  - Roles
  - Policies

When it runs it performs the 3 core tasks of using the Vault Token derived from `keys.json`

- `init`
- `plan`
- `apply --auto-approve`

The state files are stored in [`volumes/terraform`] (volumes/terraform)

It will also export the Root and Intermediatte certifcates into 

- [`volumes/secrets/qhcv_idam_root.pem`] (volumes/secrets/qhcv_idam_root.pem)
- [`volumes/secrets/qhcv_idam_intermediate.pem`] (volumes/secrets/qhcv_idam_intermediate.pem)

### Secrets

The Terraform plan will export secrets into [`volumes/secrets`] (volumes/secrets)

TLS Certicates are exported as `tls.crt` and `tls.key`.

Client certificates are exported as `.p12`

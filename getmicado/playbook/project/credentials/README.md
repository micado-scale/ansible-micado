## Credentials in MiCADO

### Sample files
The following sample credential files are provided:

#### MiCADO Credentials
`sample-credentials-micado.yml` : **MiCADO TLS and Dashboard Login**

#### Cloud Credentials or Other Authentication
`sample-credentials-cloud-api.yml` : **OpenStack, EC2, Azure, Oracle, CloudSigma, CloudBroker**

`sample-credentials-gce.json` : **Google Cloud Engine**

`sample-credentials-oci-key.pem` : **Oracle Private Key**

#### Docker Registry Credentials
`sample-credentials-docker-registry.yml` : **Private DockerHub or Registry**

### Usage

Remove the `sample-` prefix and fill with your credentials. 

```bash
mv sample-credentials-cloud-api.yml credentials-cloud-api.yml
edit credentials-cloud-api.yml
```

To avoid leaving credentials in plain text, we recommend using
Ansible Vault to encrypt them. If needed, you can still edit files
encrypted by Ansible Vault.

```bash
ansible-vault encrypt credentials-cloud-api.yml
ansible-vault edit credentials-cloud-api.yml
```

To use Ansible Vault encrypted files in a Playbook, pass the
`--ask-vault-pass` option on the command line.

```bash
ansible-playbook -i hosts.yml micado.yml --ask-vault-pass
```

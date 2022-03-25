# ansible-role-build-micado

Run this with _ansible-playbook -i hosts.yml micado.yml --tags build_ on a bare Ubuntu 18.04 or 20.04 LTS image to prepare it with all the libraries and images required for a MiCADO Master. Make sure the *micado* entry in the _hosts_ file is populated with the correct *ansible_host* (IP) and *ansible_user* (SSH username).
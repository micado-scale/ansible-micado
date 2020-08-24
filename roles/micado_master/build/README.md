# ansible-role-build-micado

Run this with _ansible-playbook -i hosts micado-master.yml --tags 'build'_ on a bare Ubuntu 16.04 LTS image to prepare it with all the libraries and images required for a MiCADO Master. Make sure the *micado-master* entry in the _hosts_ file is populated with the correct *ansible_host* (IP) and *ansible_user* (username).
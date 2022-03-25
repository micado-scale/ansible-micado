# ansible-role-micado-worker

Run this with _ansible-playbook -i hosts.yml worker.yml_ on a bare Ubuntu 16.04 LTS or Ubuntu 18.04 LTS image to prepare it with all the libraries and images required for a MiCADO Worker. Make sure the *micado* entry in the _hosts_ file is populated with the correct *ansible_host* (IP) and *ansible_user* (SSH username).
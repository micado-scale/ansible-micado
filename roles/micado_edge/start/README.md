# ansible-role-start-edge

Run this with _ansible-playbook -i hosts.yml edge.yml --tags start_ to configure an existing MiCADO Master as MiCADO-Edge ready. Make sure the *micado* entry in the _hosts_ file is populated with the correct *ansible_host* (IP) and *ansible_user* (SSH username).
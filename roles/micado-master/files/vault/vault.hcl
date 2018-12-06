# Listener address
listener "tcp" {
    address = "127.0.0.1:8200"

    # TLS configuration for listener
    tls_disable = 0
    tls_min_version = "tls12"
    tls_cert_file = ""
    tils_key_file = ""
}

# Vault built-in web UI
ui = false

# Vault log level. 
#Supported values (in order of detail) are "trace", "debug", "info", "warn", and "err". 
log_level = "info"

# Default is 768h
max_lease_ttl = "10h"

# Default is 768h. This value can't be bigger than 'max_lease_ttl'
default_lease_ttl = "10h"
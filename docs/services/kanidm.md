# Kanidm

## OAuth2 Clients

### oauth2-proxy

Used for authenticating web services via nginx reverse proxy.

```sh
# Create the OAuth2 client
kanidm system oauth2 create oauth2-proxy "OAuth2 Proxy" https://auth.shrimphouse.xyz

# Set the redirect URL
kanidm system oauth2 add-redirect-url oauth2-proxy https://auth.shrimphouse.xyz/oauth2/callback

# Use short usernames instead of SPN format
kanidm system oauth2 prefer-short-username oauth2-proxy

# Add scopes for all users
kanidm system oauth2 update-scope-map oauth2-proxy idm_all_persons openid email profile

# Retrieve the client secret (add to sops)
kanidm system oauth2 show-basic-secret oauth2-proxy
```

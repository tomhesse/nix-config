# Kanidm

## Upgrading

Kanidm requires a sequential version upgrade process. Before bumping the package version:

1. Run the upgrade check on the server to verify readiness:

   ```sh
   sudo $(systemctl cat kanidm | grep -oP 'ExecStart=\K\S+') domain upgrade-check
   ```

2. Ensure the output shows `status: PASS`.

3. Update `package` in `modules/kanidm.nix` to the next version (e.g. `pkgs.kanidm_1_10`).

4. Rebuild and restart the service. The domain level will be raised automatically on startup.

See the [upstream upgrade guide](https://kanidm.github.io/kanidm/master/server_updates.html) for version-specific notes.

## People

```sh
# Create a person account
kanidm person create <username> "<Display Name>"

# Set email and legal name
kanidm person update <username> --mail "<email>" --legalname "<Legal Name>"

# Have the user set up credentials (generates an enrollment link)
kanidm person credential create-reset-token <username>
```

Requires membership in `idm_people_admins` (which `idm_admin` has by default).

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

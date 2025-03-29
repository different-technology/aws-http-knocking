# Call endpoint
Endpoint: `https://domain.com/base-path/open`<br>
Method: GET

# Development

## Use right node version
```console
nvm use
```

## Watcher
```console
npx tsc --watch
```
## Run
### Open Firewall
```console
export AWS_PROFILE=dt
export securityGroupId=sg-096c2d60
export openPort=22
node Main.js openFirewall 192.168.0.1
```
### Cleanup Firewall
```console
export AWS_PROFILE=dt
export securityGroupId=sg-096c2d60
node Main.js cleanupFirewall
```

## Build
```console
scripts/build.sh
```

## Deploy infrastructure
#### Prepare
```console
cd infrastructure
terraform init
```
#### Apply
```console
export AWS_PROFILE=dt
terraform apply
```

## Deploy lambda app
```console
export AWS_PROFILE=dt
scripts/deploy.sh
```

## Update node version
1. Use latest LTS version
   ```console
   nvm install --lts
   ```
2. Update node version in [.nvmrc](.nvmrc)
3. Update npm packages
   ```console
   npm install @types/node@latest
   npm install @aws-sdk/client-ec2@latest
   ```
4. Check functions
5. Update node version in infrastructure

# Call endpoint
Endpoint: `https://domain.com/base-path/open`<br>
Method: GET

# Development
## Watcher
```console
tsc --watch
```
## Run
```console
export AWS_PROFILE=dt
node Main.js openFirewall 192.168.0.1
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

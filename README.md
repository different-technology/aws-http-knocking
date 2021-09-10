# AWS HTTP Knocking
This repository provides terraform modules for an HTTP Knocking mechanism
for AWS security groups (firewalls).<br>
It's a cloud-based serverless alternative to port knocking.<br>

#### Idea
Before connecting to a non-public service, hosted on AWS
(e.g. SSH, Remote Desktop, ... - on an EC2 instance)
_which is disabled by the firewall (= AWS security group)_
we do something like a port knocking.<br>
By requesting a specific URL with an HTTP GET request,
the Lambda function will add an inbound rule to the security group
and grant access for the requesting IP and a defined port.<br>
A second Lambda is called regularly by CloudWatch
to remove all inbound rules for the defined port.<br>
<br>
Notice: HTTP Knocking is of course just an (optional) second factor for an authentication.<br>
! A primary authentication method is always required !


## Module: api_gateway_open_firewall
This module provides an API Gateway for REST calls to open the firewall.

#### Example
GET request to the API:<br>
<br>
Endpoint: `https://domain.com/base-path/open`
<br>
Method: GET


## Module: firewall_open
This module provides the Lambda infrastructure to open the firewall.

## Module: firewall_cleanup
This module provides the CloudWatch & Lambda infrastructure to close the firewall regularly.



## Development

### Deploy infrastructure
Install https://github.com/tfutils/tfenv

#### Prepare
```console
tfenv install
```

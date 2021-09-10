import {EC2} from "aws-sdk";
import {DescribeSecurityGroupsResult, IpPermission, SecurityGroup} from "aws-sdk/clients/ec2";

const AWS = require('aws-sdk');
AWS.config.update({region:'eu-central-1'});

export class FirewallController {
  private readonly ec2 = new AWS.EC2();

  async openFirewall(securityGroupId: string, ip: string, port: number) {
    console.info('Start "openFirewall" method for ip "' + ip + '"');
    let message = '';

    try {
      await this.ec2.authorizeSecurityGroupIngress({
        'GroupId': securityGroupId,
        'IpPermissions': [
          {
            'FromPort': port,
            'ToPort': port,
            'IpProtocol': 'tcp',
            'IpRanges': [
              {
                'CidrIp': ip + '/32',
                'Description': 'Auto generated from Lambda at ' + (new Date()).toUTCString()
              }
            ]
          }
        ]
      }).promise();
      message = 'addedIpToFirewall';
    } catch (e) {
      if (e.code === 'InvalidPermission.Duplicate') {
        message = 'noChangeDone';
      } else {
        throw e;
      }
    }

    return {
      message: message,
      sourceIp: ip
    };
  }

  async removeAllFirewallRules(securityGroupId: string) {
    console.info('Start "removeAllFirewallRules" method for security group "' + securityGroupId + '"');
    let securityGroup: SecurityGroup = await this.getSecurityGroup(securityGroupId);
    let counter: number = 0;
    for (const ipPermission of securityGroup.IpPermissions) {
      delete ipPermission.UserIdGroupPairs;
      delete ipPermission.PrefixListIds;
      delete ipPermission.Ipv6Ranges;

      try {
        await this.ec2.revokeSecurityGroupIngress({
          GroupId: securityGroupId,
          IpPermissions: [ipPermission]
        }).promise();
        counter++;
      } catch (e) {
        console.error(e);
      }
    }

    return {
      message: 'Removed ' + counter + ' firewall rules'
    };
  }

  async getSecurityGroup(securityGroupId: string): Promise<SecurityGroup> {
    console.info('Start "getSecurityGroup" method for security group "' + securityGroupId + '"');
    let result: DescribeSecurityGroupsResult = await this.ec2.describeSecurityGroups({
      'GroupIds': [securityGroupId]
    }).promise();
    return result.SecurityGroups[0];
  }

}

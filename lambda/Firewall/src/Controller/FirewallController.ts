import {EC2Client, AuthorizeSecurityGroupIngressCommand, DescribeSecurityGroupsCommand, DescribeSecurityGroupsResult, RevokeSecurityGroupIngressCommand, IpPermission, SecurityGroup} from "@aws-sdk/client-ec2";

export class FirewallController {
  private readonly ec2 = new EC2Client({ region: "eu-central-1" });
  private readonly descriptionPrefix = "Auto generated from Lambda at ";

  async openFirewall(securityGroupId: string, ip: string, port: number) {
    console.info('Start "openFirewall" method for ip "' + ip + '"');
    let message = '';

    try {
      const command = new AuthorizeSecurityGroupIngressCommand({
        GroupId: securityGroupId,
        IpPermissions: [
          {
            FromPort: port,
            ToPort: port,
            IpProtocol: 'tcp',
            IpRanges: [
              {
                CidrIp: ip + '/32',
                Description: this.descriptionPrefix + (new Date()).toUTCString()
              }
            ]
          }
        ]
      });
      await this.ec2.send(command);
      message = 'addedIpToFirewall';
    } catch (e) {
      if (e.Code === 'InvalidPermission.Duplicate') {
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

  async removeAllTaggedFirewallRules(securityGroupId: string) {
    console.info('Start "removeAllFirewallRules" method for security group "' + securityGroupId + '"');
    let securityGroup: SecurityGroup = await this.getSecurityGroup(securityGroupId);
    let counter: number = 0;
    for (const ipPermission of securityGroup.IpPermissions) {
      for (const ipRange of ipPermission.IpRanges) {
        if (ipRange.Description !== undefined && ipRange.Description.startsWith(this.descriptionPrefix)) {
          const command = new RevokeSecurityGroupIngressCommand({
            GroupId: securityGroupId,
            IpPermissions: [
              {
                IpProtocol: ipPermission.IpProtocol,
                FromPort: ipPermission.FromPort,
                ToPort: ipPermission.ToPort,
                IpRanges: [
                  {
                    CidrIp: ipRange.CidrIp,
                  }
                ]
              }
            ]
          });
          try {
            await this.ec2.send(command);
            counter++;
          } catch (e) {
            console.error(e);
          }
        }
      }
    }

    return {
      message: 'Removed ' + counter + ' firewall rule(s)'
    };
  }

  async getSecurityGroup(securityGroupId: string): Promise<SecurityGroup> {
    console.info('Start "getSecurityGroup" method for security group "' + securityGroupId + '"');
    const command = new DescribeSecurityGroupsCommand({
      'GroupIds': [securityGroupId]
    });
    const response: DescribeSecurityGroupsResult = await this.ec2.send(command);
    return response.SecurityGroups[0];
  }

}

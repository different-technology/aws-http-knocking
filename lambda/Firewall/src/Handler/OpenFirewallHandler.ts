import { FirewallController } from "../Controller/FirewallController";

/**
 * Handler to run checks with AWS Lambda
 * @param event
 * @param context
 * @param callback
 */
export const handler =  async (event: {requestContext: {identity: {sourceIp: string}}; }, context: any, callback: (arg0: any, arg1: any) => void): Promise<any> => {
  let sourceIp = event.requestContext.identity.sourceIp;
  let result = await (new FirewallController()).openFirewall(process.env.securityGroupId, sourceIp, Number(process.env.openPort));

  const response = {
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Origin" : "*"
    },
    body: JSON.stringify(result)
  };
  console.info(response);
  callback(null, response);
};

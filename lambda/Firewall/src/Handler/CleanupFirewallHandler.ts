import {FirewallController} from "../Controller/FirewallController";

/**
 * Handler to run cleanup with AWS Lambda
 * @param event
 * @param context
 * @param callback
 */
export const handler =  async (event: any, context: any, callback: (arg0: any, arg1: any) => void): Promise<any> => {
  let result = await (new FirewallController()).removeAllFirewallRules(process.env.securityGroupId);

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

import { handler as openFirewallHandler } from "./src/Handler/OpenFirewallHandler";
import { handler as cleanupFirewallHandler } from "./src/Handler/CleanupFirewallHandler";

/**
 * Main file for execute test on command line.
 * First parameter: api (e.g. shutter)
 * Second parameter (optional)
 * Third parameter (optional)
 *
 * Example:
 * node Main.js openFirewall 192.168.0.1
 */

const args = process.argv.slice(2);

switch (args[0]) {
  case 'openFirewall':
    openFirewallHandler(
      {requestContext: {identity: {sourceIp: args[1]}}},
      null,
      function (arg0, arg1) {
      }
    );
    break;
  case 'cleanupFirewall':
    cleanupFirewallHandler(
      {},
      null,
      function (arg0, arg1) {
      }
    );
    break;
  default:
    console.log('Command not found');
    break;
}

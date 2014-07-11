#!/usr/bin/env node
var mdns = require('mdns'),
  ddcNodes = { /*name: {adresses: ['192.168.0.24', 'fe80::0:18'], port: 10001}}*/ };

var mdnsBrowser = mdns.createBrowser(mdns.udp('ddc'));

mdnsBrowser.on('serviceUp', function(service) {
  // ignore duplicate ups
  if(ddcNodes[service.name]) return;

  ddcNodes[service.name] = {'addresses': service.addresses, 'port': service.port};
  var cnt = Object.keys(ddcNodes).length;

  console.log('ddc device "'+service.name+' up at '+service.addresses[0]+':'+service.port+', now '+cnt+' devices on the net');
});

mdnsBrowser.on('serviceDown', function(service) {
  // ignore duplicate downs
  if(!ddcNodes[service.name]) return;

  var device = ddcNodes[service.name];

  delete ddcNodes[service.name];
  var cnt = Object.keys(ddcNodes).length;

  console.log('ddc device "'+service.name+' up at '+device.addresses[0]+':'+device.port+', now '+cnt+' devices on the net');
});

console.log('listening for ddc nodes on the network')
mdnsBrowser.start();
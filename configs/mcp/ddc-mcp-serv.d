[Service]
ExecStart=/usr/bin/node /root/bone/javascripts/mixpanel-ddc/index.js
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=ddc-mcp-serv
User=root
Group=root
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
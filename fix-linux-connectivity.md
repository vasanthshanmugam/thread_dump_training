For Azure:
Go to your VM in the Azure Portal.

Under Networking, click Add inbound port rule.

Set:
Port: 8080
Protocol: TCP
Source: Any (or restrict to your IP)
Action: Allow

For AWS EC2:
Go to Security Groups.
Add an Inbound Rule:
Type: Custom TCP
Port Range: 8080
Source: Anywhere (or your IP)

sudo firewall-cmd --list-all
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

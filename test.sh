#!/bin/bash
curl https://raw.githubusercontent.com/anaer/Sub/main/clash.yaml > clash.config.yaml || exit 1
BUGSNI="graph.facebook.com"
#BUGCDNOPOK="104.26.4.192"  #bug opok
BUGCDNGAME="104.18.24.176"
BUGCDNOPOK="104.22.28.102"  #bug opok
BUGCDN="104.21.69.223"  #bug sushiroll
sed '/^proxy\-groups/,$d' clash.config.yaml > cutted
csplit -z cutted /^-/ '{*}'
#grep -l type\:\ vmess xx* > allvmess
grep -ril 'port: 443' xx* | xargs  grep -il 'type: vmess' | xargs  grep -il 'network: ws'| xargs  grep -il 'path:' > allvmesssni
grep -ril 'port: 80' xx* | xargs  grep -il 'type: vmess' | xargs  grep -il 'network: ws'| xargs  grep -il 'Host:' > allvmesscdn
grep -l type\:\ trojan xx* > alltrojan
echo -ne "proxies:" > vpnTrojan.yaml.txt
echo -ne "proxies:" > vpnVmess.yaml.txt
echo -ne "proxies:" > vpnVmess-cdn.yaml.txt
#echo "proxies:" > vpnTrojan-cdn.yaml.txt

echo "Please wait."

# Trojan SNI
while IFS= read -r line
do
	# That tr is removing everything except a-Z, i think
	trojanName=$(grep name ./$line | sed s/.*\:.// | tr -cd '\11\12\15\70-\176')
	trojanPass=$(grep password ./$line | sed s/.*\:.//)
	trojanServer=$(grep server ./$line | sed s/.*\:.//)
	echo -ne "
- name: "$trojanName\-$line"
  password: "$trojanPass"
  port: 443
  server: "$trojanServer"
  skip-cert-verify: true
  sni: "$BUGSNI"
  type: trojan" >> ./vpnTrojan.yaml.txt
done < ./alltrojan

echo "Trojan SNI done."

# Vmess SNI
while IFS= read -r line
do
	vmessName=$(grep \ name\: ./$line | sed s/.*\:.// | tr -cd '\11\12\15\70-\176')
	vmessServer=$(grep server\: ./$line | sed s/.*\:.//)
	vmessUuid=$(grep uuid\: ./$line | sed s/.*\:.//)
	vmessPath=$(grep path\: ./$line | sed s/.*\:.//)
	vmessAltId=$(grep alterId\: ./$line | sed s/.*\:.//)
	echo -ne "
- alterId: "$vmessAltId"
  cipher: auto
  name: "$vmessName\-$line"
  network: ws
  port: 443
  server: "$vmessServer"
  skip-cert-verify: true
  tls: true
  type: vmess
  uuid: "$vmessUuid"
  ws-opts:
    path: "$vmessPath"
    headers:
      host: "$BUGSNI"
  servername: "$BUGSNI"
  udp: true" >> ./vpnVmess.yaml.txt
done < ./allvmesssni

echo "Vmess SNI done."

# Vmess CDN
while IFS= read -r line
do
	vmesscdnName=$(grep \ name\: ./$line | sed s/.*\:.// | tr -cd '\11\12\15\70-\176')
	vmesscdnHost=$(grep -i Host\: ./$line | sed s/.*\:.//)
	vmesscdnUuid=$(grep uuid\: ./$line | sed s/.*\:.//)
	vmesscdnPath=$(grep path\: ./$line | sed s/.*\:.//)
	vmesscdnAltId=$(grep alterId\: ./$line | sed s/.*\:.//)
	echo -ne "
- alterId: "$vmesscdnAltId"
  cipher: auto
  name: "$vmesscdnName-$line"
  network: ws
  port: 80
  server: "$BUGCDN"
  skip-cert-verify: true
  tls: false
  type: vmess
  udp: true
  uuid: "$vmesscdnUuid"
  ws-opts:
    headers:
      Host: "$vmesscdnHost"
    path: "$vmesscdnPath"" >> ./vpnVmess-cdn.yaml.txt
done < ./allvmesscdn

echo "Vmess CDN done."

cp ./vpnVmess-cdn.yaml.txt ./vpnVmess-cdn-opok.yaml.txt
sed -i "/server\:/c\  server: $BUGCDNOPOK" ./vpnVmess-cdn-opok.yaml.txt
cp ./vpnVmess-cdn.yaml.txt ./vpnVmess-cdn-game.yaml.txt
sed -i "/server\:/c\  server: $BUGCDNGAME" ./vpnVmess-cdn-game.yaml.txt

echo -e "Removing garbage\r"
rm ./allvmesssni ./alltrojan ./cutted ./xx*
echo "All done."

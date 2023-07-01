#!/bin/bash
#curl -O https://raw.githubusercontent.com/tbbatbb/Proxy/master/dist/clash.config.yaml
curl -O https://raw.githubusercontent.com/WilliamStar007/ClashX-V2Ray-TopFreeProxy/main/combine/clash.config.yaml
BUGSNI="graph.facebook.com"
#BUGCDN="104.26.4.192"  #bug opok
BUGCDN="104.21.69.223"  #bug sushiroll
sed '/^proxy\-groups/,$d' clash.config.yaml > cutted
csplit -z cutted /^-/ '{*}'
grep -l type\:\ vmess xx* > allvmess
grep -l type\:\ trojan xx* > alltrojan
echo "proxies:" > vpnTrojan.yaml.txt
echo "proxies:" > vpnVmess.yaml.txt
echo "proxies:" > vpnVmess-cdn.yaml.txt

# Trojan SNI
while IFS= read -r line
do
#	sed -i "/name/c\- name: $line" ./$line
	if grep -q sni "./$line";then
		sed -i "/sni/c\  sni: $BUGSNI" ./$line
	else
		echo "  sni: $BUGSNI" >> ./$line
	fi
	cat ./$line >> vpnTrojan.yaml.txt
done < ./alltrojan

# Vmess SNI port 443
while IFS= read -r line
do
#	sed -i "/name/c\  name: $line" ./$line
#	if grep -q "\port\:\ 80\b" "./$line" && grep -q "ws\-opts" "./$line" && grep -q "host\:" "./$line";then
	if grep -q "\port\:\ 443\b" "./$line" && grep -q "\network\:\ ws\b" "./$line";then
		echo "$line is bner"
		WSPATH=$(grep ws\-path $line | sed 's/ws\-path/path/g')
		sed -i "/ws\-path\:/c\\" ./$line
		if grep -q "ws\-headers" "./$line";then
			sed -i "/ws\-headers\:/c\\" ./$line
			sed -i "/Host\:/c\\" ./$line
		fi
		if grep -q "ws\-opts" "./$line";then
			:
		else
			echo "  ws-opts:" >> ./$line
			echo "  $WSPATH" >> ./$line
		fi
		if grep -i -q "\host\:" "./$line";then
			sed -i "/[Hh]ost\:/c\      host: $BUGSNI" ./$line
		else
			echo "    headers:" >> ./$line
			echo "      host: $BUGSNI" >> ./$line
		fi
		if grep -q "servername" ./$line;then
			sed -i "/servername/c\  servername: $BUGSNI" ./$line
		else
			echo "  servername: $BUGSNI" >> ./$line
		fi
#		sed -i "/server\:/c\  server: $bug" ./$line
		if grep -q "\udp\:" ./$line;then
			sed -i "/udp/c\  udp: true" ./$line
		else
			echo "  udp: true" >> ./$line
		fi
		cat ./$line >> vpnVmess.yaml.txt
	else
		echo "$line dihapus"
	fi
done < ./allvmess
# When i want cdn port 443, without it, the 443 cdn will also contain SNI
#rm xx* 
#csplit -z cutted /^-/ '{*}'

# Vmess CDN port 80
while IFS= read -r line
do
	if grep -q "\port\:\ 80\b" "./$line" && grep -q "\network\:\ ws\b" "./$line" && grep -qG "server\:.*[A-z]$" "./$line";then
		echo "hehe"
		sed -i "/server\:/c\  server: $BUGCDN" ./$line
		cat ./$line >> vpnVmess-cdn.yaml.txt
	fi
done < ./allvmess
rm xx* cutted alltrojan allvmess clash.config.yaml

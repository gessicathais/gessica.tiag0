#!/bin/bash

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root!"
   exit 1
fi

if [ ! -e "/etc/linuxmint/info" ]; then
    echo "Maquina Linux fora do padrao"
    exit 1
fi



versaoMint=$(cat /etc/linuxmint/info | grep 'RELEASE=' | cut -d'=' -f2 | head -1)
if [ "$versaoMint" = "18.3" ]; then
   if [ -e /opt/mstech/updatemanager.jar ]; then
      echo "Tentando baixar pacotes do C3 ..."
      cd /tmp
      ping -c1 -w2 -q 172.16.0.1
      if [ $? -eq 0 ]; then
         /usr/bin/wget http://172.16.0.1:65432/updates/atom-paramint183_2022-06-20_10-48-49.sh
         /usr/bin/wget http://172.16.0.1:65432/updates/vscode159-paramint183_2022-06-13_10-40-25.sh
      fi
      #mesmo q tenha vscode, baixar pra alocar traducoes pra convidado
      /usr/bin/wget -c www.labmovel.seed.pr.gov.br/Updates/vscode159-paramint183_2022-06-13_10-40-25.sh
      bash vscode159-paramint183_2022-06-13_10-40-25.sh
      /usr/bin/wget -c www.labmovel.seed.pr.gov.br/Updates/atom-paramint183_2022-06-20_10-48-49.sh
      bash atom-paramint183_2022-06-20_10-48-49.sh
      if [ $? -eq 0 ]; then
         echo "instalou ok o Atom;"
      else
         echo -e "\e[1;31m Algum erro ocorreu!\e[0m"
      fi
      exit
   fi
fi
echo "Nao é Netbook Verde! Baixando arquivo especifico entao..."
#www.labmovel.seed.pr.gov.br/Updates/atom-paramint183_2022-06-20_10-48-49.sh

export deuRedePrdSerah=''
function estahNaRedePRD() {
    if [ -x /usr/bin/dig ]; then
        for ip in $(dig +short prdproxy.prd); do
            # Se ip tipo 10.175 daeh ping em 2 deles
            tmpIp=$(echo "$ip" | sed 's/^10.175.//')
            if [[ "$ip" != "$tmpIp" ]]; then
                #echo "IP prd"
                ping -c1 -w2 "$ip" >> /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    if [[ "$deuRedePrdSerah" = "simsim" ]]; then
                        break
                    else
                        export deuRedePrdSerah="sim$deuRedePrdSerah"
                    fi
                fi
            fi
        done
    else
       ping -c1 -w2 10.175.253.31 >> /dev/null 2>&1
       if [ $? -eq 0 ]; then
          # assumindo super raridade de rede particular ter uso deste ip prd
          export deuRedePrdSerah='sim'
       fi

       ping -c1 -w2 10.175.253.40 >> /dev/null 2>&1
       if [ $? -eq 0 ]; then
          # assumindo super raridade de rede particular ter uso deste ip prd
          export deuRedePrdSerah="sim$deuRedePrdSerah"
       fi
    fi
}
estahNaRedePRD
if [[ "$deuRedePrdSerah" = "simsim" ]]; then
   echo "na rede do Estado;"
   export http_proxy=http://prdproxy.prd:8080
else
   echo "em rede particular;"
fi

cd /tmp/
if [ -e "atom-vscode.sh" ]; then
   mv atom-vscode.sh atom-vscode.sh$$
fi
wget jonilso.com/atom-vscode.sh
bash atom-vscode.sh




#!/bin/bash
#
# Renan Santos
# Automação menu
#data: 8/11/2023
.
shopt -s -o nounset
#variavel DNS
conf_default="/etc/bind/named.conf.default-zones"
dir_dns="/etc/bind"
loop=true
ip_fixo="0"
#Variaveis GITHUB
caminho_do_projeto="/var/www/html/Exemplo-2-CSS"
link_do_projeto="https://github.com/vitor-ext/Exemplo-2-CSS.git"
page_name="Exemplo-2-CSS"
copia_dos_arquivos="style.css', 'imagens', 'index.html', 'README.md'"

menu() {
    xMenu="continuar"
    while [ "$xMenu" == "continuar" ]; do
        echo "Bem-vindo ao nosso script shell"
        echo "/--------------------/Menu/------------------/"
        echo "[1 - Menu WEB]"
        echo "[2 - Menu DNS]"
        echo "[3 - Menu DHCP]"
        echo "[4 - Menu EMAIL]"
        echo "[5 - Sair do script]"

        read -p "Escolha uma opção: " choice

        case $choice in
        1)
            server
            ;;
        2)
            dns
            ;;
        3)
            dhcp
            ;;
        4)
            email
        ;;
        5)
            xMenu="false"
            ;;
        *)
            echo "Opção inválida, tente novamente."
            ;;
        esac
    done
}

server() {
    xServer="continuar"
    while [ "$xServer" == "continuar" ]; do
        echo "[- Bem-vindo ao menu Servidor WEB (APACHE)]"
        echo "[1 - Instalar]"
        echo "[2 - Desinstalar]"
        echo "[3 - Verificar status]"
        echo "[4 - Git Hub]"
        echo "[5 - Voltar ao menu principal]"

        read -p "Escolha uma opção: " choice

        case $choice in
        1)
        if ! command -v apache2; then 
            echo "Serviço não instalado...."
            echo "Instalando Serviço..."
            apt-get install apache2 -y
            sleep 3
            clear
            echo "Serviço Instalado"
        else
            echo "Serviço ja Instalado!!!"
        fi 
            ;;
        2)
            echo "Desinstalando Serviço..."
            apt-get purge apache2 -y
            sleep 2
            clear
            echo "Serviço Desinstalado"
            ;;
        3)
            systemctl status apache2
            sleep 2
            echo "Status Verificado!!"
            ;;
        4)
        echo "Iniciando Serviço Git..."
            if ! command -v git; then
                echo "Git Hub não Instalado..."
                echo "Iniciando Instalação..."
                apt-get install git -y
                sleep 2
            else
                echo "Git Já instalado"
            fi
            echo "clonando repositorio..."
            git clone $link_do_projeto
            sleep 1
            cp -rfp $page_name/* $caminho_do_projeto
            sleep 1
           
            ;;
        5) 
        
        xServer="false"
        ;;
        *)
            echo "Opção inválida, tente novamente."
            ;;
        esac
    done
}

dns() {
    xDns="continuar"
    while [ "$xDns" == "continuar" ]; do
        echo "Bem-vindo ao menu DNS"
        echo "[1 - Instalar]"
        echo "[2 - Desinstalar]"
        echo "[3 - Adicionar zona e configurar DNS]"
        echo "[4 - Verificar status]"
        echo "[5 - Iniciar Serviço]"
        echo "[6 - Parar Serviço]"
        echo "[7 - Reiniciar Serviço]"
        echo "[8 - Voltar ao menu Principal]"

        read -p "Escolha uma opção: " choice

        case $choice in
        1)
        if ! command -v bind9; then
            echo "Serviço não instalado..."
            echo "Instalando Serviço..."
            apt-get install bind9 -y
            sleep 2
            clear
            echo "Serviço Instalado com Sucesso!!!"
        else
            echo "Serviço Já Instalado!!!"
        fi
            ;;
        2)
            echo "Desinstalando Serviço..."
            apt-get purge bind9 -y
            sleep 2
            clear
            echo "Serviço Desinstalado com Sucesso!!!!"
            ;;
        3)
            while [[ loop==true ]]; do
            echo "Iniciando configuralção do DNS..."
            sleep 2
                echo "Zona que deseja colocar:*"
                read zone
                echo "Final da zona que deseja colocar:* (.local, .com, ...)"
                read end
                # Configurando zona no named.conf.default-zones
                zona_completa="$zone$end"
                zona_local="$dir_dns/db.$zone"
                {
                    echo "zone @" {
                    echo "      type master;"
                    echo "      file =;"
                    echo -e "};\n"

                    sed -i 's/@/"x"/g' $conf_default
                    sed -i "s|x|$zona_completa|g" $conf_default
                    sed -i 's/=/"+"/g' $conf_default
                    sed -i "s|+|$zona_local|g" $conf_default

                } >>"$conf_default"

                echo "Início da zona que seja colocar:* (www, ns1, ...)"
                read start
                echo "Ip do serviço associado a esse início da zona:* "
                read ip_service

                # Criando db. e configurando
                localhost="ns1.$zone"
                touch "$zona_local"
                {
                    echo -e "; BIND reverse data file for empty rfc1918 zone\n;\n; DO NOT EDIT THIS FILE - it is used for multiple zones.\n; Instead, copy it, edit named.conf, and use that copy.\n;\n=TTL	86400\n@	IN	SOA	localhost. root.localhost. (\n			      1		; Serial\n			 604800		; Refresh\n			  86400		; Retry\n			2419200		; Expire\n			  86400 )	; Negative Cache TTL\n;\n@	IN	NS	localhost."
                    echo "$start	IN	A	$ip_service"
                    sed -i "s|=|$|" "$dir_dns/db.$zone"
                    sed -i "s|localhost|$localhost|g" "$dir_dns/db.$zone"
                } >>"$dir_dns/db.$zone"

                echo "Deseja adicionar mais um início de zona? (S / N)"
                read verificar
                while [[ "$verificar" == "S" || "$verificar" == "s" ]]; do
                    echo "Início da zona que seja colocar:* (www, ns1, ...)"
                    read start
                    echo "Ip do serviço associado a esse início da zona:* "
                    read ip_service
                    {
                        echo "$start	IN	A	$ip_service"
                    } >>"$dir_dns/db.$zone"

                    echo "Deseja adicionar mais um início de zona? (S / N)"
                    read verificar
                done

                echo "Deseja adicionar mais uma zona? (S / N)"
                read verificar
                if [[ "$verificar" == "N" || "$verificar" == "n" ]]; then
                    break
                fi
            done

            # Configurando o resolv.conf
            if [[ ! "$ip_fixo" == "0" ]]; then
                rm "/etc/resolv.conf"
                touch "/etc/resolv.conf"
                {
                    echo "nameserver $ip_fixo"
                } >>"/etc/resolv.conf"
            fi

            echo "----------------------------------------------------------------------"
            echo "Configuração realizada com sucesso!!!"
            echo "Deseja Desligar a maquina para colocar em rede interna? (S / N)"
            read -r resposta
            while true; do
    if [ "$resposta" = "S" ]; then
        echo "Desligando a máquina..."
        sleep 4
        init 0
        break # Sai do loop após uma resposta válida
    elif [ "$resposta" = "N" ]; then
        echo "Você optou por não desligar a máquina."
        break # Sai do loop após uma resposta válida
    else
        echo "Resposta inválida. Por favor, digite 'S' ou 'N'."
    fi
done
            echo "----------------------------------------------------------------------"
            sleep 3
                clear 
            ;;
        4)
            echo "Verificando Status..."
            systemctl status bind9
            sleep 2
            echo "Status Verificado"
            ;;
        5)
            echo "Iniciando Serviço DNS..."
            systemctl start bind9
            sleep 2
            clear
            echo "Serviço Iniciado"
            ;;
        6)
            echo "Parando Serviço..."
            systemctl stop bind9
            sleep 2
            clear
            echo "Serviço Parado"
            ;;
        7)
        echo "Reiniciando serviço..."
        systemctl restart bind9
        sleep 3
        clear
        echo "Serviço Reiniciado com Sucesso!!!"
        ;;
        8)
            xDns="false"
            ;;
        *)
            echo "Opção inválida, tente novamente."
            ;;
        esac
    done
}

dhcp() {
    xDhcp="continuar"
    while [ "$xDhcp" == "continuar" ]; do
        echo "Menu DHCP"
        echo "[1 - Instalar Serviço DHCP]"
        echo "[2 - Desinstalar Serviço DHCP]"
        echo "[3 - Verificar Status]"
        echo "[4 - Reiniciar Serviço]"
        echo "[5 - Parar Serviço]"
        echo "[6 - Iniciar Serviço]"
        echo "[7 - Adicionar nova configuração DHCP]"
        echo "[8 - Configurar qual placa de rede será escolhida para o servidor DHCP]"
        echo "[9 - Ver arquivo de configuração do DHCP]"
        echo "[10 - Ver tabelas de leases do DHCP]"
        echo "[11 - Voltar ao Menu Principal]"

        read -p "Escolha uma opção: " choice

        case $choice in
        1)
        if ! command -v isc-dhcp-server; then
            echo "Serviço não intalado..."
            echo "Iniciando Instalação do Serviço DHCP..."
            apt-get install isc-dhcp-server -y
            sleep 2
            clear
            echo "Serviço Instalado com Sucesso!!!"
        else
            echo "Serviço ja instalado..."
            fi
            ;;

        2)
            echo "Desisnstalando Serviço DHCP..."
            apt-get purge isc-dhcp-server -y
            sleep 2
            clear
            echo "Serviço Desinstalado..."

            ;;

        3)
            echo "Verificando Status..."
            systemctl status isc-dhcp-server
            sleep 1
            clear
            echo "Status Verificado"
            ;;
        4)
            echo "Reiniciando o servidor"
            systemctl restart isc-dhcp-server
            sleep 3
            clear
            echo "Servidor reiniciado"
            ;;
        5)
        echo "Iniciando serviço DHCP..."
        systemctl stat isc-dhcp-server
        sleep 2
        clear
        echo "Serviço Iniciado com Sucesso!!!"
        ;;
    7)
            echo "Nome do dominio: "
            read -r name
            echo "Entre com o servidor DNS e ip do google: "
            read -r DNS
            echo "Defindo concessão de IP: "
            read -r NUMERO
            echo "Entre com um IP de rede: "
            read -r IP
            echo "Entre com a mascara da rede: "
            read -r MAQ
            echo "Entre com o range [xxx.xxx.xxx.xxx xxx.xxx.xxx.xxx]: "
            read -r RANGE
            echo "entre com a mascara: "
            read -r MASCARA
            echo "Entre com o gateway: "
            read -r GW

            echo "
option domain-name ""$name"";

option domain-name-servers $DNS

default-lease-time $NUMERO

authoritative;

subnet $IP netmask $MAQ {
        range $RANGE;
        option subnet-mask $MAQ;
        
         option routers $GW;
}
" >>/etc/dhcp/dhcpd.conf
echo "Colocado configuração no arquivo..."
sleep 2
clear
echo "Congifuração realizada com Sucesso"
            ;;
        8)
            networkctl
            echo "Digite a placa que será usada: "
            read -r PLACA
            sed -i 's/INTERFACESv4.*/INTERFACESv4= "'$PLACA'"/' /etc/default/isc-dhcp-server
            cat /etc/default/isc-dhcp-server
            sleep 3
            clear
            ;;
        9)
            echo "Abrindo arquivo de configuração do dhcp (DHCPD.CONF)"
            cat /etc/dhcp/dhcpd.conf
            ;;

        10)
            echo "Exibindo tabelas de leases do DHCP:"
            sleep 2
            clear
            cat /var/lib/dhcp/dhcpd.leases
            ;;
        11)
            xDhcp="false"
            ;;
        *)
            echo "Opção inválida, tente novamente."
            ;;
        esac
    done
}
email() {
xMail="continuar"
    while [ "xMail" == "continuar"]; do
        echo "/-/-/-/Bem Vindo ao Menu de Servidor E-Mail/-/-/-/"
        echo "[1 - Instalação do servidor Postfix (Email)]"
        echo "[2 - Desinstalar Servidor Postfix]"
        echo "[3 - Iniciar Servidor Postfix]"
        echo "[4 - Parar Servidor Postfix]"
        echo "[5 - Reniciar Servidor Postfix]"
        echo "[6 - Status do Servidor Postfix]"
        echo "[7 - Configurar o Servidor Postfix]"
        echo "[8 - Criar um dominio DNS para o Postfix]"
        echo "[9 - Adicionar Usuario]"
        echo "[10 -  Sair do Script]"
        read -p "Escolha uma Resposta: " choice

        case $choice in

        1)
        if ! command -v postfix, then
            echo "Servidor Não instalado"
            echo "Inciando Instalação..."
            apt-get install postfix -y
            sleep 2
            clear
            echo "Postfix Instalado comm Sucesso!!!"
        else
            echo "Servidor Ja instalado..."
            sleep 1
        fi
        
        if ! command -v mailutils; then
            echo "Mailutils não está instalado..."
            echo "Iniciando instalação"
            apt-get install mailutils -y
            sleep 2
            clear 
            echo "Mailutils instalado com sucesso"
        else
            echo "Mailutils ja esta instalado"

        fi
        ;;
        2)
            echo "Desinstalado Servidor..."
            apt-get purge postfiix -y
            sleep 2
            clear
            echo "Servidor Desinstalado com Sucesso"
        ;;

        3)
            echo "Iniciando Servidor..."
            systemctl start postfix
            sleep 2
            echo "Servidor Iniciado com sucesso"
        ;;
        4)
            echo "Parando Servidor..."
            systemctl stop postfix
            sleep 2
            clear
            echo "Servidor fora de funcionamento"
        ;;
        5)
            echo "Reniciando Servidor..."
            systemctl restart postfix
            sleep 2
            clear
            echo "Servidor Reniciado com Sucesso!!!"
        ;;
        6)
            systemctl status postfix
        ;;
        7)
            sudo dpkg-reconfigure postfix
            sleep 3
            clear
            echo "Servidor Reinicado com Sucesso!!!"
        ;;
        8)
        while [[ loop==true ]]; do
	echo "Zona que deseja colocar:*"
	read zone
	echo "Final da zona que deseja colocar:* (.local, .com, ...)"
	read end
	# Configurando zona no named.conf.default-zones
	zona_completa="$zone$end"
	zona_local="$dir_dns/db.$zone"
	{
		echo "zone @" {
		echo "      type master;"
		echo "      file =;"
		echo -e "};\n"

		sed -i 's/@/"x"/g' $conf_default
		sed -i "s|x|$zona_completa|g" $conf_default
		sed -i 's/=/"+"/g' $conf_default
		sed -i "s|+|$zona_local|g" $conf_default

	} >>"$conf_default"

	echo "Início da zona que seja colocar:* (www, ns1, ...)"
	read start
	echo "Ip do serviço associado a esse início da zona:* "
	read ip_service

	# Criando db. e configurando
	localhost="ns1.$zone"
	touch "$zona_local"
	{
		echo -e "; BIND reverse data file for empty rfc1918 zone\n;\n; DO NOT EDIT THIS FILE - it is used for multiple zones.\n; Instead, copy it, edit named.conf, and use that copy.\n;\n=TTL	86400\n@	IN	SOA	localhost. root.localhost. (\n			      1		; Serial\n			 604800		; Refresh\n			  86400		; Retry\n			2419200		; Expire\n			  86400 )	; Negative Cache TTL\n;\n@	IN	NS	localhost."
		echo "$start	IN	A	$ip_service"
		sed -i "s|=|$|" "$dir_dns/db.$zone"
		sed -i "s|localhost|$localhost|g" "$dir_dns/db.$zone"
	} >>"$dir_dns/db.$zone"

	echo "Deseja adicionar mais um início de zona? (S / N)"
	read verificar
	while [[ "$verificar" == "S" || "$verificar" == "s" ]]; do
		echo "Início da zona que seja colocar:* (www, ns1, ...)"
		read start
		echo "Ip do serviço associado a esse início da zona:* "
		read ip_service
		{
			echo "$start	IN	A	$ip_service"
		} >>"$dir_dns/db.$zone"

		echo "Deseja adicionar mais um início de zona? (S / N)"
		read verificar
	done

	echo "Deseja adicionar mais uma zona? (S / N)"
	read verificar
	if [[ "$verificar" == "N" || "$verificar" == "n" ]]; then
		break
	fi
done

# Configurando o resolv.conf
if [[ ! "$ip_fixo" == "0" ]]; then
	rm "/etc/resolv.conf"
	touch "/etc/resolv.conf"
	{
		echo "nameserver $ip_fixo"
	} >>"/etc/resolv.conf"
fi

echo "----------------------------------------------------------------------"
echo "Configuração realizada com sucesso!!!"
        ;;
        9)
            echo "Digite o nome do usuario que deseja: "
            read -r usuario

        sudo adduser $usuario

        sleep 2

        echo "Usuario adicionado com sucesso"
        ;;
        10)
        xMail="false"
        ;;
        *)
            echo "Opção Invalida. Escolha uma opção valida!!!"

        esac
    done

}

# Verificar permissões de root
if [ "$EUID" -ne 0 ]; then
    echo "Permissão necessária para executar o script!!!"
    exit 1
fi

# Atualizar o sistema
while true; do
    echo "Deseja atualizar a máquina? (Digite 'S' ou 'N')"
    read resposta

    if [ "$resposta" = "S" ]; then
        echo "Atualizando a máquina..."
        apt-get update -y && apt-get upgrade -y
        echo "Máquina atualizada com sucesso!"
        break # Sai do loop após uma resposta válida
    elif [ "$resposta" = "N" ]; then
        echo "Você optou por não atualizar a máquina."
        break # Sai do loop após uma resposta válida
    else
        echo "Resposta inválida. Por favor, digite 'S' ou 'N'."
    fi
done

# Iniciar o menu
menu
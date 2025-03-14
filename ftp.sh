#!/bin/bash
# Data: 22/11/2023
# Feito por Renan Santos
# CVS $HEADER$

shopt -s -o nounset

# Variáveis
usuario="nome"
xFTP="continuar" # Inicializa a variável xFTP

menu() {
    while [ "$xFTP" == "continuar" ]; do
        echo "/-/-/-/-/-/-/Menu FTP/-/-/-/-/-/"
        echo "1 - Instalação do Servidor PROFTPD"
        echo "2 - Desinstalar Servidor PROFTPD"
        echo "3 - Configurar Servidor PROFTPD"
        echo "4 - Criação de Usuario FTP"
        echo "5 - Colocar senha no Usuario"
        echo "6 - Mostrar Usuarios criados"
        echo "7 - Deixar Usuario como dono de Pasta"
        echo "8 - Baixar Quota"
        echo "9 - Iniciar Servidor"
        echo "10 - Reiniciar Servidor"
        echo "11 - Parar Servidor"
        echo "12 - Status do Servidor"
        echo "13 - Sair do Script"
        read -p "Escolha uma Opção: " choice

        case $choice in
        1)
            if ! command -v proftpd; then
                echo "Servidor não está instalado..."
                echo "Instalando Servidor..."
                apt-get install proftpd -y
                sleep 3
                clear
                echo "Servidor Instalado com Sucesso!!!"
            else
                echo "Servidor já Instalado..."
            fi
            ;;
        2)
            echo "Iniciado Desinstalado do Servidor..."
            apt-get remove proftpd -y
            sleep 2
            clear
            echo "Servidor Desinstalado com Sucesso!!!"
            ;;
        3)
            echo "Iniciando Configuração do FTP..."
            sleep 1
            while true; do
                echo "Deseja fazer o Backup do Arquivo proftpd.conf? (S/N)"
                read -r resposta
                if [ "$resposta" == "S" ] || [ "$resposta" == "s" ]; then
                    cp /etc/proftpd/proftpd.conf /etc/proftpd/proftpd.conf.bkp
                    sleep 1
                    echo "Backup Feito..."
                    break
                elif [ "$resposta" == "N" ] || [ "$resposta" == "n" ]; then
                    echo "Você optou por não atualizar a máquina."
                    break # Sai do loop após uma resposta válida
                else
                    echo "Resposta inválida. Por favor, digite 'S' ou 'N'."
                fi
            done

            # Adicione aqui as configurações do FTP
            echo "Definindo configurações básicas..."
            sed -i '11c\UseIPv6 off' /etc/proftpd/proftpd.conf
            sed -i '21c\ServerName "debian"' /etc/proftpd/proftpd.conf
            sed -i '39c\DefaultRoot ~' /etc/proftpd/proftpd.conf
            sed -i '43c\RequireValidShell off' /etc/proftpd/proftpd.conf
            # Reinicia o serviço após a configuração
            systemctl restart proftpd

            echo "Configurações do FTP aplicadas com sucesso!"
            ;;
        4)
            echo "Criando Usuario..."
            echo "Digite o nome do Usuario que deseja: "
            read -r usuario
            echo "Digite a pasta do destino (ex: /var/www): "
            read -r pasta_do_destino
 # Verificar se a pasta de destino existe, caso contrário, crie-a
    if [ ! -d "$pasta_do_destino" ]; then
        echo "A pasta de destino não existe. Criando a pasta..."
        mkdir -p "$pasta_do_destino"

        # Verificar se a criação da pasta foi bem-sucedida
        if [ $? -eq 0 ]; then
            echo "Pasta criada com sucesso!"
        else
            echo "Erro ao criar a pasta. Verifique as permissões."
            exit 1
        fi
    else
        echo "A pasta de destino já existe."
    fi
            useradd $usuario -d $pasta_do_destino -s /bin/false
            sleep 2

            # Adicionar opção para configurar quota
            read -p "Deseja configurar uma cota de 5GB para o usuário? (S/N): " resposta_quota
            if [ "$resposta_quota" == "S" ] || [ "$resposta_quota" == "s" ]; then
                setquota -u $usuario 5242880 5242880 0 0 $pasta_do_destino
                echo "Cota de 5GB configurada para o usuário $usuario."
            fi

            echo "Usuario criado com Sucesso!!!"
            ;;
        5)
            echo "Nome do usuario que deseja colocar: "
            read -r usuario
            passwd $usuario
            ;;
        6)
            cat /etc/passwd
            sleep 1
            ;;
        7)
            echo "Digite o nome do Usuario que deseja colocar como dono da pasta: "
            read -r usuario
            echo "Digite o nome da Pasta do destino: "
            read -r pasta_do_destino
            chown $usuario -R $pasta_do_destino
            ;;
        8)
            if command -v quota, then
                echo "Quota não instalada..."
                echo "Iniciando instalação"
                apt-get install quota -y
                sleep 2
                clear
                echo "Quota instalada com sucesso!!!"
            else
                echo "Quota já instalada!!!"
            fi

        ;;
        9)
            echo "Iniciando Servidor..."
            systemctl start proftpd
            sleep 2
            echo "Servidor Iniciado com sucesso!!!"
            ;;
        10)
            echo "Reiniciando Servidor..."
            systemctl restart proftpd
            sleep 2
            clear
            echo "Servidor Reiniciado com Sucesso!!!"
            ;;
        11)
            echo "Parando Servidor..."
            systemctl stop proftpd
            sleep 2
            echo "Servidor fora de Serviço"
            ;;
        12)
            systemctl status proftpd
            sleep 2
            clear

            ;;
        13)
            xFTP="sair"
            ;;
        *)
            echo "Opção Invalida. Escolha uma opção valida:"
            ;;
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

    if [ "$resposta" == "S" ] || [ "$resposta" == "s" ]; then
        echo "Atualizando a máquina..."
        apt-get update -y && apt-get upgrade -y
        echo "Máquina atualizada com sucesso!"
        break # Sai do loop após uma resposta válida
    elif [ "$resposta" == "N" ] || [ "$resposta" == "n" ]; then
        echo "Você optou por não atualizar a máquina."
        break # Sai do loop após uma resposta válida
    else
        echo "Resposta inválida. Por favor, digite 'S' ou 'N'."
    fi
done

# Chamar a função menu
menu

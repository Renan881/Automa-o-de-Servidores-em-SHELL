#!/bin/bash
#
#FEITO POR RENAN
#DATA: 18/11/2023
#CVS $HEADER$

shopt -s -o nounset

echo "Iniciando script..."
sleep 2

#variaveis
caminho_do_projeto="/var/www/html/Exemplo-2-CSS"
link_do_projeto="https://github.com/vitor-ext/Exemplo-2-CSS.git"
page_name="Exemplo-2-CSS"
copia_dos_arquivos="style.css', 'imagens', 'index.html', 'README.md'"

menu() {
    xMenu="continuar"
    while [ "$xMenu" == "continuar"]; do

        echo "----------------/Bem Vinido ao Nosso script/---------------"
        echo "Iniciado MENU de Servidor WEB (apache2)...."
        echo "[1 - Instalar Servidor WEB]"
        echo "[2 - Desinstalar Servidor WEB]"
        echo "[3 - GIT HUB]"
        echo "[4 - Reiniciar Servidor WEB]"
        echo "[5 - Status do Servdor WEB]"
        echo "[6 - Sair do Script]"
        read -r resposta
        case $resposta in
        1)
            echo "Iniciando Instalação do Servidor WEB..."
            apt-get install apache2 -y
            sleep 3
            clear
            echo "Servidor Instalado com Sucesso!!!"
            ;;
        2)
            echo "Iniciando Remoção do Sevidor WEB..."
            apt-get purge apache2 -y
            sleep 3
            clear
            echo "Remoção Realizada com Sucesso!!!"
            ;;
        3)
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
        4)
            echo "Reiniciando Servidor..."
            systemctl restarr apache2
            sleep 2
            clear
            echo "Reinicado com Sucesso!!!"
            ;;
        5)
            systemctl status apache2
            sleep 2
            clear
            ;;
        6)
            xMenu="false"
            ;;
        *)
            echo "Opção Invalida. Escolha uma opção Valida!!!"
            ;;

        esac

    done

}

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

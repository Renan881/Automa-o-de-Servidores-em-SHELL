#!/bin/bash
#Feito por Renan
#data: 13/10/2023

shopt -s -o nounset

diretorio_origem="/caminho/do/diretorio/origem"
diretorio_destino="/caminho/do/siretorio/destino"

#criar diretorio com data atual
data_backup=$(date + "%T-%m-%d")
diretorio_backup="$diretorio_destino/beckup_$data_backup"
#verificação se o beckup doi bem-sucedido

#verificação de deiretorio mantidojá existe
if [ -d "$diretorio_backup" ]; then
    echo "O diretorio para hoje ja foi feito. Saindo."
    exit 1
fi
#execute o backup usadno o comando rsync
rsync -av --delete "$diretorio_origem" "$diretorio_backup"

#verificar se foi bem-sucedido
if [ $? -eq 0 ]; then
    echo "Backup diario feito com sucesso em $data_backup!!."
else
    echo "Erro ao fazer o backup. Verifique o log!!."
fi

#verificar se o beckups foi mantidos com sucesso
numero_maximo_backups=7
lista_de_backups=($(ls -d $diretorio_destino/backup_* | sort -r))
while [ ${#lista_de_backups[@]} -gt $numero_maximo_backups ]; do
    diretorio_a_remover=${lista_de_backups[-1]}
    rm -r "$diretorio_a_remover"
    echo "Removido backup antigo em $diretorio_a_remover."
    lista_de_backups=($(ls -d $diretorio_destino/backup_* | sort -r))
done

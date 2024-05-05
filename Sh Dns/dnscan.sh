#!/bin/bash

# Definindo as cores para usar na saída
green='\033[32m'  # Verde
blue='\033[94m'   # Azul
red='\033[31m'    # Vermelho
brown='\033[33m'  # Marrom
end='\033[0m'     # Resetar a cor

# Verificar se os comandos necessários estão instalados
commands=(python3 dig)  # Lista dos comandos necessários
for cmd in "${commands[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || { echo >&2 "Erro: $cmd é necessário, mas não está instalado. Abortando."; exit 1; }
done

# Analisar os argumentos da linha de comando
while getopts ":d:" opt; do
    case $opt in
        d)
            domain="$OPTARG"  # Armazenar o domínio especificado
            ;;
        \?)
            echo "Opção inválida: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Opção -$OPTARG requer um argumento." >&2
            exit 1
            ;;
    esac
done

# Verificar se o domínio foi fornecido
if [ -z "$domain" ]; then
    echo "Erro: Nome do domínio não fornecido. Uso: dnscan.sh -d <domínio>"
    exit 1
fi

# Realizar a varredura de DNS
echo -e "Varrendo o domínio $domain em busca de registros de DNS..."

# Consultar registros NS
echo -e "\n${blue}[+] Nameservers${end}"
dig +short NS "$domain" | while read -r ns; do
    ns_ip=$(dig +short "$ns" | head -n1)
    echo -e "$ns_ip - ${brown}$ns${end}"
done

# Consultar registros A
echo -e "\n${blue}[+] Registros A${end}"
dig +short A "$domain" | while read -r ip; do
    echo -e "${brown}$ip${end} - $domain"
done

# Consultar registros AAAA
echo -e "\n${blue}[+] Registros AAAA${end}"
dig +short AAAA "$domain" | while read -r ip; do
    echo -e "${brown}$ip${end} - $domain"
done

# Consultar registros MX
echo -e "\n${blue}[+] Registros MX${end}"
dig +short MX "$domain" | while read -r mx; do
    echo -e "${mx#* } - $domain"
done

# Consultar registros TXT
echo -e "\n${blue}[+] Registros TXT${end}"
dig +short TXT "$domain" | while read -r txt; do
    echo -e "$txt"
done

# Consultar registros DMARC
echo -e "\n${blue}[+] Registros DMARC${end}"
dig +short TXT "_dmarc.$domain" | while read -r dmarc; do
    echo -e "$dmarc"
done

# Consultar registros DNSSEC
echo -e "\n${blue}[+] Registros DNSSEC${end}"
dig +short DNSKEY "$domain" | while read -r dnssec; do
    echo -e "$dnssec"
done

echo -e "\n${green}Varredura concluída.${end}"

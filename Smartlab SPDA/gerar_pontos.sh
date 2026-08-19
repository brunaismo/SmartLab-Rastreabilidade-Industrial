#!/bin/bash

# ------------------------------------------------------------
# gerar_pontos.sh - Cria estrutura de pontos SPDA a partir de CSV
# Uso: ./gerar_pontos.sh config_pontos.csv [pasta_saida]
# gerar_pontos.sh - Creates SPDA inspection point structure from CSV
# Usage: ./gerar_pontos.sh config_pontos.csv [output_directory]
# ------------------------------------------------------------

CONFIG="${1:-config_pontos.csv}"
OUT_DIR="${2:-SPDA_Pontos}"

# Verifica dependencia
# Check dependency
command -v qrencode >/dev/null 2>&1 || { echo "Erro: qrencode não encontrado. Instale"; exit 1; }

mkdir -p "$OUT_DIR"

# Copiar gerador de links
# Copy link generator
cp qr.sh "$OUT_DIR"
chmod +x "$OUT_DIR"/qr.sh
touch "$OUT_DIR"/links.txt

# Sepuku preparations
echo "rm links.txt" >> "$OUT_DIR"/qr.sh
echo "rm qr.sh" >> "$OUT_DIR"/qr.sh
# Medida de seguranca contra suicidio precipitado
# Safety measure to prevent unintended deletion

INDEX_FILE="$OUT_DIR/indice_pontos.csv"
echo "Código,Pasta,Cliente,Unidade,Área,Tipo" > "$INDEX_FILE"

# read CSV ignor first row
tail -n +2 "$CONFIG" | while IFS=',' read -r cliente sigCli unidade sigUnid area sigArea tipo sigTipo qtd desc; do
    # Remove aspas e espaços extras
	# Remove quotes and extra whitespace
    sigCli=$(echo "$sigCli" | tr -d '"' | xargs)
    sigArea=$(echo "$sigArea" | tr -d '"' | xargs)
    sigTipo=$(echo "$sigTipo" | tr -d '"' | xargs)
    qtd=$(echo "$qtd" | tr -d '"' | xargs)
    desc=$(echo "$desc" | tr -d '"' | xargs)

    # Verifica se quantidade é número
	# Validate quantity as a number
    if ! [[ "$qtd" =~ ^[0-9]+$ ]]; then
        echo "Quantidade inválida na linha: $cliente,$sigCli,..."; continue
    fi

    # Gera N pontos
	# Generate N inspection points
    for ((i=1; i<=qtd; i++)); do
        num=$(printf "%03d" $i)
        codigo="${sigCli}-SPDA-${sigArea}-${sigTipo}-${num}"
        pasta="$OUT_DIR/$codigo"
        mkdir -p "$pasta"
	mkdir -p "$pasta"/fotos

        # ponto.txt
        cat > "$pasta/ponto.txt" <<EOF
Cliente: $cliente ($sigCli)
Unidade: $unidade ($sigUnid)
Área: $area ($sigArea)
Tipo: $tipo ($sigTipo)
Código: $codigo
Descrição: $desc
EOF

        # inspecoes.csv (cabeçalho)
		# inspecoes.csv (header)
        echo "Data;Responsável;Condição_Visual;Continuidade_(mΩ);Resistência_(Ω);Oxidação;Necessita_Correção;Conformidade;Observações" > "$pasta/inspecoes.csv"

        # Índice
		# Index
        echo "$codigo,$pasta,$cliente,$unidade,$area,$tipo" >> "$INDEX_FILE"
        echo "Criado: $codigo"
    done
done

echo "Concluído! Estrutura gerada em: $OUT_DIR"

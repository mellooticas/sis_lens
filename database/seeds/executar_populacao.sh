#!/bin/bash

# ===============================================
# Script de População Automática do Banco de Dados
# BestLens - Sistema Decisor de Lentes
# Versão: 2.0
# Data: 04/10/2025
# ===============================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Função para log
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCESSO]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

info() {
    echo -e "${PURPLE}[INFO]${NC} $1"
}

# Banner do sistema
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════╗"
echo "║            BestLens Database Seeder            ║"
echo "║          Sistema Decisor de Lentes             ║"
echo "║                Versão 2.0                      ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar se o ambiente foi fornecido
ENVIRONMENT=${1:-dev}

if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
    error "Ambiente deve ser 'dev' ou 'prod'"
    echo "Uso: $0 [dev|prod]"
    exit 1
fi

log "Iniciando população do banco de dados - Ambiente: $ENVIRONMENT"

# Verificar se psql está instalado
if ! command -v psql &> /dev/null; then
    error "psql não encontrado. Instale o PostgreSQL client."
    echo "Alternativas:"
    echo "- Use o Supabase CLI: supabase db reset"
    echo "- Execute via Dashboard Supabase"
    exit 1
fi

# Verificar variáveis de ambiente
if [[ -z "$DATABASE_URL" ]]; then
    warning "DATABASE_URL não definida"
    echo "Para usar este script via psql, defina:"
    echo "export DATABASE_URL='postgresql://user:pass@host:port/database'"
    echo ""
    echo "Ou use o Supabase CLI na pasta do projeto:"
    echo "supabase start"
    echo "supabase db reset"
    echo ""
    read -p "Continuar mesmo assim? (y/N): " continue_without_url
    if [[ "$continue_without_url" != "y" && "$continue_without_url" != "Y" ]]; then
        info "Configure o ambiente e execute novamente"
        exit 1
    fi
fi

# Criar diretório de logs se não existir
mkdir -p logs

# Lista de scripts para executar (EM ORDEM!)
SCRIPTS=(
    "001_dados_basicos.sql"
    "002_catalogo_essilor.sql"
    "003_catalogo_zeiss.sql"
    "004_catalogo_hoya.sql"
    "005_precos_comercial.sql"
    "006_dados_simulados.sql"
)

# Descrições dos scripts
declare -A SCRIPT_DESCRIPTIONS=(
    ["001_dados_basicos.sql"]="Dados fundamentais (tenants, marcas, laboratórios, usuários)"
    ["002_catalogo_essilor.sql"]="Catálogo técnico completo Essilor (Varilux, Crizal, Transitions)"
    ["003_catalogo_zeiss.sql"]="Catálogo técnico completo Zeiss (SmartLife, Individual, DuraVision)"
    ["004_catalogo_hoya.sql"]="Catálogo técnico completo Hoya (iD MyStyle, Hi-Vision, Sensity)"
    ["005_precos_comercial.sql"]="Estrutura comercial (preços, condições, campanhas, contratos)"
    ["006_dados_simulados.sql"]="Histórico simulado (6 meses de decisões, métricas, analytics)"
)

log "Scripts a serem executados: ${#SCRIPTS[@]}"
echo ""

# Mostrar resumo dos scripts
info "Resumo da população:"
for i in "${!SCRIPTS[@]}"; do
    script="${SCRIPTS[$i]}"
    description="${SCRIPT_DESCRIPTIONS[$script]}"
    echo -e "${BLUE}$(($i + 1)).${NC} ${script} - ${description}"
done

echo ""
read -p "Continuar com a execução? (Y/n): " confirm_execution
if [[ "$confirm_execution" == "n" || "$confirm_execution" == "N" ]]; then
    info "Execução cancelada pelo usuário"
    exit 0
fi

echo ""
log "Iniciando execução dos scripts..."

# Contador de sucessos e erros
SUCCESS_COUNT=0
ERROR_COUNT=0
START_TIME=$(date +%s)

# Executar cada script
for i in "${!SCRIPTS[@]}"; do
    script="${SCRIPTS[$i]}"
    description="${SCRIPT_DESCRIPTIONS[$script]}"
    
    if [[ ! -f "$script" ]]; then
        error "Script não encontrado: $script"
        ((ERROR_COUNT++))
        continue
    fi
    
    echo ""
    log "📋 ($((i + 1))/${#SCRIPTS[@]}) Executando: $script"
    info "$description"
    
    # Executar script e capturar saída
    if [[ -n "$DATABASE_URL" ]]; then
        # Usar psql se DATABASE_URL está definida
        if psql "$DATABASE_URL" -f "$script" > "logs/${script%.sql}.log" 2>&1; then
            success "✅ $script executado com sucesso"
            ((SUCCESS_COUNT++))
        else
            error "❌ Erro ao executar $script"
            echo "Verifique o log: logs/${script%.sql}.log"
            
            # Mostrar últimas linhas do erro
            echo "Últimas linhas do erro:"
            tail -n 5 "logs/${script%.sql}.log"
            
            ((ERROR_COUNT++))
            
            # Perguntar se deve continuar
            read -p "Continuar com próximo script? (y/N): " continue_execution
            if [[ "$continue_execution" != "y" && "$continue_execution" != "Y" ]]; then
                error "Execução interrompida pelo usuário"
                break
            fi
        fi
    else
        # Sugerir execução manual
        warning "Execute manualmente via SQL client:"
        echo "psql \"\$DATABASE_URL\" -f $script"
        echo "ou cole o conteúdo no Dashboard Supabase"
        echo ""
        read -p "Script executado manualmente? (y/n): " manual_executed
        if [[ "$manual_executed" == "y" || "$manual_executed" == "Y" ]]; then
            success "✅ $script marcado como executado"
            ((SUCCESS_COUNT++))
        else
            error "❌ $script não executado"
            ((ERROR_COUNT++))
        fi
    fi
done

# Calcular tempo total
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║                   RESUMO FINAL                 ║"
echo "╚════════════════════════════════════════════════╝"

echo -e "Tempo total: ${BLUE}${TOTAL_TIME}s${NC}"
echo -e "Scripts executados com sucesso: ${GREEN}${SUCCESS_COUNT}${NC}"
echo -e "Scripts com erro: ${RED}${ERROR_COUNT}${NC}"

if [[ $ERROR_COUNT -eq 0 ]]; then
    success "🎉 Todos os scripts executados com sucesso!"
else
    warning "⚠️  Alguns scripts falharam. Verifique os logs em: logs/"
fi

# Verificação final (se DATABASE_URL disponível)
if [[ -n "$DATABASE_URL" ]]; then
    echo ""
    log "Verificando dados inseridos..."

    # Query de verificação expandida
    VERIFICATION_QUERY="
    SELECT 
        'Tenants' as tabela, COUNT(*) as registros 
    FROM meta_system.tenants 
    UNION ALL
    SELECT 
        'Marcas' as tabela, COUNT(*) as registros 
    FROM lens_catalog.marcas 
    UNION ALL
    SELECT 
        'Lentes' as tabela, COUNT(*) as registros 
    FROM lens_catalog.lentes 
    UNION ALL
    SELECT 
        'Laboratórios' as tabela, COUNT(*) as registros 
    FROM suppliers.laboratorios
    UNION ALL
    SELECT 
        'Representantes' as tabela, COUNT(*) as registros 
    FROM suppliers.representantes
    UNION ALL
    SELECT 
        'Tabelas Preço' as tabela, COUNT(*) as registros 
    FROM commercial.tabelas_preco
    UNION ALL
    SELECT 
        'Decisões' as tabela, COUNT(*) as registros 
    FROM scoring.decisoes
    UNION ALL
    SELECT 
        'Métricas' as tabela, COUNT(*) as registros 
    FROM analytics.metricas_performance
    ORDER BY tabela;
    "

    echo ""
    info "📊 Dados inseridos no banco:"
    echo "$VERIFICATION_QUERY" | psql "$DATABASE_URL" -t

    # Estatísticas por marca
    STATS_QUERY="
    SELECT 
        m.nome as marca,
        COUNT(l.id) as produtos,
        AVG(l.preco_venda)::DECIMAL(10,2) as preco_medio
    FROM lens_catalog.marcas m
    LEFT JOIN lens_catalog.lentes l ON m.id = l.marca_id
    WHERE m.tenant_id = (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo')
    GROUP BY m.id, m.nome
    ORDER BY produtos DESC;
    "

    echo ""
    info "📈 Estatísticas por marca:"
    echo "$STATS_QUERY" | psql "$DATABASE_URL" -t
fi

echo ""
success "🏁 População do banco concluída!"
info "📁 Logs salvos em: logs/"
info "📚 Consulte o README.md para próximos passos"

if [[ $SUCCESS_COUNT -eq ${#SCRIPTS[@]} ]]; then
    echo ""
    echo -e "${GREEN}🎯 Sistema BestLens pronto para uso!${NC}"
    echo -e "${BLUE}Próximos passos:${NC}"
    echo "1. Acesse o sistema web"
    echo "2. Teste algumas decisões de lentes"
    echo "3. Explore os relatórios e analytics"
    echo "4. Configure dados reais da sua ótica"
fi
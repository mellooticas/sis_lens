# 🛡️ Sistema de Controles Avançados para Vouchers

## 📊 **Limites Inteligentes Implementados:**

### **🎯 Limites Globais do Sistema:**
- **Máximo 80 vouchers/mês** (26% das 300 vendas)
- **Máximo R$ 16.000 economia/mês** (~R$ 53 por venda)
- **Desconto máximo por perfil:**
  - 🎯 DCL: 20%
  - 👑 Financeiro: 25% 
  - ⚙️ Admin Junior: 15%

### **⚡ Alertas Automáticos:**
- **80% dos limites**: Alerta amarelo
- **90% dos limites**: Alerta vermelho + bloqueio
- **Projeção de risco**: Calcula se vai estourar no mês

---

## 🚀 **Novas Funcionalidades:**

### **1. Verificação Prévia**
```sql
SELECT public.verificar_limites_voucher(15.0, 500.00);
-- Retorna se pode gerar e alertas
```

### **2. Geração Controlada**
```sql
SELECT public.api_gerar_voucher_controlado(
    15.0,     -- 15% desconto
    200.00,   -- R$ 200 mínimo
    500.00,   -- R$ 500 máximo desconto
    30,       -- 30 dias validade
    null,     -- todas as lojas
    'Voucher promocional',
    false     -- não forçar (só supervisor pode)
);
```

### **3. Dashboard de Controle**
```sql
SELECT public.api_dashboard_controle_vouchers();
-- Dashboard completo com métricas e projeções
```

---

## 📈 **Controles por Perfil:**

| Perfil | Limite Desconto | Pode Forçar | Vouchers/Mês |
|--------|----------------|--------------|--------------|
| 👑 **Financeiro** | 25% | ✅ Sim | Ilimitado |
| 🎯 **DCL** | 20% | ❌ Não | 50 |
| ⚙️ **Admin Jr** | 15% | ❌ Não | 30 |
| 🏪 **Lojas** | - | ❌ Não | Só usar |

---

## 🔄 **Fluxo de Controle:**

### **Geração Normal:**
1. ✅ Verifica role e permissões
2. ✅ Valida limite de desconto por perfil
3. ✅ Verifica limite mensal (80 vouchers)
4. ✅ Verifica limite de valor (R$ 16k)
5. ✅ Calcula projeção e alertas
6. ✅ Gera voucher ou bloqueia

### **Override do Supervisor:**
- 👑 **Financeiro** pode usar `force_admin: true`
- Bypassa todos os limites
- Registra no log como "forçado"

---

## 📊 **Dashboard em Tempo Real:**

```json
{
  "vouchers": {
    "gerados": 45,
    "limite": 80,
    "percentual_usado": 56.3
  },
  "economia": {
    "potencial": 8500.00,
    "limite": 16000.00,
    "percentual_usado": 53.1
  },
  "projecoes": {
    "vouchers_fim_mes": 72,
    "risco_limite": false
  }
}
```

---

## ⚙️ **Configurações Flexíveis:**

Todas as configurações ficam na tabela `sistema_config_bestlens` e podem ser ajustadas:

```sql
-- Exemplo: Reduzir limite para 60 vouchers
UPDATE public.sistema_config_bestlens 
SET valor = jsonb_set(valor, '{limite_mensal_vouchers_sistema}', '60')
WHERE chave = 'voucher_config';
```

---

## 🎯 **Próximos Passos:**

1. **Execute o script** `controles_avancados_vouchers.sql` no Supabase
2. **Teste os limites** gerando vouchers
3. **Configure interface** com dashboard de controle
4. **Ajuste limites** conforme necessário

**Quer que eu execute este sistema de controles no Supabase Cloud?** 🚀
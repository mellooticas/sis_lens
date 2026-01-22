// ============================================================================
// VERIFICAÇÃO: Marcas e is_premium nas Lentes (Schema Correto)
// ============================================================================

import pg from 'pg';
const { Client } = pg;

const client = new Client({
  host: 'aws-0-sa-east-1.pooler.supabase.com',
  port: 6543,
  database: 'postgres',
  user: 'postgres.otkbrpkmwzkuuunhclwi',
  password: '09FTLens69',
});

async function verificar() {
  try {
    await client.connect();
    console.log('\n' + '='.repeat(70));
    console.log('VERIFICAÇÃO DE MARCAS E IS_PREMIUM NAS LENTES');
    console.log('='.repeat(70) + '\n');

    // Verificação 1: Total de lentes e campos NULL
    const resultado1 = await client.query(`
      SELECT 
        COUNT(*) as total_lentes,
        COUNT(CASE WHEN marca_id IS NULL THEN 1 END) as sem_marca,
        COUNT(CASE WHEN is_premium IS NULL THEN 1 END) as sem_premium,
        COUNT(CASE WHEN marca_id IS NOT NULL AND is_premium IS NOT NULL THEN 1 END) as lentes_ok
      FROM lens_catalog.lentes
      WHERE ativo = true
    `);

    const { total_lentes, sem_marca, sem_premium, lentes_ok } = resultado1.rows[0];

    console.log('📊 TOTAIS:');
    console.log(`   Total de lentes:        ${total_lentes}`);
    console.log(`   Lentes sem marca:       ${sem_marca}`);
    console.log(`   Lentes sem is_premium:  ${sem_premium}`);
    console.log(`   Lentes OK:              ${lentes_ok}\n`);

    // Verificação 2: Distribuição is_premium
    const resultado2 = await client.query(`
      SELECT 
        is_premium,
        COUNT(*) as total,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentual
      FROM lens_catalog.lentes
      WHERE ativo = true
      GROUP BY is_premium
      ORDER BY is_premium DESC NULLS LAST
    `);

    console.log('📋 DISTRIBUIÇÃO is_premium:');
    resultado2.rows.forEach(row => {
      const label = row.is_premium === null ? 'NULL' : 
                    row.is_premium ? 'Premium (true)' : 'Standard (false)';
      console.log(`   ${label.padEnd(20)} ${String(row.total).padStart(6)} lentes (${row.percentual}%)`);
    });
    console.log('');

    // Verificação 3: Lentes por marca
    const resultado3 = await client.query(`
      SELECT 
        m.nome as marca,
        COUNT(l.id) as total_lentes,
        COUNT(CASE WHEN l.is_premium = true THEN 1 END) as lentes_premium,
        COUNT(CASE WHEN l.is_premium = false THEN 1 END) as lentes_standard,
        COUNT(CASE WHEN l.is_premium IS NULL THEN 1 END) as lentes_null
      FROM lens_catalog.marcas m
      LEFT JOIN lens_catalog.lentes l ON l.marca_id = m.id AND l.ativo = true
      WHERE m.ativo = true
      GROUP BY m.id, m.nome
      HAVING COUNT(l.id) > 0
      ORDER BY total_lentes DESC
      LIMIT 15
    `);

    console.log('📊 LENTES POR MARCA (Top 15):');
    console.log('   ' + 'Marca'.padEnd(25) + 'Total'.padStart(8) + 'Premium'.padStart(10) + 'Standard'.padStart(11) + 'NULL'.padStart(8));
    console.log('   ' + '-'.repeat(70));
    resultado3.rows.forEach(row => {
      console.log('   ' +
        row.marca.padEnd(25) +
        String(row.total_lentes).padStart(8) +
        String(row.lentes_premium).padStart(10) +
        String(row.lentes_standard).padStart(11) +
        String(row.lentes_null).padStart(8)
      );
    });
    console.log('');

    // Se houver problemas, mostrar exemplos
    if (parseInt(sem_marca) > 0) {
      const resultado4 = await client.query(`
        SELECT id, nome, categoria, tipo_lente
        FROM lens_catalog.lentes
        WHERE ativo = true AND marca_id IS NULL
        LIMIT 5
      `);
      console.log('⚠️  EXEMPLOS de lentes SEM MARCA:');
      resultado4.rows.forEach(row => {
        console.log(`   ID ${row.id}: ${row.nome} (${row.tipo_lente}, ${row.categoria})`);
      });
      console.log('');
    }

    if (parseInt(sem_premium) > 0) {
      const resultado5 = await client.query(`
        SELECT l.id, l.nome, l.categoria, m.nome as marca
        FROM lens_catalog.lentes l
        LEFT JOIN lens_catalog.marcas m ON m.id = l.marca_id
        WHERE l.ativo = true AND l.is_premium IS NULL
        LIMIT 5
      `);
      console.log('⚠️  EXEMPLOS de lentes SEM IS_PREMIUM:');
      resultado5.rows.forEach(row => {
        console.log(`   ID ${row.id}: ${row.nome} - ${row.marca} (${row.categoria})`);
      });
      console.log('');
    }

    // Validação final
    console.log('='.repeat(70));
    console.log('RESULTADO FINAL');
    console.log('='.repeat(70) + '\n');

    if (parseInt(sem_marca) === 0 && parseInt(sem_premium) === 0) {
      console.log('✅ TUDO OK - Pode executar 99V e 99W');
      console.log('   → Todas as lentes têm marca_id definida');
      console.log('   → Todas as lentes têm is_premium definido\n');
    } else {
      console.log('⚠️  CORRIGIR antes de executar 99V e 99W\n');
      if (parseInt(sem_marca) > 0) {
        console.log(`   → ${sem_marca} lentes sem marca_id`);
      }
      if (parseInt(sem_premium) > 0) {
        console.log(`   → ${sem_premium} lentes sem is_premium`);
      }
      console.log('');
    }

  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    await client.end();
  }
}

verificar();

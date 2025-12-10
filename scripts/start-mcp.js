import { spawn } from 'child_process';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

// 1. Carregar .env
const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, '../.env') });

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
    console.error('ERRO: Variavel DATABASE_URL não encontrada no .env');
    process.exit(1);
}

console.error('Iniciando MCP Server Postgres...');
// console.error('Connection:', connectionString.replace(/:[^:]*@/, ':****@')); // Log seguro

// 2. Executar o servidor MCP oficial passando a string de conexão
// Usamos stdio: 'inherit' para ligar a entrada/saida padrão do processo pai (Client) ao filho (Server)
const child = spawn('npx', ['-y', '@modelcontextprotocol/server-postgres', connectionString], {
    stdio: 'inherit',
    shell: true,
    cwd: path.join(__dirname, '..') // Executar na raiz do projeto
});

child.on('error', (err) => {
    console.error('Falha ao iniciar processo mcp:', err);
    process.exit(1);
});

child.on('exit', (code) => {
    process.exit(code || 0);
});

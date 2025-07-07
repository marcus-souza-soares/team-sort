# Team Sort - Sistema de Sorteio de Times

Sistema web para organizar times de futebol de domingo (pelada entre amigos) com funcionalidade de sorteio automático de jogadores.

## 🎯 Sobre o Projeto

O **Team Sort** é uma aplicação Rails que permite:
- Cadastrar e gerenciar jogadores
- Criar sessões de jogo
- Adicionar jogadores às sessões
- Fazer sorteio automático de times
- Visualizar times formados

## 🚀 Como Executar do Zero

### Pré-requisitos

- **Ruby** 3.2+ (verificar com `ruby --version`)
- **Rails** 8.0+ (verificar com `rails --version`)
- **SQLite** (vem com Rails por padrão)
- **Node.js** (para assets)

### 1. Clone o Repositório

```bash
git clone <url-do-repositorio>
cd team-sort
```

### 2. Instale as Dependências

```bash
# Instalar gems do Ruby
bundle install

# Se houver problemas com bundler, atualize:
gem install bundler
bundle update --bundler
```

### 3. Configure o Banco de Dados

```bash
# Criar banco de dados
rails db:create

# Executar migrações
rails db:migrate

# Executar seed com dados de exemplo
rails db:seed
```

### 4. Execute o Servidor

```bash
# Iniciar servidor Rails
rails server

# Ou usando o comando mais curto
rails s
```

### 5. Acesse a Aplicação

Abra seu navegador e acesse: **http://localhost:3000**

## 📊 Dados Iniciais (Seed)

O seed cria automaticamente:

- **10 jogadores** com dados reais
- **1 sessão de exemplo** para amanhã
- **3 times de exemplo**
- **Todos os jogadores** já adicionados à sessão

### Executar apenas o seed:
```bash
rails db:seed
```

### Resetar banco e executar seed:
```bash
rails db:reset
```

## 🏗️ Estrutura do Projeto

```
team-sort/
├── app/
│   ├── controllers/          # Controllers da aplicação
│   ├── models/              # Modelos (Player, GameSession, Team, etc.)
│   ├── views/               # Views das páginas
│   └── services/            # Serviços (TeamSorterService)
├── config/
│   ├── routes.rb            # Configuração de rotas
│   └── database.yml         # Configuração do banco
├── db/
│   ├── migrate/             # Migrações do banco
│   └── seeds.rb             # Dados iniciais
└── README.md               # Este arquivo
```

## 🎮 Como Usar

### 1. Criar Jogadores
- Acesse `/players`
- Clique em "Novo Jogador"
- Preencha nome, email, telefone e posição
- Salve

### 2. Criar Sessão
- Acesse `/game_sessions`
- Clique em "Nova Sessão"
- Defina data/hora e status
- Salve

### 3. Adicionar Jogadores à Sessão
- Na sessão, clique em "Gerenciar Jogadores"
- Adicione os jogadores que vão participar
- Veja quantos jogadores estão na sessão

### 4. Fazer Sorteio
- Clique em "Sortear Times"
- Escolha quantos jogadores por time
- Clique em "Fazer Sorteio"
- Veja os times formados!

## 🔧 Comandos Úteis

```bash
# Verificar status do banco
rails db:status

# Resetar banco (cuidado!)
rails db:drop db:create db:migrate db:seed

# Ver rotas disponíveis
rails routes

# Console Rails (para debug)
rails console

# Ver logs em tempo real
tail -f log/development.log
```

## 🐛 Solução de Problemas


### Erro de Banco de Dados
```bash
rails db:drop db:create db:migrate db:seed
```

### Erro de Assets
```bash
rails assets:precompile
```

### Porta 3000 ocupada
```bash
rails server -p 3001
```

## 📱 Tecnologias Utilizadas

- **Backend**: Ruby on Rails 8.0
- **Frontend**: Tailwind CSS
- **Banco**: SQLite (desenvolvimento)
- **JavaScript**: Importmaps (Rails 8.0)

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

---

**Desenvolvido com ❤️ para organizar peladas com os amigos!** ⚽

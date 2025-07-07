# Contexto Técnico

## Stack Tecnológica

### Backend
- **Framework**: Ruby on Rails 8.0
- **Ruby Version**: Definida em `.ruby-version`
- **Banco de Dados**: SQLite (desenvolvimento)
- **ORM**: ActiveRecord

### Frontend
- **CSS Framework**: Tailwind CSS
- **JavaScript**: Importmaps (Rails 8.0)
- **Stimulus**: Para interatividade JavaScript

### Desenvolvimento
- **Gerenciador de Pacotes**: Bundler
- **Linter**: RuboCop
- **Deploy**: Kamal
- **Containerização**: Docker

## Estrutura Atual

### Modelos Existentes
- `Team`: Modelo básico com scaffold
  - Atributos: `name` (string)
  - Sem relacionamentos definidos

### Controllers
- `TeamsController`: CRUD completo via scaffold
- `ApplicationController`: Controller base

### Views
- Views padrão do scaffold para Teams
- Layout com Tailwind CSS configurado

## Configurações Importantes

### Banco de Dados
- Migração inicial: `CreateTeams` (20250707001301)
- Schema atual: Apenas tabela `teams`

### Assets
- Tailwind CSS configurado em `app/assets/stylesheets/tailwind/`
- JavaScript via importmaps

### Rotas
- Rotas RESTful para Teams (padrão scaffold)

## Próximos Passos Técnicos

### Modelos a Criar
1. **Player** (Jogador)
   - Nome, email, telefone, posição preferida
   - Status (ativo/inativo)
   - Histórico de participação

2. **TeamAssignment** (Atribuição de Time)
   - Relacionamento entre Player e Team
   - Data do sorteio
   - Sessão de jogo

3. **GameSession** (Sessão de Jogo)
   - Data e hora
   - Número de jogadores por time
   - Status (agendada, em andamento, finalizada)

### Funcionalidades a Implementar
1. CRUD completo para Players
2. Algoritmo de sorteio
3. Gestão de sessões de jogo
4. Interface de sorteio
5. Histórico de times

## Dependências
- Rails 8.0
- Tailwind CSS
- Stimulus
- Importmaps 
# Team Assignment Observer - Exemplos de Uso

## Visão Geral

O `TeamAssignmentObserver` é um Observer implícito implementado usando Active Record Callbacks que monitora mudanças nas atribuições de jogadores a times e executa ações específicas.

## Funcionalidades do Observer

### 1. Logging Automático
- **Criação**: Log quando jogador é atribuído a um time
- **Atualização**: Log quando jogador é transferido entre times
- **Remoção**: Log quando jogador é removido de um time

### 2. Atualização de Estatísticas
- Recalcula estatísticas da sessão automaticamente
- Atualiza `updated_at` da sessão para invalidar cache

### 3. Notificações
- Simula notificações quando jogadores são adicionados/removidos
- Pode ser expandido para email, push notifications, etc.

## Exemplos de Uso

### Console Rails

```ruby
# 1. Criar uma sessão de jogo
session = GameSession.create!(
  date: Date.today,
  status: 'scheduled'
)

# 2. Criar jogadores
player1 = Player.create!(name: "João", email: "joao@email.com", status: true)
player2 = Player.create!(name: "Maria", email: "maria@email.com", status: true)
player3 = Player.create!(name: "Pedro", email: "pedro@email.com", status: true)

# 3. Criar times
team_a = Team.create!(name: "Time A")
team_b = Team.create!(name: "Time B")

# 4. Atribuir jogadores (Observer será acionado)
assignment1 = TeamAssignment.create!(
  player: player1,
  team: team_a,
  game_session: session
)
# Log: 🎯 Jogador João foi atribuído ao time Time A na sessão 07/01/2025
# Log: 📊 Estatísticas atualizadas - Sessão 07/01/2025: 1 jogadores em 1 times
# Log: 🔔 NOTIFICAÇÃO: João foi adicionado ao time Time A

assignment2 = TeamAssignment.create!(
  player: player2,
  team: team_a,
  game_session: session
)
# Log: 🎯 Jogador Maria foi atribuído ao time Time A na sessão 07/01/2025
# Log: 📊 Estatísticas atualizadas - Sessão 07/01/2025: 2 jogadores em 1 times
# Log: 🔔 NOTIFICAÇÃO: Maria foi adicionado ao time Time A

# 5. Transferir jogador (Observer será acionado)
assignment2.update!(team: team_b)
# Log: 🔄 Jogador Maria foi transferido do time Time A para Time B na sessão 07/01/2025
# Log: 📊 Estatísticas atualizadas - Sessão 07/01/2025: 2 jogadores em 2 times

# 6. Remover jogador (Observer será acionado)
assignment1.destroy
# Log: ❌ Jogador João foi removido do time Time A na sessão 07/01/2025
# Log: 📊 Estatísticas atualizadas - Sessão 07/01/2025: 1 jogadores em 1 times
# Log: 🔔 NOTIFICAÇÃO: João foi removido do time Time A
```

### No Controller

```ruby
# app/controllers/team_assignments_controller.rb

def create
  @team_assignment = TeamAssignment.new(team_assignment_params)
  
  if @team_assignment.save
    # Observer automaticamente:
    # - Loga a atribuição
    # - Atualiza estatísticas
    # - Envia notificação
    redirect_to @team_assignment.game_session, notice: 'Jogador atribuído com sucesso!'
  else
    render :new
  end
end

def update
  if @team_assignment.update(team_assignment_params)
    # Observer automaticamente:
    # - Loga a transferência (se mudou de time)
    # - Atualiza estatísticas
    redirect_to @team_assignment.game_session, notice: 'Atribuição atualizada!'
  else
    render :edit
  end
end

def destroy
  @team_assignment.destroy
  # Observer automaticamente:
  # - Loga a remoção
  # - Atualiza estatísticas
  # - Envia notificação
  redirect_to @team_assignment.game_session, notice: 'Jogador removido do time!'
end
```

## Estrutura do Observer

### Concern: `app/models/concerns/team_assignment_observer.rb`

```ruby
module TeamAssignmentObserver
  extend ActiveSupport::Concern

  included do
    # Callbacks que funcionam como Observer
    after_create :log_player_assignment
    after_update :log_assignment_change
    after_destroy :log_player_removal
    
    after_commit :update_session_statistics, on: [:create, :update, :destroy]
    after_commit :notify_team_changes, on: [:create, :destroy]
  end

  private

  def log_player_assignment
    Rails.logger.info "🎯 Jogador #{player.name} foi atribuído ao time #{team.name}..."
  end

  def log_assignment_change
    if saved_change_to_team_id?
      Rails.logger.info "🔄 Jogador #{player.name} foi transferido..."
    end
  end

  # ... outros métodos do observer
end
```

### Modelo: `app/models/team_assignment.rb`

```ruby
class TeamAssignment < ApplicationRecord
  include TeamAssignmentObserver  # Inclui o Observer
  
  belongs_to :player
  belongs_to :team
  belongs_to :game_session
  
  # Validações...
end
```

## Vantagens do Observer

1. **Separação de Responsabilidades**: Lógica de observação separada da lógica de negócio
2. **Reutilização**: Concern pode ser usado em outros modelos
3. **Manutenibilidade**: Fácil de modificar comportamentos sem alterar o modelo principal
4. **Testabilidade**: Comportamentos podem ser testados isoladamente
5. **Extensibilidade**: Fácil adicionar novos comportamentos

## Possíveis Expansões

### 1. Sistema de Logs Persistente
```ruby
def log_player_assignment
  ActivityLog.create!(
    action: 'player_assigned',
    player: player,
    team: team,
    game_session: game_session,
    details: "Jogador #{player.name} foi atribuído ao time #{team.name}"
  )
end
```

### 2. Notificações por Email
```ruby
def notify_player_assigned
  PlayerMailer.team_assignment_notification(player, team, game_session).deliver_later
end
```

### 3. Webhooks
```ruby
def notify_team_changes
  WebhookService.new(game_session).notify_team_change(self)
end
```

### 4. Cache Invalidation
```ruby
def update_session_statistics
  Rails.cache.delete("session_stats_#{game_session.id}")
  game_session.touch
end
``` 
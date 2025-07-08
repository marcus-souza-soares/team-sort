#!/usr/bin/env ruby

# Teste para verificar se o TeamNotificationJob está funcionando
require_relative 'config/environment'

puts "🧪 Testando TeamNotificationJob..."

begin
  # Criar dados de teste
  player1 = Player.create!(name: "João", email: "joao@email.com", status: true)
  player2 = Player.create!(name: "Maria", email: "maria@email.com", status: true)
  player3 = Player.create!(name: "Pedro", email: "pedro@email.com", status: true)

  team_a = Team.create!(name: "Time A")
  team_b = Team.create!(name: "Time B")

  game_session = GameSession.create!(date: Date.today, status: 'in_progress')

  # Adicionar jogadores à sessão
  game_session.add_player(player1)
  game_session.add_player(player2)
  game_session.add_player(player3)

  # Criar atribuições de times
  TeamAssignment.create!(player: player1, team: team_a, game_session: game_session)
  TeamAssignment.create!(player: player2, team: team_a, game_session: game_session)
  TeamAssignment.create!(player: player3, team: team_b, game_session: game_session)

  puts "✅ Dados de teste criados"
  puts "📊 Sessão: #{game_session.id}"
  puts "👥 Jogadores: #{game_session.session_participants.count}"
  puts "🏆 Times: #{game_session.teams.count}"

  # Testar a query que estava causando erro
  puts "\n🔄 Testando query de jogadores por time..."

  teams_with_players = game_session.teams.includes(:players).map do |team|
    players = team.players.joins(:team_assignments)
                         .where(team_assignments: { game_session: game_session })
    {
      team: team,
      players: players,
      player_count: players.count
    }
  end

  teams_with_players.each do |team_info|
    team = team_info[:team]
    players = team_info[:players]
    puts "  🏆 #{team.name}: #{players.map(&:name).join(', ')} (#{players.count} jogadores)"
  end

  puts "\n✅ Query funcionando corretamente!"

  # Testar o job
  puts "\n🔄 Executando TeamNotificationJob..."
  TeamNotificationJob.perform_now(game_session.id)

  puts "✅ TeamNotificationJob executado com sucesso!"

rescue => e
  puts "❌ Erro no teste: #{e.message}"
  puts e.backtrace.first(5).join("\n")
end

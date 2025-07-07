``# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "🌱 Iniciando seed do banco de dados..."

# Limpar dados existentes (opcional - descomente se quiser resetar)
# Player.destroy_all
# GameSession.destroy_all
# Team.destroy_all
# TeamAssignment.destroy_all
# SessionPlayer.destroy_all

# Criar jogadores
players_data = [
  {
    name: "Marcus",
    email: "marcus@exemplo.com",
    phone: "",
    position: "Meio-campo",
    status: true
  },
  {
    name: "Fabricio",
    email: "fabricio@exemplo.com",
    phone: "",
    position: "Lateral",
    status: true
  },
  {
    name: "Otavio",
    email: "otavio@exemplo.com",
    phone: "",
    position: "Zagueiro",
    status: true
  },
  {
    name: "Douglas",
    email: "douglas@exemplo.com",
    phone: "",
    position: "Atacante",
    status: true
  },
  {
    name: "Manuel",
    email: "manuel@exemplo.com",
    phone: "",
    position: "Zagueiro",
    status: true
  },
  {
    name: "Enzo",
    email: "enzo@exemplo.com",
    phone: "",
    position: "Volante",
    status: true
  },
  {
    name: "Mateus",
    email: "mateus@exemplo.com",
    phone: "",
    position: "Atacante",
    status: true
  },
  {
    name: "Davi",
    email: "davi@exemplo.com",
    phone: "",
    position: "Atacante",
    status: true
  },
  {
    name: "Tiago",
    email: "tiago@exemplo.com",
    phone: "",
    position: "Volante",
    status: true
  },
  {
    name: "Pedro",
    email: "pedro@exemplo.com",
    phone: "",
    position: "Zagueiro",
    status: true
  }
]

puts "👥 Criando jogadores..."

players_data.each do |player_data|
  player = Player.find_or_create_by!(email: player_data[:email]) do |p|
    p.name = player_data[:name]
    p.phone = player_data[:phone]
    p.position = player_data[:position]
    p.status = player_data[:status]
  end
  puts "  ✅ #{player.name} (#{player.position})"
end

# Criar uma sessão de exemplo
puts "\n🏟️ Criando sessão de exemplo..."

game_session = GameSession.find_or_create_by!(
  date: DateTime.current + 1.day,
  status: 'scheduled'
) do |gs|
  gs.date = DateTime.current + 1.day
  gs.status = 'scheduled'
end

puts "  ✅ Sessão criada para #{game_session.date.strftime('%d/%m/%Y às %H:%M')}"

# Adicionar todos os jogadores à sessão de exemplo
puts "\n➕ Adicionando jogadores à sessão..."

Player.active.each do |player|
  unless game_session.has_player?(player)
    game_session.add_player(player)
    puts "  ✅ #{player.name} adicionado à sessão"
  end
end

puts "\n🎯 Criando alguns times de exemplo..."

# Criar alguns times de exemplo
teams_data = [
  { name: "Time A" },
  { name: "Time B" },
  { name: "Time C" }
]

teams_data.each do |team_data|
  team = Team.find_or_create_by!(name: team_data[:name])
  puts "  ✅ #{team.name} criado"
end

puts "\n🎉 Seed concluído com sucesso!"
puts "\n📊 Resumo:"
puts "  • #{Player.count} jogadores criados"
puts "  • #{GameSession.count} sessão criada"
puts "  • #{Team.count} times criados"
puts "  • #{game_session.total_players} jogadores na sessão de exemplo"
puts "\n🚀 Para testar o sistema:"
puts "  1. Acesse a sessão criada"
puts "  2. Clique em 'Sortear Times'"
puts "  3. Escolha quantos jogadores por time"
puts "  4. Veja os times serem criados automaticamente!"

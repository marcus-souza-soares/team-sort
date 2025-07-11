# Configuração do Sidekiq
require 'sidekiq'

# Configurar Redis para Sidekiq
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }

  # Configurações de logging
  config.logger.level = Logger::INFO
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end

# Configurar Active Job para usar Sidekiq
Rails.application.config.active_job.queue_adapter = :sidekiq

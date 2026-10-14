class StatusController < ApplicationController
  def show
    checks = {
      postgres: postgres_status,
      redis: redis_status
    }
    healthy = checks.values.all? { |check| check == "ok" }

    render json: { status: healthy ? "ok" : "degraded", checks: checks },
           status: healthy ? :ok : :service_unavailable
  end

  private

  def postgres_status
    ActiveRecord::Base.connection.select_value("SELECT 1")
    "ok"
  rescue StandardError
    "error"
  end

  def redis_status
    redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
    redis.ping == "PONG" ? "ok" : "error"
  rescue StandardError
    "error"
  ensure
    redis&.close
  end
end

require "test_helper"

class StatusTest < ActionDispatch::IntegrationTest
  test "reports postgres and redis as healthy" do
    get status_path

    assert_response :success

    body = JSON.parse(response.body)
    assert_equal "ok", body["status"]
    assert_equal "ok", body.dig("checks", "postgres")
    assert_equal "ok", body.dig("checks", "redis")
  end
end

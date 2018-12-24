require 'test_helper'

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  test "should get login" do
    get authentication_login_url
    assert_response :success
  end

  test "should get create_password" do
    get authentication_create_password_url
    assert_response :success
  end

  test "should get forgotten_password" do
    get authentication_forgotten_password_url
    assert_response :success
  end
end

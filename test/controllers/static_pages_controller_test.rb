require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get static_pages_home_url
    assert_response :success
  end

  test "should get sign_in" do
    get static_pages_sign_in_url
    assert_response :success
  end

  test "should get sign_up" do
    get static_pages_sign_up_url
    assert_response :success
  end

end

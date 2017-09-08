require 'test_helper'

class Api::ActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_activity = api_activities(:one)
  end

  test "should get index" do
    get api_activities_url
    assert_response :success
  end

  test "should get new" do
    get new_api_activity_url
    assert_response :success
  end

  test "should create api_activity" do
    assert_difference('Api::Activity.count') do
      post api_activities_url, params: { api_activity: {  } }
    end

    assert_redirected_to api_activity_url(Api::Activity.last)
  end

  test "should show api_activity" do
    get api_activity_url(@api_activity)
    assert_response :success
  end

  test "should get edit" do
    get edit_api_activity_url(@api_activity)
    assert_response :success
  end

  test "should update api_activity" do
    patch api_activity_url(@api_activity), params: { api_activity: {  } }
    assert_redirected_to api_activity_url(@api_activity)
  end

  test "should destroy api_activity" do
    assert_difference('Api::Activity.count', -1) do
      delete api_activity_url(@api_activity)
    end

    assert_redirected_to api_activities_url
  end
end

require 'test_helper'

module Api
  class GroupsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @api_group = api_groups(:one)
    end

    test "should get index" do
      get api_groups_url
      assert_response :success
    end

    test "should get new" do
      get new_api_group_url
      assert_response :success
    end

    test "should create api_group" do
      assert_difference('Api::Group.count') do
        post api_groups_url, params: { api_group: {} }
      end

      assert_redirected_to api_group_url(Api::Group.last)
    end

    test "should show api_group" do
      get api_group_url(@api_group)
      assert_response :success
    end

    test "should get edit" do
      get edit_api_group_url(@api_group)
      assert_response :success
    end

    test "should update api_group" do
      patch api_group_url(@api_group), params: { api_group: {} }
      assert_redirected_to api_group_url(@api_group)
    end

    test "should destroy api_group" do
      assert_difference('Api::Group.count', -1) do
        delete api_group_url(@api_group)
      end

      assert_redirected_to api_groups_url
    end
  end
end

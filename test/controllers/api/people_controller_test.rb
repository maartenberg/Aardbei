require 'test_helper'

class Api::PeopleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_person = api_people(:one)
  end

  test "should get index" do
    get api_people_url
    assert_response :success
  end

  test "should get new" do
    get new_api_person_url
    assert_response :success
  end

  test "should create api_person" do
    assert_difference('Api::Person.count') do
      post api_people_url, params: { api_person: {  } }
    end

    assert_redirected_to api_person_url(Api::Person.last)
  end

  test "should show api_person" do
    get api_person_url(@api_person)
    assert_response :success
  end

  test "should get edit" do
    get edit_api_person_url(@api_person)
    assert_response :success
  end

  test "should update api_person" do
    patch api_person_url(@api_person), params: { api_person: {  } }
    assert_redirected_to api_person_url(@api_person)
  end

  test "should destroy api_person" do
    assert_difference('Api::Person.count', -1) do
      delete api_person_url(@api_person)
    end

    assert_redirected_to api_people_url
  end
end

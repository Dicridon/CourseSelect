require 'test_helper'

class UserLoginTest < ActionDispatch::IntegrationTest

  # def setup
  #   @user = users(:peng)
  # end

  test "login with valid information" do
    get sessions_login_path
    puts @user.inspect
    post sessions_login_path(params: {session: {email: 'xiongziwei15@mails.ucas.ac.cn', password: '123456'}})
    assert_redirected_to controller: :courses, action: :index
    follow_redirect!
    assert_template 'courses/index'
  end
end

require 'test_helper'

class CoursesControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'select single courser' do 
    get root_path
    post sessions_login_url params: {
      email: 'xiongziwei15@mails.ucas.ac.cn',
      password: '123456',
    }
    assert_redirected_to courses_path
  end
end

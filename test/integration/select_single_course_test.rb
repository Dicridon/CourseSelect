require 'test_helper'

class SelectSingleCourseTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "select a course" do
    get root_path
    post_via_resirect sessions_login_path(params: {session: {email: 'xiongziwei15@mails.ucas.ac.cn', password: '123456'}})
    assert_response :found
    
  end
end

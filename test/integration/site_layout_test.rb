require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "homepage layout links" do
    get root_path
    assert_template 'sessions/new'
  end
end

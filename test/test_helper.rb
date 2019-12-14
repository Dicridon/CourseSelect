# 注意这里必须在 require rails/test_help 之前加入，否则不会生效
require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

module LoginHelper
  def login(email='xiongziwei15@mails.ucas.ac.cn', pwd='123456')
    post sessions_login_path(params: {session: {email: email, password: pwd}})
    follow_redirect!
  end


end


class ActiveSupport::TestCase
  include LoginHelper
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :users

  # Add more helper methods to be used by all tests here...
end

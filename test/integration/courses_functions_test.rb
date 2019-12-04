require 'test_helper'

class CoursesFunctionsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @course_map={
      1 => {course_code: "091M4001H", name: "计算机体系结构"},
      2 => {course_code: "091M4002H", name: "计算机网络"},
      3 => {course_code: "091M4021H-1", name: "高级软件工程"},
      4 => {course_code: "091M4021H-2", name: "高级软件工程"},
      5 => {course_code: "091M4023H", name: "数理逻辑与程序理论"},
      6 => {course_code: "091M4041H", name: "计算机算法设计与分析"},
      7 => {course_code: "091M4042H", name: "模式识别与机器学习"},
      8 => {course_code: "091M4043H", name: "高级人工智能"},
      9 => {course_code: "091M5001H", name: "VLSI测试与可测试性设计"},
      10 => {course_code: "091M5004H", name: "超大规模集成电路基础"},
      11 => {course_code: "091M5023H", name: "数据挖掘"},
      12 => {course_code: "091M5024H", name: "编译程序高级教程"},
      13 => {course_code: "091M5025H", name: "操作系统高级教程"},
      14 => {course_code: "091M5026H", name: "并发数据结构与多核编程"},
      15 => {course_code: "091M5027H", name: "形式语言与自动机理论"},
      16 => {course_code: "091M5041H", name: "人机交互"},
      17 => {course_code: "091M5042H", name: "网络数据挖掘"},
      18 => {course_code: "091M6043H", name: "认知计算"},
      19 => {course_code: "091M6045H", name: "可视化与可视计算"},
      20 => {course_code: "092M4001H", name: "最优控制理论"},
      21 => {course_code: "092M4002H", name: "模式识别"},
      22 => {course_code: "092M4022H", name: "人工智能理论与实践"},
      23 => {course_code: "092M4023H", name: "图像处理与分析"},
      24 => {course_code: "092M5002H", name: "机器人学导论"},
      25 => {course_code: "092M5006H", name: "矩阵分析与应用"},
      26 => {course_code: "092M5025H", name: "现代信息检索"},
      27 => {course_code: "092M5026H", name: "随机过程"},
      28 => {course_code: "092M6001H", name: "机器视觉及其应用"},
      29 => {course_code: "092M6002H", name: "嵌入式系统"},
      30 => {course_code: "093M1002H-1", name: "计算机算法设计与分析"},
      31 => {course_code: "093M1002H-2", name: "计算机算法设计与分析"},
      32 => {course_code: "093M1002H-3", name: "计算机算法设计与分析"},
      33 => {course_code: "093M2007H", name: "数据库新技术"},
      34 => {course_code: "09MGX005H", name: "Python语言导论"},
    }
    # Rails.application.load_seed

    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
    load "#{Rails.root}/db/seeds.rb"
  end

  test 'can login' do
    get sessions_login_path
    assert_template 'sessions/new'
    assert_response :success
    # post sessions_login_path(params: {session: {email: @user.email, password: '123456'}})
    login 'xiongziwei15@mails.ucas.ac.cn', '123456'
    assert_response :success
    assert_template 'courses/index'
  end

  test 'select one course' do
    # Rails.application.load_seed
    course_id = rand(1..34)
    course = @course_map[course_id]
    login
    get "/courses/#{course_id}/select"
    assert_response :found
    assert_redirected_to courses_path
    follow_redirect!
    assert_response :success
    assert_template 'courses/index'
    assert_select 'tr' do
      assert_select 'td', course[:course_code]
    end
  end

  test 'invalid course id' do
    login
    get "/courses/1234543213/select"
    assert_redirected_to list_courses_path
    follow_redirect!
    assert_not_nil flash[:danger]
  end

  test 'duplicated course id' do
    course_id = rand(1..34)
    course = @course_map[course_id]
    login
    get "/courses/#{course_id}/select"
    assert_response :found
    assert_redirected_to courses_path
    follow_redirect!
    assert_response :success
    assert_template 'courses/index'
    assert_select 'tr' do
      assert_select 'td', course[:course_code]
    end
    get "/courses/#{course_id}/select"
    assert_redirected_to list_courses_path
    follow_redirect!
    assert_not_nil flash[:danger]
  end

  test 'quit a course' do
    puts current_user.inspect
  end
end

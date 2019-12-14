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
      assert_select 'td', {text: course[:course_code]}
    end
    get "/courses/#{course_id}/select"
    assert_redirected_to list_courses_path
    follow_redirect!
    assert_not_nil flash[:danger]
  end

  test 'quit a course' do
    course_id = rand(1..34)
    course = @course_map[course_id]
    login
    get "/courses/#{course_id}/select"
    follow_redirect!
    get "/courses/#{course_id}/quit"
    assert_select 'tr', false
  end

  test 'batch courses' do
    login
    request = '/courses/batch?utf8=%E2%9C%93&course%5B%5D=34&course%5B%5D=24&course%5B%5D=15&commit=%E6%89%B9%E9%87%8F%E6%8F%90%E4%BA%A4'
    get request
    follow_redirect!
    assert_not_nil flash[:success]
  end

  test 'search course type' do
    types = [ '%E4%B8%93%E4%B8%9A%E6%99%AE%E5%8F%8A%E8%AF%BE',
              '%E5%85%AC%E5%85%B1%E9%80%89%E4%BF%AE%E8%AF%BE',
              '%E4%B8%80%E7%BA%A7%E5%AD%A6%E7%A7%91%E6%A0%B8%E5%BF%83%E8%AF%BE',
              '%E4%B8%93%E4%B8%9A%E6%A0%B8%E5%BF%83%E8%AF%BE',
              '%E4%B8%93%E4%B8%9A%E7%A0%94%E8%AE%A8%E8%AF%BE',
              '%E4%B8%80%E7%BA%A7%E5%AD%A6%E7%A7%91%E6%99%AE%E5%8F%8A%E8%AF%BE' ]
    encodings = { '%E4%B8%93%E4%B8%9A%E6%99%AE%E5%8F%8A%E8%AF%BE' => '专业普及课',
                  '%E5%85%AC%E5%85%B1%E9%80%89%E4%BF%AE%E8%AF%BE' => '公共选修课',
                  '%E4%B8%80%E7%BA%A7%E5%AD%A6%E7%A7%91%E6%A0%B8%E5%BF%83%E8%AF%BE' => '一级学科核心课',
                  '%E4%B8%93%E4%B8%9A%E6%A0%B8%E5%BF%83%E8%AF%BE' => '专业核心课',
                  '%E4%B8%93%E4%B8%9A%E7%A0%94%E8%AE%A8%E8%AF%BE' => '专业研讨课',
                  '%E4%B8%80%E7%BA%A7%E5%AD%A6%E7%A7%91%E6%99%AE%E5%8F%8A%E8%AF%BE' => '一级学科普及课'}
    
    login
    idx = rand(0..5)
    course_encoding = types[idx]
    course_type = encodings[course_encoding]
    get "/courses/search?utf8=%E2%9C%93&course_type=#{course_encoding}&empty_course=&keyword=&commit=Search"
    puts "search #{course_type}"
    assert_select 'tr' do
      types.each_with_index do |t, i|
        if i != idx
          assert_select 'td', {count: 0, text: encodings[t]}
        else
          assert_select 'td', {text: encodings[t]}
        end
      end
    end
  end

  test 'search keyword' do
    login
    get "/courses/search?utf8=%E2%9C%93&course_type=&empty_course=&keyword=Python&commit=Search"
    assert_select 'tr' do
      assert_select 'td', {count: 1, text: 'Python语言导论'}
    end
  end

  test 'search empty' do
    login
    get "/courses/search?utf8=%E2%9C%93&course_type=&empty_course=%E6%98%AF&keyword=&commit=Search"
    assert_select 'tr' do
      assert_select 'td', {text: /09[0-9a-zA-Z]{6}H-{0,1}\d{0,1}/}
    end
  end

  test 'summery' do
    login
    course_id = rand(1..34)
    course = @course_map[course_id]
    get "/courses/#{course_id}/select"
    follow_redirect!
    get "/courses/summery"
    assert_select 'tr' do
      assert_select 'td', {text: /[1-9]+/}
    end
  end

  test 'schedule' do
    login
    request = '/courses/batch?utf8=%E2%9C%93&course%5B%5D=34&course%5B%5D=24&course%5B%5D=15&commit=%E6%89%B9%E9%87%8F%E6%8F%90%E4%BA%A4'
    get request
    follow_redirect!
    get '/courses/schedule'
    assert_template 'courses/schedule'
  end

  test 'upload' do
    login
    tempfile = Object.new
    tempfile.define_singleton_method(:path) {Rails.root.join('test/files/schedule.xlsx')}
    f = ActionDispatch::Http::UploadedFile.new original_filename: 'schedule.xlsx', tempfile: tempfile
    a = [1, 2, 3]
    post '/courses/upload', params: {excel: a}
    follow_redirect!
    get '/courses'
    assert_select 'tbody' do
      assert_select 'tr' do
        assert_select 'td', {:text => '09MGX005H'}
        assert_select 'td', {:text => '091M4021H-1'}
        assert_select 'td', {:text => '091M5027H'}
      end
    end
  end
end

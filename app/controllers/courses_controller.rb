class CoursesController < ApplicationController
  include CoursesHelper

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :open, :close]#add open by qiao
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: '新课程申请成功'}
    else
      flash[:warning] = '信息填写有误,请重试'
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => '更新成功'}
    else
      flash={:warning => '更新失败'}
    end
    redirect_to courses_path, flash: flash
  end

  def open
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: true)
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end

  def close
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: false)
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  #-------------------------for students----------------------

  def list
    #-------QiaoCode--------
    if @search_course
      logger.debug 'Debug info: in list @search_course is ' + @search_course.to_s
      @course = @courses
      @search_course = false
      return
    end
    @courses = Course.where(:open=>true).paginate(page: params[:page], per_page: 4)
    @course = @courses-current_user.courses
    tmp=[]
    @course.each do |course|
      if course.open==true
        tmp<<course
      end
    end
    @course=tmp
  end

  def summery
    @credits = [[0, 0, 0], [0, 0, 0]]
    current_user.courses.each do |course|
      credit = course.credit[/\d\.\d/].to_f
      @credits[0][2] += credit
      case course.course_type
        when '公共选修课' || '一级学科普及课'
          @credits[0][0] += credit
        else
          @credits[0][1] += credit
      end
    end
    @extra_info = @credits.inspect
  end

  def schedule
    time = {
      '周一' => 1,
      '周二' => 2,
      '周三' => 3,
      '周四' => 4, 
      '周五' => 5,
      '周六' => 6,
      '周日' => 7
    }.freeze
    classes = []
    current_user.courses.each do |c|
      times = c.course_time.match /(\d+)-(\d+)/
      start = times[1]
      stop = times[2]
      classes << {:name => c.name,
                  :room => c.class_room,
                  :week => c.course_time[0,2],
                  :start => start.to_i,
                  :duration => stop.to_i - start.to_i + 1}
    end
    courses_time = ['8:30-9:20',
                    '9:20-10:10',
                    '10:30-11:20',
                    '11:20-12:10',
                    '13:30-14:20',
                    '14:20-15:10',
                    '15:30-16:20',
                    '16:20-17:10',
                    '19:00-19:50',
                    '19:50-20:40',
                    '20:50-21:40']
    sche = Array.new(11) {Array.new(7)}
    classes.each do |c|
      sche[c[:start]-1][time[c[:week]]-1] = c
      (1...c[:duration]).each do |e|
        sche[c[:start]-1+e][time[c[:week]]] = :skip
      end
    end
    sche.each_with_index do |line, i|
      line.unshift courses_time[i]
    end
    @classes = sche
    # @extra_info = @classes
  end

  def select
    logger.debug "Debug info: get id: #{params[:id]}"
    @course=Course.find_by_id(params[:id])
    path = list_courses_path
    flash = {}
    if @course && @course.open
      flash = select_check @course
      if flash[:success]
        current_user.courses<<@course
        path = courses_path
      end
    else
      flash[:danger] = "Course ID #{params[:id]} is invalid"
    end
    redirect_to path, flash: flash
  end

  def quit
    @course=Course.find_by_id(params[:id])
    if @course
      current_user.courses.delete(@course)
      flash={:success => "成功退选课程: #{@course.name}"}
      redirect_to courses_path, flash: flash
    end
  end

  def batch
    success = []
    errors = []
    msg = {}
    no_course = true
    unless params[:course].nil?
      no_course = false
      params[:course].each do |id|
        course = Course.find_by_id(id)
        if course && course.open
          flash = select_check course
          # add as many courses as possible
          if flash[:success]
            current_user.courses << course
            success << flash[:success]
          else
            errors << flash[:danger]
          end
        end
      end
    end
    
    msg[:success] = success.join('\n') unless success.empty?
    msg[:danger] = errors.join('\n') unless errors.empty?
    msg[:danger] = 'Please select at least one valid course' if no_course
    redirect_to list_courses_path, flash: msg
  end

  def search
    unless params[:keyword].empty?
      @courses = Course.where('name LIKE ?', "%#{params[:keyword]}%").where(:open=>true)
    else
      @courses = Course.where(:open=>true)
    end
    logger.debug 'Debug Info: ' + @courses.inspect

    unless params[:course_type].empty?
      @courses = @courses.where(:course_type => params[:course_type])
    end
    logger.debug 'Debug Info: ' + @courses.inspect
    unless params[:empty_course].empty?
      @courses = @courses.where('limit_num != student_num')
    end
    logger.debug 'Debug Info: ' + @courses.inspect
    @courses = @courses.paginate(page:  params[:page], per_page: 4)
    # @courses -= current_user.courses
  end

  def upload
    if params[:excel].original_filename.end_with? 'xlsx'
      data = Roo::Spreadsheet.open(params[:excel].path).to_s
      @courses = data.scan(/@cell_value="(09[0-9a-zA-Z]{6}H-{0,1}\d{0,1}?)"/).flatten!
      success = []
      errors = []
      msg = {}
      unless @courses.nil?
        @courses.each do |c|
          # course = Course.where(course_code => c)
          logger.debug "Debug info: Selecting a course #{c}"
          course = Course.find_by(course_code: c)
          if course
            flash = select_check course
            # add as many courses as possible
            if flash[:success]
              current_user.courses << course
              success << flash[:success]
            else
              errors << flash[:danger]
            end
          end
        end
      else
        msg[:danger] = 'courses in your spreadsheet are invalid'
      end
      msg[:success] = success.join('\n') unless success.empty?
      msg[:danger] = errors.join('\n') unless errors.empty?
    else
      msg = {danger: 'please upload a excel spreadsheet'}
    end
    redirect_to list_courses_path, flash: msg
  end
  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses.paginate(page: params[:page], per_page: 4) if teacher_logged_in?
    @course=current_user.courses.paginate(page: params[:page], per_page: 4) if student_logged_in?
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end
end

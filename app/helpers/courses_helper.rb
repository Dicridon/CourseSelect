module CoursesHelper
    def select_check(course)
      course_info = "#{course.name}(#{course.course_code})"
      contension_msg = contension? course
      if current_user.courses.include?(course)
        return {:danger => "重复选课: #{course_info}"}
      elsif course.limit_num && course.limit_num < course.student_num + 1
        return {:danger => "超过限选人数: #{course_info}"}
      elsif contension_msg
        return {:danger => "课程时间冲突：#{course_info}和#{contension_msg}冲突"}
      else
        return {:success => "选课成功：#{course_info}"}
      end
    end
    
    def contension?(course)
      standard_info = []
      current_user.courses.each do |course|
        weeks = course.course_week.match(/(\d+)-(\d+)/)
        time = course.course_time.match(/(\d+)-(\d+)/)
        standard_info << {:code => course.course_code, 
                          :name => course.name, 
                          :weeks => (weeks[1].to_i)..(weeks[2].to_i), 
                          :week => course.course_time[1],
                          :time => (time[1].to_i)..(weeks[2].to_i)}
      end
  
      course_weeks = course.course_week.match(/(\d+)-(\d+)/)
      course_time = course.course_time.match(/(\d+)-(\d+)/)
      weeks = (course_weeks[1].to_i)..(course_weeks[2].to_i)
      week = course.course_time[1]
      time = (course_time[1].to_i)..(course_time[2].to_i)
      
      
      standard_info.each do |c|
        if overlap(c[:weeks], weeks) && overlap(c[:time], time) && c[:week] == week
          return "#{c[:name]}(#{c[:code]})" 
        end
      end
      return nil
    end
    
    def overlap(a, b)
      b.begin <= a.end && a.begin <= b.end
    end
end
class HomeController < ApplicationController

  def index
    @response = self.api('org')
  end

  def school
    if params[:org].nil?
      redirect_to '/'
      return
    end
    @org = params[:org]
    @response = self.api('org/' + @org + '/school')
  end

  def student
    if params[:org].nil? || params[:school].nil?
      redirect_to '/'
      return
    end
    @org = params[:org]
    @school = params[:school]
    @response = self.api('org/' + @org + '/school/' + @school + '/student')
  end

  def me
    if params[:org].nil? || params[:student].nil?
      redirect_to '/'
      return
    end
    @org = params[:org]
    @student_id = params[:student]
    @student = self.api('org/' + @org + '/student/' + @student_id)
    student_courses = self.api('org/' + @org + '/student/' + @student_id + '/course_grade')

    sections = {}
    courses = {}

    @student_grades = {}
    student_courses['data'].each do |stu|
      section_id = stu['section']['id']
      sections[section_id] ||= self.api('org/' + @org + '/section/' + section_id)
      course_id = sections[section_id]['course']['id']
      courses[course_id] ||= self.api('org/' + @org + '/course/' + course_id)

      @student_grades[section_id] ||= []
      @student_grades[section_id] << {
        :grade => stu['grade'],
        :percent => stu['percent'],
        :section_id => section_id,
        :course_id => course_id,
        :course_name => courses[course_id]['name'],
        :start_date => Date.strptime(stu['start_date']),
        :end_date => Date.strptime(stu['end_date'])
      }
    end

    @suggested_courses = {}
    khan_course = self.khan()

    @formatted = []
    @student_grades.each do |id, sec|
      data = []
      sec.each do |grade|
        data << [grade[:end_date], grade[:percent]]
      end
      @formatted << {
        :name => sec[0][:course_name],
        :data => data.sort_by { |hsh| hsh[0] }
      }

      if @suggested_courses[sec[0][:course_name]].nil?
        khan.keys.each do |k|
          if m = sec[0][:course_name].match(k)
            num = sec[0][:course_name][m.end(0), m.end(0) + 3].to_i
            khan[k].each do |info|
              if num >= info[:lower] && num <= info[:upper]
                @suggested_courses[sec[0][:course_name]] = info
                break
              end
            end
          end
        end
      end
    end
  end


  protected

    def api(path)
      require 'net/https'
      key = 'fcb8534c-e4ee-4e02-8b22-9328db1dac18'
      url = "https://v1.api.learnsprout.com/" + path +  "?apikey=" + key

      parsed_url = URI.parse(url)
      http = Net::HTTP.new(parsed_url.host, parsed_url.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(parsed_url.request_uri)

      JSON.parse(http.request(request).body)
    end

    def khan
      return {
        "Math" => [
          {:lower => 100,:upper => 149, :course => "Arithmetic and Pre-Algebra", :link => "http://www.khanacademy.org/math/arithmetic"},
          {:lower => 150,:upper => 199, :course => "Algebra", :link => "http://www.khanacademy.org/math/algebra"},
          {:lower => 200,:upper => 249, :course => "Geometry", :link => "http://www.khanacademy.org/math/geometry"},
          {:lower => 250,:upper => 299, :course => "Probability & Statistics", :link => "http://www.khanacademy.org/math/probability"},
          {:lower => 300,:upper => 349, :course => "Precalculus", :link => "http://www.khanacademy.org/math/precalculus"},
          {:lower => 350,:upper => 399, :course => "Calculus", :link => "http://www.khanacademy.org/math/calculus"}
        ],
        "Computer Lab" => [
          {:lower => 300,:upper => 349, :course => "Programming Basics", :link => "http://www.khanacademy.org/cs/tutorials/programming-basics"},
          {:lower => 350,:upper => 399, :course => "User Interaction", :link => "http://www.khanacademy.org/cs/tutorials/user-interaction"},
          {:lower => 400,:upper => 449, :course => "Animation", :link => "http://www.khanacademy.org/cs/tutorials/animation"}
        ],

        "Art" => [
          {:lower => 450,:upper => 499, :course => "Art History I", :link => "http://www.khanacademy.org/humanities/art-history"},
          {:lower => 500,:upper => 7000000000, :course => "Art History II", :link => "http://www.khanacademy.org/humanities/art-history"}
        ]
      }
    end
end

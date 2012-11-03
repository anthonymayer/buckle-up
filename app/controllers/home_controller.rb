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
end

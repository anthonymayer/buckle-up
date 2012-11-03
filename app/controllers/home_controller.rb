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

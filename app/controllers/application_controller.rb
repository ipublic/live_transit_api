class ApplicationController < ActionController::Base
  # protect_from_forgery
  after_filter :set_access_control_headers

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = "*"
  end


  def process_not_found
    respond_to do |format|
      format.html {
        self.formats = [:json]
        render :content_type => "application/json", :template => "shared/not_found", :status => 404
      }
      format.json { render :template => "shared/not_found", :status => 404 }
      format.xml { render :template => "shared/not_found", :status => 404 }
    end
  end
end

class ApplicationController < ActionController::Base
  # protect_from_forgery


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

class ServicesController < ApplicationController
  before_action :require_loggedin,:get_organizations, :get_members
  include_all_helpers
  def create
    
  end

  def index
    @org_url = params['organization']
    response = send_get("/#{@org_url}/services")
    if response.code == 200

      if response.body != 'null'
        @services = JSON.parse(response.body)
        @organizations.each {
          |org|
          if org["name"] == @org_url 
            @role = org["role"]
          end
        }
      end

    else
      response response.code
    end
    :get_members
  end

  def store
    @org = params['organization']
    response = HTTParty.post(
        "#{ENV["REUNI_HOST"]}/#{@org}/services",
        :body => {
            :name => params['service_name'],
            :configuration => params['configuration']
        }.to_json,
        :headers => {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{cookies[:token]}"
        }
    )
    if response.code == 201
      response2 = HTTParty.post(
          "#{ENV["REUNI_HOST"]}/#{@org}/#{params['service_name']}/namespaces",
          :body => {
              :namespace => 'default',
              :configurations => JSON.parse(params['configuration'])
          }.to_json,
          :headers => {
              'Content-Type' => 'application/json',
              'Authorization' => "Bearer #{cookies[:token]}"
          }
      )
      if response2.code != 201
        @error = JSON.parse(response2.body)
        render 'services/create'
      else
        redirect_to "/#{@org}/services"
      end
    else
      @error = JSON.parse(response.body)
      render 'services/create'
    end


  end

  def service_form

  end

  def service_form_handler
    puts "Heloooo"
  end
end

# config/initializers/swagger-docs.rb
#Swagger::Docs::Config.register_apis({
#  "1.0" => {
#    :api_file_path => "public/",
#    :api_extention_type => :json,
#    :base_path => "http://localhost:3000",
#    :clean_directory => true,
#    :parent_controller => ApplicationController,
#    :base_api_controller => ApplicationController,
#    :attributes => {
#      :info => {
#        "title" => "komunikator",
##      }
#    }
#  }
#})

Swagger::Docs::Config.register_apis({
  "1.0" => {
      #:api_extention_type => :json,
      :api_file_path => "public/",
      :base_path => "http://localhost:3000",
      :controller_base_path => "",
      :clean_directory => true,
      #:parent_controller => ActionController,
      #:base_api_controller => ApplicationController,
      :attributes => {
        :info => {
        "title" => "komunikator",
        "description" => "Example rails app"
        }
      }
    }
})

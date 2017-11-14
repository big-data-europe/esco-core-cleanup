require 'net/http'
require 'json'
# require 'pry'# for breakpoints

require_relative 'lib/file_handler.rb'
require_relative 'lib/helpers/param.rb'
helpers Helpers::ParamHandler

###############
#### Calls ####
###############

# variable to handle reading from the config files
config_handler = FileHandler.new

config_dir_location = "/config"
config_dir_location = ENV["CONFIG_DIR_CLEANUP"] if ENV["CONFIG_DIR_CLEANUP"]
config_handler.set_dir(config_dir_location)


###
# Depending on the existence of the delete parameter
# either calls the parameter handling
# or gives an error 404
###
delete '/clean' do
    content_type 'application/vnd.api+json'

    delete_params = []
    delete_params = params[:delete].split(',') if params[:delete]

    graph_param = params[:graph].to_s

    return_message = ''
    if delete_params && !delete_params.empty?
        config_handler.refresh_config
        return_message = handle_parameter(config_handler, delete_params, graph_param)
    else
        error("Missing or empty 'delete' parameter", status = 400)
    end
    status 200
    create_meta_json(return_message)
end

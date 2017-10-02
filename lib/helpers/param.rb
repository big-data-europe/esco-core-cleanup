require_relative 'clean.rb'
helpers Helpers::Clean

###
# Helper module for parameters
#
# requires clean module
###

module Helpers
    module ParamHandler
        ###
        # Method to decide which cleaning Method
        # should be called
        # if it is not existing, then error 422
        ###
        private

        def handle_parameter(config, delete_params, graph_param)
            status_message = ''
            delete_params.each do |delete_param|
                next unless config.include?(delete_param)
                clean(config, delete_param, graph_param)
                status_message += delete_param.capitalize + ' data was deleted. '
            end
            status_message
        end

        ###
        # Creates a meta json and return timestamp
        #
        # format: JSON API
        ###
        private

        def create_meta_json(message)
            meta = {}
            meta['message'] = message
            result = {}
            result['meta'] = meta
            result.to_json
        end
    end
end

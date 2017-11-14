###
# Helper module for cleaning methods
###

module Helpers
    module Clean
        ###
        # Method to clean data from the database
        #
        # Use this method when pulling the query from the
        # config files is enough
        ###
        private

        def clean(config, delete_param, graph_param)
            queries = config.get_queries.fetch(delete_param)
            queries.each do |query|
                do_update(config, query, graph_param)
            end
        end

        ###
        # Method to change time limit in query
        #
        # if 'change_the_date' exists
        # it will replace it with today's date
        #
        # time format: YYYY-mm-dd
        ###
        private

        def change_time_in_query(query)
            today = Time.now
            today = today.strftime('%F').to_s
            query.gsub(/change_the_date/, today)
        end

        ###
        # Method to put graph uuid into query
        #
        # if graph_param exists
        # it will replace it the uuid
        # otherwise with a ?c
        ###
        private

        def change_graph_param(query, graph_param)
            graph = unless graph_param.empty?
                        " '" + graph_param + "'"
                    else
                        '?graph_uuid'
                    end
            query.gsub(/change_graph_uuid/, graph)
        end

        ###
        # Method to return basic prefixes
        ###
        private
        def prefix(config)
            if config.get_prefixes.empty?
                prefixes = "PREFIX mu: <http://mu.semte.ch/vocabularies/core/>\n"
            else
              prefixes = ""
              config.get_prefixes.each do |prefix|
                  prefixes += prefix + "\n"
              end
            end
            prefixes
        end

        ###
        # Method to return with <application_graph>
        ###
        private

        def graph
            "WITH <http://mu.semte.ch/application>\n"
        end

        ###
        # Method to run queries
        #
        # add prefixes
        # add graph
        ###

        private

        def do_update(config, query, graph_param)
            # We change the transaction level to avoid deadlocks for those queries
            query = change_time_in_query(query)
            query = change_graph_param(query, graph_param)
            query = prefix(config) + graph + query
            update(query)
        end
    end
end

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
            queries = config.fetch(delete_param)
            queries.each do |query|
                do_update(query, graph_param)
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

        def prefix
            prefix = "prefix mu: <http://mu.semte.ch/vocabularies/core/>\n"
            prefix += "prefix mp: <http://sem.tenforce.com/vocabularies/mapping-platform/>\n"
            prefix += "prefix esco: <http://data.europa.eu/esco/model#>\n"
            prefix += "prefix escolabelrole: <http://data.europa.eu/esco/LabelRole#>\n"
            prefix += "prefix translation: <http://translation.escoportal.eu/>\n"
            prefix += "prefix translationvocab: <http://translation.escoportal.eu/vocab/>\n"
            prefix += "prefix skosxl: <http://www.w3.org/2008/05/skos-xl#>\n"
            prefix += "prefix skos: <http://www.w3.org/2004/02/skos/core#>\n\n"

            prefix
        end

        ###
        # Method to return with <application_graph>
        ###
        private

        def graph
            "with <http://mu.semte.ch/application>\n"
        end

        ###
        # Method to run queries
        #
        # add prefixes
        # add graph
        ###

        private

        def do_update(query, graph_param)
            query = change_time_in_query(query)
            query = change_graph_param(query, graph_param)
            query = prefix + graph + query
            update(query)
        end
    end
end

class FileHandler
    ###
    # Init, creates the config
    # and fills it with data from the resource file
    ###
    def initialize
        @config = {}
        @dir = ''
    end

    ###
    # Reads the config.json config file and stores it in the @config variable
    ###
    def refresh_config
        filepath = get_file_path('delete_queries.json')
        @config = read_file(filepath, 'queries')
    end

    ###
    # Reads the file, parses the JSON and returns the value of the key
    # read ensures the file is closed before returning
    # http://ruby-doc.org/core-2.3.1/IO.html
    ###
    def read_file(path, key)
        file = IO.read(path)
        JSON.parse(file)[key]
    end

    ###
    # Refreshes the value of the @config variable
    # and returns the copy of the @config variable
    ###
    def get_config
        refresh_config
        @config.clone
    end

      ###
    # Set the new dir variable
    ###
    def set_dir(new_dir)
        # checking for / at the end of the env variable
        new_dir = '' unless new_dir
        new_dir += '/' unless new_dir[-1, 1] == '/'
        @dir = new_dir
    end

    ###
    # Returns relative path to resource file
    ###
    def get_file_path(filename)
        # dir = File.realdirpath(File.join(File.dirname(__FILE__), '..', 'config'))
        File.join(@dir, filename)
    end
end

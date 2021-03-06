# encoding: UTF-8

module Rakali
  class Converter

    # Default options.
    DEFAULTS = {
      'from'          => { 'format' => 'md' },
      'to'            => { 'folder' => nil, 'format' => 'html' },
      'schema'        => 'default.json',
      'citations'     => false,
      'strict'        => false,
      'merge'         => false,
      'options'       => {}
    }

    attr_accessor :config, :documents, :errors

    def initialize(file, options = {})
      begin
        config = read_config_file(file)

        # deep merge defaults to preserve nested keys
        @config = Utils.deep_merge_hashes(DEFAULTS, config)

        # print configuration
        Rakali.logger.info "Configuration:", to_yaml

        from_folder = @config.fetch('from').fetch('folder')
        from_format = @config.fetch('from').fetch('format')
        documents = Dir.glob("#{from_folder}/*.#{from_format}")

        # merge all documents into one file if merge flag is set
        # otherwise iterate through each file in source folder
        if @config.fetch('merge')
          Rakali::Document.new(documents, @config)
        else
          documents.each { |document| Rakali::Document.new(document, @config) }
        end
      rescue KeyError => e
        Rakali.logger.abort_with "Fatal:", "Configuration #{e.message}."
      rescue => e
        Rakali.logger.abort_with "Fatal:", "#{e.message}."
      end
    end

    def read_config_file(file)
      # use an empty hash if the file is empty
      SafeYAML.load_file(file) || {}
    rescue SystemCallError
      Rakali.logger.abort_with "Fatal:", "Configuration file not found: \"#{file}\"."
    end

    def from_json(string)
      JSON.parse(string)
    rescue JSON::ParserError, TypeError
      nil
    end

    def to_json
      content.to_json
    end

    def to_yaml
      yaml = config.to_yaml.gsub(/---\n/, '').split("\n")
      yaml.join("\n                    ")
    end
  end
end

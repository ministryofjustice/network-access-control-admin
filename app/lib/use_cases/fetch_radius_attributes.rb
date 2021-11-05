module UseCases
  class FetchRadiusAttributes
    def initialize(gateway:, output:)
      @gateway = gateway
      @output = output
    end

    def call
      files = gateway.list_object_keys("radius_dictionaries").contents

      files.each do |file_d|
        file_name = file_d.key.remove("radius_dictionaries/")
        gateway.get_object(file_d.key, "#{output}#{file_name}")
      end
    end

  private

    attr_reader :gateway, :output
  end
end

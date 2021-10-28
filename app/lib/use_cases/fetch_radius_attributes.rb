module UseCases
  class FetchRadiusAttributes
    def initialize(gateway:, output:)
      @gateway = gateway
      @output = output
    end

    def call
      files = gateway.list_object_keys("radius_dictionaries").contents

      File.open(output, "w") do |output_file|
        files.each do |file|
          content = gateway.read(file.key).split("\n")

          content.each do |line|
            next unless line.include?("ATTRIBUTE")

            output_file.write(line.split.second, "\n")
          end
        end
      end
      pp "Fetched #{File.read(output).split.count} RADIUS dictionary attibutes"
    end

  private

    attr_reader :gateway, :output
  end
end

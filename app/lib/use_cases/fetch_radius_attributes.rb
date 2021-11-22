module UseCases
  class FetchRadiusAttributes
    def initialize(gateway:, output:)
      @gateway = gateway
      @output = output
    end

    def call
      fetch_dictionaries_from_s3
      extracted_attributes
    end

  private

    def fetch_dictionaries_from_s3
      files = gateway.list_object_keys("radius_dictionaries").contents

      files.each do |file_d|
        file_name = file_d.key.remove("radius_dictionaries/")
        gateway.read(file_d.key, "#{output}#{file_name}")
      end
    end

    def extracted_attributes
      attribute_lines.map { |a| a.split(" ")[1] }
    end

    def attribute_lines
      active_dictionaries.map { |d|
        File.read("#{output}/#{d}").each_line.select { |l| l.match?(/ATTRIBUTE/) }
      }.flatten!
    end

    def active_dictionaries
      active_dictionary_lines.map { |match| match.split(" ")[1] }
    end

    def active_dictionary_lines
      File.read("#{output}/dictionary").each_line.select { |l| l.match?(/^\$INCLUDE/) }
    end

    attr_reader :gateway, :output
  end
end

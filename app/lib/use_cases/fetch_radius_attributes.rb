class UseCases::FetchRadiusAttributes
  def initialize(gateway:, output:, files:)
    @gateway = gateway
    @files = files
    @output = output
  end

  def call
    File.open(output, "w") do |output_file|
      files.each do |file|
        content = gateway.read(file).split("\n")

        content.each do |line|
          next unless line.include?("ATTRIBUTE")

          output_file.write(line.split.second, "\n")
        end
      end
    end
  end

private

  attr_reader :gateway, :output, :files
end

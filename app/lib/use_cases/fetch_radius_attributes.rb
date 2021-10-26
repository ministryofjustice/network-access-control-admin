class UseCases::FetchRadiusAttributes
  def initialize(gateway:, output:)
    @gateway = gateway
    @output = output
  end

  def call
    content = gateway.read.split("\n")

    File.open(output, "w") do |output_file|
      content.each do |line|
        next unless line.include?("ATTRIBUTE")

        output_file.write(line.split.second, "\n")
      end
    end
  end

private

  attr_reader :gateway, :output
end

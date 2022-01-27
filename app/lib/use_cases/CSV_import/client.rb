module UseCases
  module CSVImport
    class Client < Client
      def skip_validation?
        true
      end
    end
  end
end

module UseCases
  module CSVImport
    class Policy < Policy
    private

      def skip_uniqueness_validation?
        true
      end
    end
  end
end

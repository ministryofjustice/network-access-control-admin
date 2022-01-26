module UseCases
  module CSVImport
    class Site < Site
      def skip_uniqueness_validation?
        true
      end
    end
  end
end

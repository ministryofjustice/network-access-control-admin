class BasePresenter
  attr_reader :record

  def initialize(record)
    @record = record
  end
end

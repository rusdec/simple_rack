class Controller
  attr_reader :params

  def initialize(query_string)
    @params = query_string
  end

  # Templete method
  def index; end
end

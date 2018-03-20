class TimeController < Controller
  def index
    my_time = MyTime.new
    my_time.time(params['format'])
  end
end

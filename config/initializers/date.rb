class Date
  def holidays?
    [0,6].include? wday
  end
end

class MovieTest
  def initialize(mean, stddev, rms, to_a)
    @mean = mean
    @stddev = stddev
    @rms = rms
    @to_a = to_a
  end

  def mean
    return @mean
  end

  def stddev
    return @stddev
  end

  def rms
    return @rms
  end

  def to_a
    return @to_a
  end
end

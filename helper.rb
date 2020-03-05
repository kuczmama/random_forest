class String
  def is_float?
    to_f.to_s == self
  end

  def is_int?
    to_i.to_s == self
  end
end
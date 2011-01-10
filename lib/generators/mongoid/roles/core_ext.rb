class String
  def as_filename
    self.underscore  
  end
end

class Symbol
  def as_filename
    self.to_s.underscore  
  end
end
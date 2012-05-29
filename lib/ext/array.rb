require 'fuzzy/index'

class Array

  def fuzzy(query, count = nil)
    @fuzzy_index ||= Fuzzy::Index.new(:array => self)
    
    case count
    when :all
      @fuzzy_index.find(query)
    when Integer
      @fuzzy_index.find(query).take(count)
    else
      @fuzzy_index.find(query).first
    end
  end

  def fuzzy_index
    Fuzzy::TfIdfIndex.new_for(self)
  end
end
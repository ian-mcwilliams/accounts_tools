module AccountsHelpers

  def self.pounds_to_pence(input)
    if input.is_a?(String) && !input.empty? && input[/^(-)?(\d+)?(\.)?(\d+)?$/].nil?
      raise("string must be a valid number or float format, got: #{input}")
    end
    if (input.is_a?(String) || input.is_a?(Float)) && input.to_s.index('.') && input.to_s.reverse.index('.') > 2
      raise("max 2 decimal places allowed, got: #{input}")
    end
    if input.is_a?(String)
      return input.to_i * 100 unless input.index('.')
      return input.delete('.').to_i * 100 if input[-1] == '.'
      return input.delete('.').to_i * 10 if input[-2] == '.'
      return input.delete('.').to_i if input[-3] == '.'
    elsif input.is_a?(Fixnum)
      return input * 100
    elsif input.is_a?(Float)
      return pounds_to_pence(input.to_s)
    elsif input.nil?
      return 0
    else
      raise("class not valid: #{input.class}")
    end
  end

end

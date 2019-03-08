module LogHelpers

  def self.completion_log(log_hash, &block)
    validate_log_hash(log_hash)
    yield
  end

  def self.validate_log_hash(log_hash)
    raise("log_hash must be a Hash, got: #{log_hash.class}") unless log_hash.is_a?(Hash)
    raise('log_hash must contain a :static_text key') unless log_hash.has_key?(:static_text)
    unless log_hash[:static_text].is_a?(String)
      raise("static_text must be a String, got: #{log_hash[:static_text].class}")
    end
    raise('static_text must not be empty') if log_hash[:static_text].empty?
    if log_hash.has_key?(:wait_text) && !log_hash[:wait_text].is_a?(String)
      raise("wait_text must be a String if provided, got: #{log_hash[:wait_text].class}")
    end
    raise('wait_text must not be empty') if log_hash.has_key?(:wait_text) && log_hash[:wait_text].empty?
    if log_hash.has_key?(:done_text) && !log_hash[:done_text].is_a?(String)
      raise("done_text must be a String if provided, got: #{log_hash[:done_text].class}")
    end
    raise('done_text must not be empty') if log_hash.has_key?(:done_text) && log_hash[:done_text].empty?
  end

end
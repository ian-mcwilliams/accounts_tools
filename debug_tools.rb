def oph(output_str)
  wrapped_str = inset_str("   #{output_str}   ", '=', 100)
  puts '===================================================================================================='
  puts wrapped_str
  puts '===================================================================================================='
end

def inset_str(str, wrapper, length)
  return_str = "#{str}"
  until return_str.length >= length
    return_str.prepend(wrapper)
    return_str << wrapper unless return_str.length == length
  end
  return_str
end
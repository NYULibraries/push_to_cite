module Citero
  module CsfHelpers
    def self.hash_to_csf(hash)
      csf = {}
      hash.each_pair do |key,value|
        hash[key] = [value].flatten.compact
        hash[key] = hash[key].first if hash[key].size == 1
        csf[key] = [csf[key], value].flatten.compact
        csf[key] = csf[key].first if csf[key].size == 1
      end
      csf
    end

    def self.csf_to_string(csf)
      string = ""
      csf.each_pair do |key,value|
        if value.kind_of?(Array)
          value.each do |val|
            string = "#{string}#{key}:#{val}\n"
          end
        else
          string = "#{string}#{key}:#{value}\n"
        end
      end
      return string
    end
  end
end

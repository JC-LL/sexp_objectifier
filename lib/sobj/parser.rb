require 'sxp'

module SOBJ
  class Parser
    def parse filename
      puts "=> parsing".light_green+" '#{filename}'"
      SXP.read IO.read(filename)
    end
  end
end

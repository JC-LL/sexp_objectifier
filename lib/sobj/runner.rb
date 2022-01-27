require "optparse"

require_relative "compiler"

module SOBJ
  class Runner
    def self.run *arguments
      new.run(arguments)
    end

    def run arguments
      compiler=Compiler.new
      compiler.options=args=parse_options(arguments)
      begin
        if filename=args[:file]
          ok=compiler.compile(filename)
        else
          raise "need a description file : sobj [options] <file.sxp>"
        end
      rescue Exception => e
        unless compiler.options[:mute]
          puts e 
          puts e.backtrace
        end
        return false
      end
    end

    private

    def header
      puts "[sobj (#{VERSION}) - (c) JC Le Lann 2022]".yellow
    end

    def parse_options arguments
      parser=OptionParser.new
      no_arguments=arguments.empty?

      options = {}

      parser.on("-h", "--help", "Show help message") do
        puts parser
        exit(true)
      end

      parser.on("-m name", "--model", "Show help message") do |name|
        options[:model_name]=name
      end

      parser.parse!(arguments)

      header unless options[:mute]

      options[:file]=arguments.shift #the remaining file

      if no_arguments
        puts parser
      end

      options
    end
  end
end

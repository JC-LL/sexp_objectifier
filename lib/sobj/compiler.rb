require_relative 'parser'
require_relative 'classifier'
require_relative 'codegen'

module SOBJ
  class Compiler
    attr_accessor :options
    def compile filename
      sexp=Parser.new.parse(filename)
      objs=Classifier.new.run(sexp)
      code=CodeGenerator.new(@options[:model_name]).generate(objs)
    end
  end
end

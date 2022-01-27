module SOBJ

  class SOBJ::Class
    attr_accessor :name,:attributes
    def initialize name
      @name=name
      @attributes=nil #
    end
  end

  class Classifier
    def initialize
      @classes={}
    end

    def run sxp
      puts "=> running classifier".light_green
      classify(sxp)
      pp @classes
      apply_default_naming
      pp @classes
    end

    def classify sxp
      skipped="...<skipped>" if sxp.to_sxp.size > 60
      #puts "   objectifying".yellow+" #{sxp.to_s[0..60]}#{skipped}"
      puts "   classifying".yellow+" #{sxp.to_sxp[0..60]}#{skipped}"
      klass_name=header(sxp)
      if klass=@classes[klass_name]
        puts "   model for '#{klass_name.to_s.yellow}' previously inspected. Reinforcing class."
      end
      klass||=SOBJ::Class.new(klass_name)
      @classes[klass.name]=klass
      current_attributes={}
      appear_as_arrays=[] #keep track of attributes with multiplicity
      rest(sxp).each do |element|
        case element
        when Array
          attribute_klass=classify(element)
          if current_attributes[attr_name=attribute_klass.name.to_sym]
            # adding multiplicity on this attribute
            current_attributes.delete(attr_name)
            multiplicty_for_name="#{attr_name}s"
            current_attributes[multiplicty_for_name]=attribute_klass
            appear_as_arrays << attr_name
          else
            attr_name=attribute_klass.name.to_sym
            unless appear_as_arrays.include?(attr_name)
              current_attributes[attr_name]=attribute_klass
            end
          end
        when String, Float, Integer
          current_attributes[:unamed_args_]||=[]
          current_attributes[:unamed_args_] << element.class
        else
          puts "unhandled data type during classification : #{element} -> #{element.class}"
        end
      end

      if klass.attributes && klass.attributes != current_attributes
        puts "warning : previous discovery of '#{klass_name}' revealed a *different structure* than current exporation."
        puts " - previous detected attributes : #{klass.attributes}"
        puts " - current  detected attributes : #{current_attributes}"
        puts " ==> previous kept"
      else
        klass.attributes=current_attributes
      end

      klass
    end

    def apply_default_naming
      puts "=> applying default naming".light_green
      @classes.each do |name,klass|
        if klass.attributes[:unamed_args_]
          case (unamed_args_klasses=klass.attributes[:unamed_args_]).size
          when 1
            klass.attributes.delete(:unamed_args_)
            case (unamed_args_klass=unamed_args_klasses.first).name
            when "String" # then we name this argument 'name'
              klass.attributes[:name] = String
            when "Integer","Float" # then we name this argument 'value'
              klass.attributes[:value] = unamed_args_klass.name
            else
              puts "ERROR : first element of attribute 'unamed_args' has unhandled type : #{ary.first.class}"
            end
          when 2 #let rename the 'unamed_args' attribute a 'paire' attribute
            klass.attributes.delete(:unamed_args_)
            klass.attributes[:paire] = unamed_args_klasses
          end
        end
      end
    end

    def header sxp
      sxp.first
    end

    def rest sxp
      sxp[1..-1]
    end
  end
end

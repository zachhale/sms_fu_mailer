require 'erb'

module SmsFuMailer
  class Base
    include SMSFu
    
    def self.method_missing(meth, *args)
      if match = matches_dynamic_method?(meth)
        case match[1]
        when 'deliver'
          new(match[2], *args).deliver!
        else 
          super
        end
      else
        super
      end
    end
    
    def self.respond_to?(meth, include_private = false) #:nodoc:
      matches_dynamic_method?(meth) || super
    end
    
    def initialize(method_name=nil, *parameters) #:nodoc:
      create!(method_name, *parameters) if method_name
    end
    
    def create!(method_name, *parameters)
      @body = {}
      @recipient = {}
      __send__(method_name, *parameters)
      template_path = File.join(RAILS_ROOT, 'app', 'views', mailer_name, "#{method_name}.erb")
      @message = render_message(template_path, @body)
    end
    
    def deliver!
      raise "Must set phone" unless @recipient[:phone]
      raise "Must set carrier" unless @recipient[:carrier]
      deliver_sms @recipient[:phone], @recipient[:carrier], @message
    end
    
  private
  
    def self.matches_dynamic_method?(method_name) #:nodoc:
      method_name = method_name.to_s
      /^(deliver)_([_a-z]\w*)/.match(method_name)
    end
    
    def mailer_name
      @mailer_name ||= self.class.name.underscore
    end
    
    def render_message(template_path, body)
      template = File.open(template_path,'r').read
      erb = ERB.new(template,0,'','@message')      
    
      vars_binding = SmsFuMailer::Binder.new(@body).binding
      erb.result(vars_binding)
    end
  end
end
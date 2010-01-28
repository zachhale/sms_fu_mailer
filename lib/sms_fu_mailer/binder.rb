module SmsFuMailer
  class Binder
    def initialize(vars)
      vars.each do |key,value|
        instance_variable_set("@#{key}", value)
      end
    end
    
    public :binding
  end
end
module ModalHelper
  
  
  class ModalDialog
    attr_accessor :options, :id, :viewcontext, :title, :body, :preview, :footer

    def initialize(options={},&block)
      # default options
      options = options.reverse_merge :id => rand.to_s.split('.').last # generate random-id if no id is given

      # set some instance-variables according to option-values
      set :id           => options.delete(:id),
          :viewcontext  => options.delete(:viewcontext),
          :title        => options.delete(:title),
          :body         => options.delete(:body),
          :preview      => options.delete(:preview),
          :footer       => options.delete(:footer),
          :options      => options
          
      # be able to use initializer with yield or with instance_eval block 
      # based on the number of arguments for the block passed in
      # if no arguments to the block are given instance_eval &block is used
      block.arity == 1 ? yield(self) : instance_eval(&block) if block_given?
    end
        
    
    def render_haml
      viewcontext.capture_haml do
        viewcontext.haml_concat preview
        classes = ["modal", "hide", "fade"]
        classes << options[:class] unless options[:class].nil? 
        viewcontext.haml_tag :div, :id => htmlid, :class => classes, :tabindex => "-1", :role => "dialog", :"aria-labelledby" => "myModalLabel", :"aria-hidden" => "true" do
          viewcontext.haml_tag :div, :class => "modal-header" do
            viewcontext.haml_tag :button, :type => "button", :class => "close", :"data-dismiss" => "modal", :"aria-hidden" => "true" do
              viewcontext.haml_concat "x"
            end
            viewcontext.haml_tag "h3" do
              viewcontext.haml_concat title
            end
            viewcontext.haml_tag :div, :class => "modal-body" do
              viewcontext.haml_concat body
            end
            viewcontext.haml_tag :div, :class => "modal-footer" do
              viewcontext.haml_concat footer
            end unless footer.nil?
          end
        end
      end
    end
    
    # in viewcontext?
    def viewcontext?
      !viewcontext.nil?
    end    
    
    def set(opts, &block)
      unless opts.empty?
        opts.each { |k,v| self.send("#{k}=",v) } if opts.is_a? Hash # set (multiple) instance-variables if options is a hash
         # important to use capture in viewcontext for evaluating blocks so that they not appear in view
        self.send("#{opts}=", viewcontext? ? viewcontext.capture(&block) : yield) if block_given? && opts.is_a?(Symbol) # set instance-variable to evaluated block if block is given and option is a symbol
      end
      nil
    end
    
    
    def htmlid
      "modal-#{id}"
    end
    
    def render_text
      "#{self}" + "\n"
    end
    
    def to_s
      "ModalDialog: #{id} options: #{options} title: #{title} preview: #{preview} body: #{body}"
    end
  end
  
  
  
  def modaldialog(options={}, &block)
    # viewcontext is needed for capturing blocks and rendering content to views 
    g = ModalDialog.new(options.merge!({:viewcontext => self}) ,&block)
    # puts g.render_text
    g.render_haml
  end
  
  
end

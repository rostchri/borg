require 'active_support/core_ext' # needed for reverse_merge

module CollapsibleGroupHelper

  class UniversalBlockItem
    include Haml::Helpers
    @@depth = 0
    
    attr_accessor :options, :id, :depth, :viewcontext

    def initialize(options={},&block)
      # default options
      options = options.reverse_merge :id => rand.to_s.split('.').last # generate random-id if no id is given

      # set some instance-variables according to option-values
      set :id           => options.delete(:id),
          :viewcontext  => options.delete(:viewcontext),
          :options      => options,
          :depth        => block_depth
          
      track_block_depth do # update depth-variable
        # be able to use initializer with yield or with instance_eval block 
        # based on the number of arguments for the block passed in
        # if no arguments to the block are given instance_eval &block is used
        block.arity == 1 ? yield(self) : instance_eval(&block)
      end if block_given?

    end
    
    # Thread and exception-safe tracking of block-depth (http://www.alfajango.com/blog/counting-block-nesting-depth-in-ruby/)
    def block_depth=(value)
      #Thread.current[:block_depth] = value
      @@depth = value
    end
  
    def block_depth
      #Thread.current[:block_depth] || 0
      @@depth || 0
    end
  
    def track_block_depth(&block)
      self.block_depth += 1
      yield
      ensure
        self.block_depth -= 1
    end
    
    # in viewcontext?
    def viewcontext?
      !viewcontext.nil?
    end    
    
    def set(options, &block)
      unless options.empty?
        options.each { |k,v| self.send("#{k}=",v) } if options.is_a? Hash # set (multiple) instance-variables if options is a hash
         # important to use capture in viewcontext for evaluating blocks so that they not appear in view
        self.send("#{options}=", viewcontext? ? viewcontext.capture(&block) : yield) if block_given? && options.is_a?(Symbol) # set instance-variable to evaluated block if block is given and option is a symbol
      end
      nil
    end

    def to_s
      "#{id} #{options}"
    end
  end
  
  class Item < UniversalBlockItem
    attr_accessor :title, :group, :body, :show, :ajaxurl, :url
    
    def initialize(options={},&block)
      # default options
      options = options.reverse_merge :show  => false
      
      # set some instance-variables according to option-values
      set :group    => options.delete(:group),
          :title    => options.delete(:title),
          :body     => options.delete(:body),
          :ajaxurl  => options.delete(:ajaxurl),
          :url      => options.delete(:url)
      super
    end
            
    def render_haml
      # head
      content = viewcontext.capture_haml do
        viewcontext.haml_tag :div, :class => 'accordion-heading' do
          opts = {:'data-toggle' => "collapse", :'data-target' => "#collapsible_item-#{id}"}
          opts.merge!({:'data-parent' => "#collapsible_group-#{group.id}"}) if group.options[:connected]
          labelopts = {:id => "label-collapsible_item-#{id}", :class => ['collapsable-label', 'icon-black']} 
          labelopts[:class] << (options[:show] || group.options[:show] ? 'icon-chevron-down' : 'icon-chevron-right') if group.options[:icons]
          viewcontext.haml_tag :i, labelopts do
          end
          headcontent = title
          linktarget  = ajaxurl.nil? ? "#" : ajaxurl
          linktarget  = url unless url.nil?
          opts.merge!({:remote => true}) unless ajaxurl.nil? 
          viewcontext.haml_concat viewcontext.link_to headcontent, linktarget, opts
        end
      end

      # body
      content += viewcontext.capture_haml do
        opts = {:id => "collapsible_item-#{id}", :class => ['accordion-body', 'collapse']}
        opts[:class] << "in" if options[:show] || group.options[:show]
        viewcontext.haml_tag :div, opts  do
          viewcontext.haml_tag :div, :class => 'accordion-inner' do
            viewcontext.haml_concat body
          end
        end
        if group.options[:icons]
           viewcontext.haml_concat viewcontext.javascript_tag <<-EOF
$(document).ready( function() {
  var item = $('#collapsible_item-#{id}');
  var label = $('#label-collapsible_item-#{id}');
  item.on('show', function(event) {
      label.removeClass('icon-chevron-right').addClass('icon-chevron-down');
      event.stopPropagation();
  });

  item.on('hide', function(event) {
    //console.log($(this).hasClass('in'));
    //if ($(this).hasClass('in') && label.hasClass('icon-chevron-down')) {
      //console.log(label.hasClass('icon-chevron-right'));
    label.removeClass('icon-chevron-down').addClass('icon-chevron-right');
    //}
    event.stopPropagation();
  });
});
EOF
        end
      end
      content
    end
    
    def to_s
      "Collapsible-Item: #{id} #{title} #{options}"
    end
  end
  
  class Group < UniversalBlockItem
    attr_accessor :items
  
    def initialize(options={},&block)
      # default options
      options = options.reverse_merge :icons => true,       # show icon
                                      :show  => false,      # show: all items must be clicked to show or manually set to show=true in item
                                      :connected => false   # connected: only one item per time in a group is visible

      # set some instance-variables according to option-values
      set :items  => [] 
      super             
    end
    
    def item(options = {}, &block)
      items << Item.new(options.merge!({:group => self, :viewcontext => self.viewcontext}), &block)
      nil
    end
    
    # not needed?
    # def group(options={},&block)
    #   items << Group.new(options.merge!({:viewcontext => self.viewcontext}),&block)
    #   nil
    # end
    
    def render_text(with_body=false)
      spaces = 1.upto(depth).map{" "}.join
      "#{self}" + "\n" +  items.map{|i| "#{spaces} #{i.is_a?(Item) ? "#{i}" + (i.body.nil? || !with_body ? "" : "\n  #{spaces}#{i.body}") : i.render_text(with_body)}"}.join("\n")
    end
    
    def render_haml
      viewcontext.capture_haml do
        viewcontext.haml_tag :div, :id => "collapsible_group-#{id}", :class => 'accordion' do
          items.each do |item|
            viewcontext.haml_tag :div, :class => 'accordion-group' do
              viewcontext.haml_concat item.render_haml
            end
          end
        end
      end
    end
    
    def to_s
      "Collapsible-Group: #{id} #{options}"
    end
  end
    
  def collapsible_group(options={}, &block)
    # viewcontext is needed for capturing blocks and rendering content to views
    g = Group.new(options.merge!({:viewcontext => self}),&block)
    # puts g.render_text(false)
    g.render_haml
  end
  
end

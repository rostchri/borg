module UsersHelper

  def users_grid(objects,paginator = nil)
    
    col_visible   = {:col_visible   => ->(col) { 
                                                 true
                                               }}

    options = { #:caption => User.model_name.human(:count => 2),
                :row_layout         => [:login,:givenname,:surname,:email,:current_login_ip,:current_login_at,:last_login_ip,:last_login_at,:failed_login_count,:login_count,:created_at,:updated_at],
                :paginator          => paginator,
                :show_action        => ->(obj)  {iconic_show_link(user_path(obj))},
                :edit_action        => ->(obj)  {iconic_edit_link(edit_user_path(obj))},
                :destroy_action     => ->(obj)  {iconic_destroy_link(user_path(obj), obj.class, obj.login)},
                :format_date        => ->(date) {l date, :format => :short_with_time},
                :clickable_path     => ->(obj)  {user_path(obj)},
              }.merge(col_visible)

    table_grid(objects, options)
  end


  def user_grid(object)
    col_visible   = {:col_visible   => ->(col) {true}}
        
    options = { :vertical    => true, 
                #:caption     => t("#{resource_class}.show", :login => object.login),
                :row_layout  => [:login,:givenname,:surname,:email,:current_login_ip,:current_login_at,:last_login_ip,:last_login_at,:failed_login_count,:login_count,:created_at,:updated_at],
                :format_date => ->(date) {l date, :format => :short_with_time},
              }.merge(col_visible)
    table_grid([object],options)
  end

  
end

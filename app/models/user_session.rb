class UserSession < Authlogic::Session::Base
  single_access_allowed_request_types :any
  remember_me true
  def remember_me_for 
    1.weeks 
  end
end

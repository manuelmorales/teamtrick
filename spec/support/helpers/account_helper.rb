module AccountHelper
  def login_as(user)
    request.session[:user] = user ? user.id : nil
  end
end

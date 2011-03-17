define :bundle_install do
  bash "bundle-install" do
    user params[:user] if params[:user]
    cwd params[:name]
    code "bundle install"
  end
end

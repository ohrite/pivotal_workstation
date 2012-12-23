# Acknowledgements: Some configuration source from
# https://github.com/Casecommons/casecommons_workstation

include_recipe "pivotal_workstation::homebrew"
include_recipe "pivotal_workstation::ack"
include_recipe "pivotal_workstation::git"
include_recipe "pivotal_workstation::rvm"
include_recipe "pivotal_workstation::tmux"

brew_install "mercurial"

execute "install vim from url" do
  command "brew install #{node["vim_homebrew_url"]}"
  user WS_USER
  not_if "brew list | grep '^vim$'"
end

execute "install macvim with system ruby" do
  command "rvm use system; brew install macvim"
  user WS_USER
  not_if "brew list | grep '^macvim$'"
end

execute "link macvim into place" do
  command "ln -s /usr/local/Cellar/macvim/*/MacVim.app /Applications/MacVim.app"
  user WS_USER
  not_if { File.symlink?("/Applications/MacVim.app") }
end

directory "remove pre-existing vim configuration" do
  path node["vim_home"]
  action :delete
  recursive true
  only_if { File.directory?(node["vim_home"]) }
  not_if { File.directory?("#{node["vim_home"]}/.git") }
end

git node["vim_home"] do
  repository node["vim_config_git"]
  branch "master"
  revision node["vim_hash"] || "HEAD"
  action :sync
  user WS_USER
  enable_submodules true
end

%w{vimrc gvimrc}.each do |vimrc|
  link "#{WS_HOME}/.#{vimrc}" do
    to "#{node["vim_home"]}/#{vimrc}"
    owner WS_USER
    not_if { File.symlink?("#{node["vim_home"]}/#{vimrc}") }
  end
end

execute "compile command-t" do
  command "rvm use system; ruby extconf.rb && make clean && make"
  cwd "#{node["vim_home"]}/bundle/command-t/ruby/command-t"
  user WS_USER
  not_if "otool -l #{node["vim_home"]}/bundle/command-t/ruby/command-t/ext.bundle | grep libruby"
end

file "#{WS_HOME}/.vimrc.local" do
  action :touch
  owner WS_USER
  not_if { File.exists?("#{WS_HOME}/.vimrc.local") }
end

pivotal_workstation_bash_it_custom_plugin "vim-alias_vi_to_minimal_vim.bash"
pivotal_workstation_bash_it_custom_plugin "vim-source_tmux_config.bash"

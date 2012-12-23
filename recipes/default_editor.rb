include_recipe "pivotal_workstation::duti"

node["default_editor_content_types"].each do |content_type|
  default_editor = node["default_editor"]
  execute "set default editor for #{content_type}" do
    command "duti -s #{default_editor} #{content_type} all"
    user WS_USER
    not_if "duti -d #{content_type} | grep #{default_editor}"
  end
end

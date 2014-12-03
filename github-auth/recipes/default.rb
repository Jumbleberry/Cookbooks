#Applications
apps = ["core", "mesh", "admin"]

#Username owner of the keys
username = node['jbx']['user']

#Creates tmp ssh folder for github keys
tmp_ssh_folder = node['github']['wrapper_path']

directory tmp_ssh_folder do
  action :create
  owner username
  group username
  recursive true
end

#Creates one key file and ssh wrapper for each app
apps.each do |app|
  if !node['jbx'][app]['github_key'].empty?
    key_name = node['jbx'][app]['github_key'] + ".key"
    ssh_wrapper_name = node['jbx'][app]['github_key'] + "_wrapper.sh"

    #Copy private key to tmp folder
    cookbook_file "#{tmp_ssh_folder}/#{key_name}" do
      source "ssh/#{key_name}"
      owner username
      mode 0600
    end

    #Creates ssh wrapper for the key
    template "#{tmp_ssh_folder}/#{ssh_wrapper_name}" do
      source 'ssh/ssh_wrapper.sh.erb'
      variables ({
            'tmp_key_file' => "#{tmp_ssh_folder}/#{key_name}"
      })
      mode 0770
      owner username
      group username
    end
  end
end

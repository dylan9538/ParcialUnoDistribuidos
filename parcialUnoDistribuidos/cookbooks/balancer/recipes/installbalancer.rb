bash 'open port' do
  code <<-EOH
  iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
  iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
  service iptables save
  EOH
end

cookbook_file '/etc/yum.repos.d/nginx.repo' do
  source 'nginx.repo'
end 

package 'nginx'

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  variables(
    ip_serverOne: node[:balancer][:ip_serverOne],
    ip_serverTwo: node[:balancer][:ip_serverTwo]
  )
end

service 'nginx' do
  action :enable
end

service 'nginx' do
  action :start
end

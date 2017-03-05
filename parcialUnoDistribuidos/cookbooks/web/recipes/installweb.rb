package 'httpd'
package 'php'
package 'php-mysql'
package 'mysql'

service 'httpd' do
  action [:enable, :start]
end

bash 'open port' do 
 code <<-EOH
  iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
  service iptables save 
    EOH
end

template '/var/www/html/index.php' do
 source 'index.php.erb'
 mode 0644
 variables(
      db_ip: node[:db][:ip],
      wb_user: node[:wb][:user],
      wb_pass: node[:wb][:pass],
      tablename: node[:web][:tabla]    
)
end



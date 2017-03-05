package 'mysql-server' 

service 'mysqld' do 
 action [:enable, :start]
end

bash 'openPort' do
  code <<-EOH
     iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
     service iptables save
  EOH
end

package 'expect'

cookbook_file '/tmp/configure_mysql.sh' do
    source 'configure_mysql.sh'
    mode 0711
end

bash 'configure mysql' do
  cwd '/tmp'
  code <<-EOH 
  ./configure_mysql.sh
  EOH
end

template '/tmp/create_schema.sql' do
    source 'create_schema.sql.erb'
    mode 0644
    variables(
      wb_ipOne: node[:wb][:wb_ipOne],
      wb_ipTwo: node[:wb][:wb_ipTwo],
      db_user: node[:db][:user],
      db_pass: node[:db][:pass]
    )
end

bash 'create schema' do
 cwd '/tmp'
 code <<-EOH
 cat create_schema.sql | mysql -u root -pdistribuidos
 EOH
end







 

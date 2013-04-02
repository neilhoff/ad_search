require 'net-ldap'

require "ad_search/version"

# Search Active Directory and get a hash in return
module AdSearch

  # Connection to Active Directory
  def self.connect_to_ad(username, password, domain, host, base)
    ldap = Net::LDAP.new :host => host,
                         :port => 389,
                         :base => base,
                         :auth => {
                             :method => :simple,
                             :username => username + '@' + domain,
                             :password => password
                         }
    if ldap.bind
      return ldap
    else
      raise 'authentication failed'
    end
  end

  def self.search_active_users_by_username(ad_connection, search_term, treebase)
    users = Hash.new

    #Create a filter based on the username
    filter = Net::LDAP::Filter.eq("sAMAccountName", search_term)
    #Create a 2nd filter that makes sure we are only searching on users
    filter2 = Net::LDAP::Filter.eq("objectCategory", "organizationalPerson")
    #Join the filters together
    joined_filter = Net::LDAP::Filter.join(filter, filter2)

    count = 0
    ad_connection.search(:base => treebase, :filter => joined_filter) do |entry|
      if active_account?(entry)
        username = entry.sAMAccountName.to_s[2..-3]
        #Split the first name and last name and remove un-needed characters
        name = entry.name.to_s
        name_length = name.length
        name = name[2..-3].split
        begin
          manager = entry.manager.to_s.split(',')
          manager = manager[0][5..-1]
        rescue
          manager = 'Manager is not set'
        end
        begin
          title =  entry.title.to_s[2..-3]
        rescue
          title = 'Title is not set'
        end
        begin
          office = entry.physicaldeliveryofficename.to_s[2..-3]
        rescue
          office = 'Office is not set'
        end
        begin
          email = entry.mail.to_s[2..-3]
        rescue
          email = 'Email is not set'
        end

        users[username] = 	{"first_name" => name[0],
                             "last_name" => name[1],
                             "username" => username,
                             "title" => title,
                             "office" => office,
                             "email" => email
                             #"manager" => manager
        }
        count = count + 1
      end
    end
    return users
  end

  #Microsoft Active Directories way of keeping track of time: BIGEPOCH (01/01/1970) is 116444916000000000 "100 nanosecond intervals since 01/01/1601"
  BIGEPOCH = 116444916000000000
  def self.active_account?(ad_object)
    #See if account is disabled or the account is expired
    tmpuac = ad_object.userAccountControl[0].to_i
    if tmpuac & 2 == 2
      return false
    elsif ad_object.accountExpires[0].to_i != 0 and Time.now > Time.at((ad_object.accountExpires[0].to_i - BIGEPOCH) / 10000000) #Microsoft to epoch time
      return false
    else
      return true
    end
  end

end

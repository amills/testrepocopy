require 'libxml'

class Admin::TransactionController < ApplicationController
  include AuthenticatedSystem

  layout 'admin',:except => [:ok,:error]
  
  def index
    @validate_only = params[:validate] == 'true'
    session[:request_type] = 'POST' if request.post?
    return redirect_to(:action => 'document') unless params[:xml] or @validate_only
    parse_xml(params[:xml])
    return show_error(@errors.join('; ')) if @errors.any?
    redirect_to :action => 'ok'
  rescue
    show_error($!.to_s)
  end
  
  def ok
  end

  def error
  end

  def document
  end

  def test
    session[:request_type] = 'GET' if request.post?
    return redirect_to(:action => 'index',:xml => params[:xml]) unless params[:xml].blank?
    @error = "No XML specified" if request.post?
  end
  
  def validate
  end

private
  def parse_xml(xml)
    @errors = []
    parser,parser.string = LibXML::XML::Parser.new,xml
    root = parser.parse.root
    unless @validate_only
      existing_login = (logged_in? && session[:is_super_admin])
      self.current_user = User.authenticate(request.subdomains.first,root[:username], root[:password]) unless existing_login
      raise "Authentication error" unless logged_in?
      session[:is_super_admin] = self.current_user.is_super_admin
    end
    if root.name == 'session'
      root.each_element {|child| process_transaction(child)}
    else
      process_transaction(root)
    end
  ensure
    self.current_user = nil unless existing_login
  end
  
  def process_transaction(node)
    case node.name
      when 'add-account'
        add_account(node)
      else
        @errors.push("Unknown transaction: #{node.name}")
    end
  end
  
  def add_account(node)
    check_no_subelements(node)
    raise 'No subdomain defined' if (subdomain = node['subdomain']).blank?
    raise 'No company defined' if (company = node['company']).blank?
    raise 'No language defined' if (language = node['language']).blank?
    raise 'No first name defined' if (first = node['first']).blank?
    raise 'No last name defined' if (last = node['last']).blank?
    raise 'No email defined' if (email = node['email']).blank?
    raise 'No password defined' if (password = node['password']).blank?

    Account.transaction do
      account = Account.create!(:subdomain => subdomain,:company => company,:is_verified => true)
      user = User.create!(:account_id => account.id,:email => email,:first_name => first,:last_name => last,:password => password,:is_admin => true)
    end
  rescue
    @errors.push($!.to_s)
  end
  
  def check_no_subelements(node)
    node.each_element {|child| raise "#'{node.name}' has invalid sub-elements"}
  end
  
  def get_optional_cdata(node)
    matches = node.children.find_all {|child| child.cdata?}
    return if matches.empty?
    raise "Too many CDATA blocks found" if matches.length > 1
    matches[0].content.strip
  end
  
  def pp_hash(hash)
    result = []
    hash.each_pair {|key,value| result.push "#{key}=#{value}"}
    result.join(',')
  end
  
  def sql_string_value(string)
    string.gsub(/'/,"''")
  end

  def show_error(error)
    redirect_to :action => 'error',:error => error
    return false
  end
end
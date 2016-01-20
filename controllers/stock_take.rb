require 'active_record'
require 'mail'
# Stock Take list
#####################################
get '/stock_takes' do
  authenticate!
  ActiveRecord::Base.include_root_in_json = false
  viewmodel = StockTakeListModel.new.load_stock_takes
  @data = viewmodel.to_json
  haml :'stock_take/list/index'
end


get '/stock_take/:id/csv' do
  authenticate!
  env['api.format'] = :binary
  content_type 'text/csv'
  attachment "stock_take.csv"
  ActiveRecord::Base.include_root_in_json = false
  StockTakeListModel.new.generate_csv(params['id'])
end

post '/stock_take/mail' do
  to_email ||= YAML.load_file(File.join(__dir__, '../config/email.yml'))[ session[:user].name ]
  raise "Error sending mail! Invalid email address #{to_email} ." if to_email.blank?
  Mail.defaults do
    delivery_method :sendmail
  end
  mail = Mail.new
  mail.to = to_email
  mail.from = 'reports@mshini.com'
  mail.subject = 'Stock Take Report'
  mail.body = "Please find the stock take report for #{params['date']} attached."
  mail.add_file( File.join(File.dirname(__FILE__), "../public/pdfs/#{params['id']}.pdf") )
  #mail.attachments['myfile.pdf'] = File.read('path/to/myfile.pdf')
  response = mail.deliver!
  raise "Error sending mail!" unless response.class == Mail::Message
end

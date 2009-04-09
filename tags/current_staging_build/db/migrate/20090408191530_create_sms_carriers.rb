class CreateSmsCarriers < ActiveRecord::Migration
  def self.up
    create_table :sms_carriers do |t|
      t.column :name,:string
      t.column :domain,:string
      t.timestamps
    end
    
    add_column :users,:sms_number,:string
    add_column :users,:sms_domain,:string
    add_column :users,:sms_notify,:boolean,:null => false,:default => false
    add_column :users,:sms_confirmed,:boolean,:null => false,:default => false

    execute "insert into sms_carriers (name,domain) values ('AllTel','message.alltel.com')"
    execute "insert into sms_carriers (name,domain) values ('AT&T Wireless Services','txt.att.net')"
    execute "insert into sms_carriers (name,domain) values ('Bell Mobility','txt.bellmobility.ca')"
    execute "insert into sms_carriers (name,domain) values ('Bluegrass Cellular','sms.bluecell.com')"
    execute "insert into sms_carriers (name,domain) values ('CenturyTel','messaging.centurytel.net')"
    execute "insert into sms_carriers (name,domain) values ('Cincinnati Bell','mobile.att.net')"
    execute "insert into sms_carriers (name,domain) values ('Cingular Wireless','cingularME.com')"
    execute "insert into sms_carriers (name,domain) values ('Corr Wireless Communications','corrwireless.net')"
    execute "insert into sms_carriers (name,domain) values ('Dobson Cellular Systems','mobile.dobson.net')"
    execute "insert into sms_carriers (name,domain) values ('Dobson-Alex Wireless','mobile.cellularone.com')"
    execute "insert into sms_carriers (name,domain) values ('Dobson-Cellular One','mobile.cellularone.com')"
    execute "insert into sms_carriers (name,domain) values ('Inland Cellular Telephone Co.','inlandlink.com')"
    execute "insert into sms_carriers (name,domain) values ('Metro PCS','metropcs.sms.us')"
    execute "insert into sms_carriers (name,domain) values ('Microcell','fido.ca')"
    execute "insert into sms_carriers (name,domain) values ('Midwest Wireless','clearlydigital.com')"
    execute "insert into sms_carriers (name,domain) values ('Nextel','messaging.nextel.com')"
    execute "insert into sms_carriers (name,domain) values ('PCS ONE','pcsone.net')"
    execute "insert into sms_carriers (name,domain) values ('Pioneer/Enid Cellular','msg.pioneerenidcellular.com')"
    execute "insert into sms_carriers (name,domain) values ('Powertel','voicestream.net')"
    execute "insert into sms_carriers (name,domain) values ('Price Communications','mobilecell1se.com')"
    execute "insert into sms_carriers (name,domain) values ('Public Service Cellular','sms.pscel.com')"
    execute "insert into sms_carriers (name,domain) values ('Qwest Wireless','qwestmp.com')"
    execute "insert into sms_carriers (name,domain) values ('Rogers','pcs.rogers.com')"
    execute "insert into sms_carriers (name,domain) values ('Rural Cellular','typetalk.ruralcellular.com')"
    execute "insert into sms_carriers (name,domain) values ('SprintPCS','messaging.sprintpcs.com')"
    execute "insert into sms_carriers (name,domain) values ('Telepak/Cellular South','csouth1.com')"
    execute "insert into sms_carriers (name,domain) values ('Telus','msg.telus.com')"
    execute "insert into sms_carriers (name,domain) values ('Triton','tms.suncom.com')"
    execute "insert into sms_carriers (name,domain) values ('US Cellular','uscc.textmsg.com')"
    execute "insert into sms_carriers (name,domain) values ('US Unwired','messaging.sprintpcs.com')"
    execute "insert into sms_carriers (name,domain) values ('Verizon Wireless','vtext.com')"
    execute "insert into sms_carriers (name,domain) values ('Virgin Mobile','vmobl.com')"
    execute "insert into sms_carriers (name,domain) values ('Voicestream','voicestream.net')"
    execute "insert into sms_carriers (name,domain) values ('West Central Wireless','sms.wcc.net')"
    execute "insert into sms_carriers (name,domain) values ('Western Wireless','cellularonewest.com')"
  end

  def self.down
    drop_table :sms_carriers
    
    remove_column :users,:sms_number
    remove_column :users,:sms_domain
    remove_column :users,:sms_notify
    remove_column :users,:sms_confirmed
  end
end

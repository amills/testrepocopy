class Admin::TranslationController < ApplicationController
  include AuthenticatedSystem

  before_filter :authorize_super_admin
  layout 'admin'
  
  def index
    @language = Globalize::Language.find(:first,:conditions => {:iso_639_1 => (params[:language] || 'en')})
    if request.post? and params[:new_value] and params[:old_value]
      for key in params[:new_value].keys
        new_value = params[:new_value][key]
        next if new_value.blank? or new_value == params[:old_value][key]
        translation = Globalize::Translation.find(key)
        translation.text = new_value
        translation.save!
      end
    end
    @translations = Globalize::Translation.find(:all,:conditions => {:language_id => @language.id}) # if @language.iso_639_1 != 'en'
  rescue
    flash[:error] = $!.to_s
  end
end

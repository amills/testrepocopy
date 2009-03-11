class Admin::TranslationController < ApplicationController
  include AuthenticatedSystem

  before_filter :authorize_super_admin
  layout 'admin'
  
  def index
    @show_all = params[:show_all] == 'on'
    @language = Globalize::Language.find(:first,:conditions => {:iso_639_1 => (params[:language] || 'en')})
    if request.post? and params[:new_value] and params[:old_value]
      for key in params[:new_value].keys
        new_value = params[:new_value][key]
        next if new_value == params[:old_value][key]
        new_value = nil if new_value.blank?
        translation = Globalize::Translation.find(key)
        translation.text = new_value
        translation.save!
      end
    end
    return if @language.iso_639_1 == 'en'
    conditions = "language_id = #{@language.id}"
    conditions += " and text is null" unless @show_all
    @translations = Globalize::Translation.find(:all,:conditions => conditions,:order => "type,tr_key")
  rescue
    flash[:error] = $!.to_s
  end
end

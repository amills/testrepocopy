class NotificationMode < ActiveRecord::Base
#	belongs_to :user
	
	PRIORITY_NONE = 0
	PRIORITY_INFO = 1
	PRIORITY_WARNING = 2
	PRIORITY_ERROR = 3
	PRIORITY_CRITICAL = 4
	PRIORITY_DOWN = 5
end

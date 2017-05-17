class StaticPagesController < ApplicationController

	def return_and_refund_policy
		@body_class_name         = "static_pages return_and_refund_policy"
	end

	def seller_manual
		@body_class_name         = "static_pages seller_manual"
	end

	def affiliates
		@body_class_name         = "static_pages affiliates"
	end

	def investors
		@body_class_name         = "static_pages investors"
	end
	def terms_of_use
		@body_class_name         = "static_pages terms_of_use"
	end
	def cookies
		@body_class_name         = "static_pages cookies"
	end
	def privacy
		@body_class_name         = "static_pages privacy"
	end
	def interest_based_ads
		@body_class_name         = "static_pages interest_based_ads"
	end
	def copyright
		@body_class_name         = "static_pages copyright"
	end
end

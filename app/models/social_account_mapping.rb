class SocialAccountMapping < ApplicationRecord
  enum :social_ids, { google: 1 }
end
class Message < ApplicationRecord
    belongs_to :user
    belongs_to :conversation
  
    # Ensure content is present
    validates :content, presence: true
  
    # Ensure sender_role is present and valid
    validates :sender_role, presence: true, inclusion: { in: sender_roles.keys }
  
    # Define enum for sender_role
    enum sender_role: { initiator: "initiator", expert: "expert" }
end

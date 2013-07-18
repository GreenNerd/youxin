class Conversation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :originator_id
  field :last_message_id

  validates :originator_id, presence: true

  has_and_belongs_to_many :participants, class_name: 'User', dependent: :destroy
  has_many :messages, dependent: :destroy

  default_scope desc(:updated_at)

  def originator
    User.where(id: self.originator_id).first
  end
  def last_message
    Message.where(id: self.last_message_id).first
  end
end

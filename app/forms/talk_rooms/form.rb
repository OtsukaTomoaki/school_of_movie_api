class TalkRooms::Form
  include ActiveModel::Model
  include ActiveModel::Attributes
  include CustomException

  attribute :id, :string
  attribute :name, :string
  attribute :describe, :string
  attribute :status, :integer

  validates :name, presence: true, length: { maximum: 400 }
  validates :describe, length: { maximum: 2000 }
  validates :status, presence: true


  def initialize(params)
    super(params)
  end

  def error_messages()
    self.errors.map { |error|
      {
        attribute: error.attribute,
        message: error.full_message
      }
    }
  end
end
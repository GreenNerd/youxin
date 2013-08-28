# encoding: utf-8

class Notification::Organization < Notification::Base
  belongs_to :organization, class_name: 'Organization'

  field :status, type: String

  validates :status, inclusion: %w( in out )
  validates :organization_id, presence: true

  scope :_in, ->{ where(status: 'in') }
  scope :_out, ->{ where(status: 'out') }

  after_create :send_organization_notification_to_ios_device

  private
  def send_organization_notification_to_ios_device
    Notification::Notifier.publish_to_ios_device_async([user.id], ios_payload)
  end
  def ios_payload
    {
      alert: "组织状态改变\n(系统通知) 你被#{status == 'in' ? '移入' : '移除'}了 #{organization.name}",
      custom: {
        type: :organization,
        id: id.to_s,
      }
    }
  end
end

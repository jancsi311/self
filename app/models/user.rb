class User < ActiveRecord::Base
  has_many :user_projects, dependent: :destroy
  has_many :projects, through: :user_projects
  has_many :events, dependent: :destroy
  has_many :evaluated_vacation_requests, class_name: 'VacationRequest', foreign_key: :admin_id
  has_many :feedbacks

  include Oauth
  include Payable
  include Vacation

  devise :database_authenticatable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  validate :has_company_email_address?
  validates_numericality_of :vacation_limit, greater_than_or_equal_to: 0
  before_save :set_admin_flag

  def name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def to_keen
    {
      name: name,
      email: email,
      created_at: created_at,
      ip: current_sign_in_ip
    }
  end

  def report(project:, from:, to:)
    query = <<-SQL
      SELECT string_agg('[' || round(e.hours + e.minutes / 60.0, 1) || '] ' || e.description, '\n ') as description
            ,e.worked_at FROM events as e
      WHERE user_id = #{id} AND e.project_id = #{project.id.to_i}
      AND worked_at >= '#{from.beginning_of_day.strftime '%Y-%m-%d %H:%M:%S'}'
      AND worked_at <= '#{to.end_of_day.strftime '%Y-%m-%d %H:%M:%S'}'
      GROUP BY e.worked_at
      ORDER BY e.worked_at ASC
    SQL

    decimal_mapper = ->(d) { d[0] == '0' ? '' : ".#{d}"  }

    ActiveRecord::Base.connection.execute(query).to_a.map do |day|
      day['description'] = day['description'].split(/\n/).map do |event_description|
        event_description.sub(/\[(\d+)\.(\d+)\]/) do
          "[#{Regexp.last_match[1]}#{decimal_mapper.call(Regexp.last_match[2])}h]"
        end
      end.join('<br/>').html_safe

      day
    end || []
  end

  private
  def set_admin_flag
    admins = Figaro.env.admins.split(',').map &:strip
    address = Mail::Address.new email

    self.admin = admins.include? address.local

    self
  end

  def has_company_email_address?
    address = Mail::Address.new email
    unless address.domain == "#{Figaro.env.email_domain}.com"
      errors.add(:email, "You're not welcome here with a #{address.domain} email domain.")
    end
  end
end

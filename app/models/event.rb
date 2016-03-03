class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  enum status: [ :submitted, :generated, :accounted, :paid ].map {|status| [status, status.to_s]}.to_h

  validates_numericality_of :hours, greater_than_or_equal_to: 0, less_than_or_equal_to: 12
  validates_numericality_of :minutes, greater_than_or_equal_to: 0, less_than: 60

  validates_numericality_of :minutes, greater_than_or_equal_to: 15, less_than: 60,
                            if: :less_than_an_hour?, message: 'must be greater than or equal to 15 if total is less than an hour!'

  validates_numericality_of :minutes, equal_to: 0, if: :has_worked_a_lot?, message: 'should not work more than 12 hours!'
  before_create :update_amount
  before_update :update_amount
  validate :ensure_not_frozen, :ensure_less_than_a_day

  include Aggregate

  scope :gefroren, -> { where gefroren: true }

  def user_project
    @user_project ||= UserProject.find_by_user_id_and_project_id user_id, project_id
  end

  def rate
    user_project.rate_at(worked_at) || user.rate_at(worked_at) rescue user.rate_at(worked_at)
  end

  def to_keen(options={})
    options.merge(
        user: user.to_keen,
        project: project.to_keen,
        hours: hours,
        minutes: minutes,
        worked_at: worked_at,
        overtime: ot,
        description: description,
        amount: amount
    )
  end

  def destroy
    raise "Can't destroy frozen event. Are you doing funky stuff?" if gefroren?
    super
  end

  def as_json(*args)
    {
        duration: duration / 3600.0,
        project: project ? project.name : 'Project N/A',
        description: description,
        id: id
    }
  end

  private
  def less_than_an_hour?
    hours < 1
  end

  def has_worked_a_lot?
    hours == 12
  end

  def ensure_less_than_a_day
    excluded_ids = persisted? ? [id] : []

    unless user.events.at(worked_at).where.not(id: excluded_ids).total + duration < 24.hours
      errors.add :hours, "Can't exceed 24 in a day!"
    end
  end

  def ensure_not_frozen
    error_msg = "Can't change this!"

    if persisted? && gefroren?
      errors.add :project_id, error_msg
      errors.add :hours, error_msg
    end
  end

  def update_amount
    self.amount = compute_amount
  end
end

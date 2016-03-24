class EventsController < ApplicationController
  respond_to :html
  respond_to :js, only: [:create, :update]
  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_token

  after_filter :publish_event_to_keen
  before_filter :load_event, only: [:update, :destroy, :edit]

  def index
    cookies.signed[:user_id] = current_user.id
    respond_to do |format|
      format.json do

        render json: {
                   projects: Project.events_for_projects(user: current_user, date: @date),
                   date: @date
               }
      end

      format.html { redirect_to root_path }
    end
  end

  def data_table
    respond_to do |format|
      format.json do
        collection = scope.joins 'LEFT JOIN projects ON projects.id = events.project_id'
        render json: EventDataTable.new(view: view_context, relation: collection)
      end
      format.html { redirect_to root_path }
    end
  end

  def edit
    render layout: false
  end

  def create
    @event = scope.new permitted_params
    @success = @event.save
    @date = @event.worked_at
    respond_with @event, location: -> { root_path(date: permitted_params[:worked_at]) }
  end

  def update
    @success = @event.update permitted_params
    @date = @event.worked_at
    respond_with @event, location: -> { root_path(date: permitted_params[:worked_at]) }
  end

  def destroy
    @event.destroy
    flash[:notice] = 'Event successfully removed'
  rescue
    flash[:alert] = 'Unable to remove event!'
  ensure
    redirect_to root_path(date: @event.worked_at)
  end

  private
  def load_event
    @event = scope.find params[:id]
  end

  def scope
    current_user.events
  end

  def permitted_params
    params.require(:event).permit :hours, :minutes, :description, :project_id, :worked_at, :ot
  end

  def publish_event_to_keen
    if @event && (@event.persisted? || @event.destroyed?)
      publish_keen collection: :events, event: @event.to_keen( action: params[:action])
    end
  rescue
    # don't care about issues with +Keen+
  end

  def handle_invalid_token(error)
    render json: {error: error.message}, status: :unauthorized
  end
end

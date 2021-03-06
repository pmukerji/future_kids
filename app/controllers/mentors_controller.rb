class MentorsController < ApplicationController
  load_and_authorize_resource
  include CrudActions
  include ManageSchedules # edit_schedules & update_schedules

  def index
    if current_user.is_a?(Admin) && 'xlsx' == params[:format]
      return render xlsx: 'index'
    end

    # a prototyped mentor is submitted with each index query. if the prototype
    # is not present, it is built here with default values
    params[:mentor] ||= {}
    params[:mentor][:inactive] = '0' if params[:mentor][:inactive].nil?

    # mentors are filtered by the criteria above
    @mentors = @mentors.where(mentor_params.to_h.delete_if { |_key, val| val.blank? })

    # provide a prototype for the filter form
    @mentor = Mentor.new(mentor_params)

    # when only one record is present, show it immediatelly. this is not for
    # admins, since they could have no chance to alter their filter settings in
    # some cases
    if !current_user.is_a?(Admin) && (1 == @mentors.count)
      redirect_to @mentors.first
    else
      respond_with @mentors
    end
  end

  def show
    # together with the mentor, a list of journal entries is shown for the
    # given year / month
    @year =  (params[:year] || Date.today.year).to_i
    @month = (params[:month] || Date.today.month).to_i
    @journals = @mentor.journals.where(month: @month, year: @year)

    # decouble journals from database to allow adding the virtial record
    # below and use Enumerables sum instaed of ARs sum in view
    @journals = @journals.to_a

    # per default a coaching entry is added for each month
    @journals << Journal.coaching_entry(@mentor, @month, @year)
    respond_with @mentor
  end

  private

  def mentor_params
    if params[:mentor].present?
      params.require(:mentor).permit(
        :name, :prename, :email, :password, :password_confirmation, :address, :sex,
        :city, :dob, :phone, :college, :field_of_study, :education, :transport,
        :personnel_number, :ects, :term, :absence, :note, :todo, :substitute,
        :primary_kids_school_id, :primary_kids_meeting_day, :primary_kids_admin_id,
        :exit_kind, :exit_at,
        :inactive, :photo, schedules_attributes: [:day, :hour, :minute]
      )
    else
      {}
    end
  end
end

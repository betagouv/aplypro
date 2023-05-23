# frozen_string_literal: true

class PfmpsController < StudentsController
  before_action :set_classe, only: %i[new create]
  before_action :set_student, only: %i[new create]

  def new
    @pfmp = Pfmp.new
  end

  def create
    @pfmp = Pfmp.new(pfmp_params.merge(student: @student))

    if @pfmp.save
      redirect_to class_student_path(@classe, @student), notice: t("pfmps.new.success")
    else
      respond_to do |format|
        format.html { render :new }
      end
    end
  end

  private

  def pfmp_params
    params.require(:pfmp).permit(
      :start_date,
      :end_date
    )
  end

  def set_student
    @student = @classe.students.find_by(ine: params[:student_id])
  end

  def set_classe
    @classe = Classe.find_by(id: params[:class_id])
  end
end

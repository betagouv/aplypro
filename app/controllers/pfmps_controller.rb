# frozen_string_literal: true

class PfmpsController < StudentsController
  before_action :set_classe, only: %i[new create show]
  before_action :set_student, only: %i[new create show]

  def index
    infer_page_title

    # FIXME: this is awful but we need to scope the PFMPs to the
    # current establishment and I cannot think of a better way now.
    @pfmps = @etab.classes.includes(pfmps: [:transitions]).map(&:pfmps).flatten.group_by(&:current_state)
  end

  def show
    add_breadcrumb t("pages.titles.classes.index"), classes_path
    add_breadcrumb t("pages.titles.classes.show", name: @classe.label), class_path(@classe)
    add_breadcrumb(
      t("pages.titles.students.show", name: @student.full_name, classe: @classe.label),
      class_student_path(@classe, @student)
    )

    @pfmp = Pfmp.find(params[:id])
  end

  def new
    add_breadcrumb t("pages.titles.classes.index"), classes_path
    add_breadcrumb t("pages.titles.classes.show", name: @classe.label), class_path(@classe)
    add_breadcrumb(
      t("pages.titles.students.show", name: @student.full_name, classe: @classe.label),
      class_student_path(@classe, @student)
    )

    infer_page_title

    @inhibit_title = true

    @pfmp = Pfmp.new
  end

  def create
    @pfmp = Pfmp.new(pfmp_params.merge(student: @student))

    respond_to do |format|
      if @pfmp.save
        format.html { redirect_to class_student_path(@classe, @student), notice: t("pfmps.new.success") }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pfmp.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def pfmp_params
    params.require(:pfmp).permit(
      :start_date,
      :end_date,
      :day_count
    )
  end

  def set_student
    @student = @classe.students.find_by(ine: params[:student_id])
  end

  def set_classe
    @classe = Classe.find_by(id: params[:class_id])
  end
end

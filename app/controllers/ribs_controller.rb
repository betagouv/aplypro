# frozen_string_literal: true

class RibsController < StudentsController
  before_action :set_classe, only: %i[new create]
  before_action :set_student, only: %i[new create]

  def index; end

  def show; end

  def new
    add_breadcrumb t("pages.titles.classes.index"), classes_path
    add_breadcrumb t("pages.titles.classes.show", name: @classe.label), class_path(@classe)
    add_breadcrumb(
      t("pages.titles.students.show", name: @student.full_name, classe: @classe.label),
      class_student_path(@classe, @student)
    )

    infer_page_title

    @inhibit_title = true

    @rib = Rib.new
  end

  def create
    @rib = Rib.new(rib_params)

    if @rib.save
      redirect_to class_student_path(@classe, @student), notice: t("ribs.new.success")
    else
      respond_to do |format|
        format.html { render :new }
      end
    end
  end

  private

  def rib_params
    params.require(:rib).permit(
      :iban,
      :bic
    ).with_defaults(student: @student)
  end

  def set_student
    @student = @classe.students.find_by(ine: params[:student_id])
  end

  def set_classe
    @classe = Classe.find_by(id: params[:class_id])
  end
end

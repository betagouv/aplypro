# frozen_string_literal: true

class RibsController < StudentsController
  before_action :set_classe, :set_student
  before_action :set_rib, except: %i[new create]

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

  def edit; end

  def confirm_deletion; end

  def create
    @rib = Rib.new(rib_params)

    respond_to do |format|
      if @rib.save
        format.html { redirect_to class_student_path(@classe, @student), notice: t(".success") }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @rib.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @rib.update(rib_params)
      redirect_to class_student_path(@classe, @student), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rib.destroy

    redirect_to class_student_path(@classe, @student), notice: t("flash.ribs.destroyed", name: @student.full_name)
  end

  private

  def rib_params
    params.require(:rib).permit(
      :iban,
      :bic,
      :name,
      :personal
    ).with_defaults(student: @student)
  end

  def set_student
    @student = @classe.students.find(params[:student_id])
  end

  def set_classe
    @classe = Classe.where(establishment: @etab).find(params[:class_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to classes_path, alert: t("errors.classes.not_found"), status: :forbidden and return
  end

  def set_rib
    @rib = @student.ribs.find(params[:id])
  end
end

# frozen_string_literal: true

# FIXME: we should rightfully tidy up at some point

# rubocop:disable Metrics/ClassLength
class RibsController < ApplicationController
  rescue_from ActiveRecord::ReadOnlyRecord, with: :rib_is_readonly

  before_action :set_classe
  before_action :set_student, :set_rib_breadcrumbs, except: %i[missing bulk_create]
  before_action :check_classes, only: :bulk_create
  before_action :set_bulk_rib_breadcrumbs, only: %i[missing bulk_create]
  before_action :set_rib, only: %i[edit update destroy confirm_deletion]

  def new
    @rib = Rib.new
  end

  def index

  end

  def edit; end

  def confirm_deletion; end

  def create
    @rib = Rib.new(rib_params)

    respond_to do |format|
      if @rib.save
        # Archive previous Rib
        @student.ribs.order(created_at).to[-2].update!(archived_at: DateTime.now)

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

  def missing
    @ribs = @classe
            .students
            .without_ribs
            .map { |student| Rib.new(student: student, owner_type: :personal, name: student.full_name) }
  end

  def bulk_create
    @ribs = bulk_ribs_params
            .map { |rib_params| Rib.new(rib_params) }
            .reject { |rib| [rib.iban, rib.bic].all?(&:blank?) }

    if @ribs.each(&:save).all?(&:valid?)
      redirect_to class_path(@classe), notice: t("ribs.create.success")
    else
      render :missing, status: :unprocessable_entity
    end
  end

  private

  def rib_params
    params.require(:rib).permit(
      :iban,
      :bic,
      :name,
      :owner_type
    ).with_defaults(student: @student)
  end

  def bulk_ribs_params
    params
      .require(:ribs)
      .values
      .map do |rib_params|
        rib_params.permit(%i[iban bic name owner_type student_id])
      end
  end

  def set_student
    @student = @classe.students.find(params[:student_id])
  end

  def set_classe
    @classe = Classe.where(establishment: current_establishment).find(params[:class_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to classes_path, alert: t("errors.classes.not_found"), status: :forbidden and return
  end

  def set_rib
    @rib = @student.ribs.find(params[:id])
  end

  def set_classe_breadcrumbs
    add_breadcrumb t("pages.titles.classes.index"), classes_path
    add_breadcrumb t("pages.titles.classes.show", name: @classe.label), class_path(@classe)
  end

  def set_rib_breadcrumbs
    set_classe_breadcrumbs
    add_breadcrumb(
      t("pages.titles.students.show", name: @student.full_name, classe: @classe.label),
      class_student_path(@classe, @student)
    )
    infer_page_title(name: @student.full_name)
  end

  def set_bulk_rib_breadcrumbs
    set_classe_breadcrumbs
    infer_page_title
  end

  def check_classes
    students_not_in_class = bulk_ribs_params.pluck(:student_id).map(&:to_i) - @classe.students.pluck(:id)

    if students_not_in_class.present? # rubocop:disable Style/GuardClause
      redirect_to(
        missing_class_ribs_path(@classe),
        alert: t("errors.classes.not_found"),
        status: :forbidden
      ) and return
    end
  end

  def rib_is_readonly
    redirect_to class_student_path(@classe, @student), alert: t("flash.ribs.readonly", name: @student.full_name)
  end
end
# rubocop:enable Metrics/ClassLength

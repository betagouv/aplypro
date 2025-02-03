# frozen_string_literal: true

# FIXME: we should rightfully tidy up at some point

class RibsController < ApplicationController # rubocop:disable Metrics/ClassLength
  rescue_from ActiveRecord::ReadOnlyRecord, with: :rib_is_readonly

  before_action :set_classe, :set_bulk_rib_breadcrumbs, only: %i[missing bulk_create]
  before_action :set_student, :check_establishment!, :set_rib_breadcrumbs, except: %i[missing bulk_create]
  before_action :check_classes, only: :bulk_create
  before_action :set_rib, only: %i[edit update]

  def new
    @rib = Rib.new
  end

  def edit; end

  def create
    @rib = @student.create_new_rib(rib_params)

    if @rib.save
      redirect_to student_path(@student), notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @student.rib(current_establishment.id) == Rib.new(rib_params)
      redirect_to edit_student_rib_path(@student, @rib), alert: t("flash.ribs.cannot_create")
    else
      @rib = @student.create_new_rib(rib_params)

      if @rib.save
        @student.retry_pfmps_payment_requests!(%w[rib bic paiement])

        redirect_to student_path(@student), notice: t(".success")
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def missing
    @ribs = @classe
            .active_students
            .without_ribs
            .map { |student| Rib.new(student: student, owner_type: :personal, name: student.full_name) }
  end

  def bulk_create
    @ribs = bulk_ribs_params.map do |rib_params|
      Student.find(rib_params["student_id"]).create_new_rib(
        rib_params.except("student_id").merge("establishment_id" => current_establishment.id)
      )
    end
    if @ribs.each(&:save).all?(&:valid?)
      redirect_to school_year_class_path(selected_school_year, @classe), notice: t("ribs.create.success")
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
    ).with_defaults(student_id: @student.id, establishment_id: current_establishment.id)
  end

  def bulk_ribs_params
    params
      .require(:ribs)
      .values
      .map { |p| p.permit(%i[iban bic name owner_type student_id]).to_h }
      .reject { |rib| [rib["iban"], rib["bic"]].all?(&:blank?) }
  end

  def set_student
    @student = Student.find(params[:student_id])
    raise ActiveRecord::RecordNotFound unless @student.any_classes_in_establishment?(current_establishment)
  rescue ActiveRecord::RecordNotFound
    redirect_to school_year_classes_path(selected_school_year), alert: t("errors.students.not_found")
  end

  def set_classe
    @classe = current_establishment.classes.find_by!(id: params[:class_id], school_year: selected_school_year)
  rescue ActiveRecord::RecordNotFound
    redirect_to school_year_classes_path(selected_school_year),
                alert: t("errors.classes.not_found") and return
  end

  def set_rib
    @rib = @student.ribs.find_by!(id: params[:id], establishment: current_establishment)
  end

  def set_classe_breadcrumbs
    add_breadcrumb(
      t("pages.titles.classes.index"),
      school_year_classes_path(selected_school_year)
    )
    add_breadcrumb(
      t("pages.titles.classes.show", name: @classe.label),
      school_year_class_path(selected_school_year, @classe)
    )
  end

  def set_rib_breadcrumbs
    add_breadcrumb(
      t("pages.titles.students.show", name: @student.full_name),
      student_path(@student)
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
        missing_school_year_class_ribs_path(selected_school_year, @classe),
        alert: t("errors.classes.not_found"),
        status: :forbidden
      ) and return
    end
  end

  def check_establishment!
    raise ActiveRecord::ReadOnlyRecord unless @student.any_classes_in_establishment?(current_establishment)
  end

  def rib_is_readonly
    redirect_to student_path(@student), alert: t("flash.ribs.readonly", name: @student.full_name)
  end
end

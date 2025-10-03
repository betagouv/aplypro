# frozen_string_literal: true

class InvitationsController < ApplicationController
  before_action :check_authorised_to_invite
  before_action :set_invitation, only: :destroy
  before_action :add_new_breadcrumbs, only: %i[new create]

  def index
    @invitations = current_establishment.establishment_invitations

    infer_page_title
  end

  def new
    @invitation = EstablishmentInvitation.new
  end

  def create
    @invitation = EstablishmentInvitation.new(invitation_params)

    if @invitation.save
      redirect_to establishment_invitations_path, notice: t("flash.invites.created", email: @invitation.email)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @invitation.destroy

    redirect_to(
      establishment_invitations_path(current_establishment),
      notice: t("flash.invites.destroyed", email: @invitation.email)
    )
  end

  private

  def invitation_params
    params
      .require(:invitation)
      .permit(:email)
      .with_defaults(user: current_user, establishment: current_establishment)
  end

  def set_invitation
    @invitation = current_establishment.establishment_invitations.find(params[:id])
  end

  def check_authorised_to_invite
    if current_user.cannot_invite? # rubocop:disable Style/GuardClause
      redirect_back_or_to(
        root_path,
        alert: t("flash.pfmps.not_authorised_to_invite"),
        status: :forbidden
      )
    end
  end

  def add_new_breadcrumbs
    add_breadcrumb t("pages.titles.invitations.index"), establishment_invitations_path(current_establishment)
    infer_page_title
  end
end

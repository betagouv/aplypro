# frozen_string_literal: true

class InvitationsController < ApplicationController
  before_action :check_authorisation
  before_action :set_invitation, only: :destroy

  def index
    @invitations = @etab.invitations

    infer_page_title
  end

  def new
    add_breadcrumb t("pages.titles.invitations.index"), establishment_invitations_path(@etab)

    @invitation = Invitation.new

    infer_page_title
  end

  def create
    @invitation = Invitation.new(invitation_params)

    if @invitation.save
      redirect_to establishment_invitations_path, notice: t("flash.invites.created", email: @invitation.email)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @invitation.destroy

    redirect_to establishment_invitations_path(@etab), notice: t("flash.invites.destroyed", email: @invitation.email)
  end

  private

  def invitation_params
    params
      .require(:invitation)
      .permit(:email)
      .with_defaults(user: current_user, establishment: @etab)
  end

  def set_invitation
    @invitation = @etab.invitations.find(params[:id])
  end

  def check_authorisation
    if !current_user.can_authorise?
      redirect_back_or_to(
        root_path,
        alert: t("flash.pfmps.not_authorised_to_authorise"),
        status: :forbidden
      ) and return
    end
  end
end

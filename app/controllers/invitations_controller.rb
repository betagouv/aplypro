# frozen_string_literal: true

class InvitationsController < ApplicationController
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
      redirect_to establishment_invitations_path, notice: "L'email #{@invitation.email} est maintenant autorisé"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def invitation_params
    params
      .require(:invitation)
      .permit(:email)
      .with_defaults(user: current_user, establishment: @etab)
  end
end

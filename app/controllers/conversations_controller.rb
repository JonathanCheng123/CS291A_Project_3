class ConversationsController < ApplicationController
  include JwtAuthenticable

  before_action :authenticate_with_jwt!
  before_action :set_conversation, only: [:show]

  def index
    conversations = Conversation.where(questioner_id: current_user_from_token.id)
                                .or(Conversation.where(assigned_expert_id: current_user_from_token.id))
                                .order(updated_at: :desc)

    render json: conversations.map { |c| conversation_response(c) }
  end

  def show
    render json: conversation_response(@conversation)
  end

  def create
    conversation = Conversation.new(conversation_params)
    conversation.questioner = current_user_from_token

    if conversation.save
      render json: conversation_response(conversation), status: :created
    else
      render json: { errors: conversation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
    
    unless @conversation.questioner_id == current_user_from_token.id || 
           @conversation.assigned_expert_id == current_user_from_token.id
      render json: { error: 'Unauthorized' }, status: :forbidden
    end
  end

  def conversation_params
    params.permit(:title)
  end

  def conversation_response(conversation)
    {
      id: conversation.id.to_s,
      title: conversation.title,
      status: conversation.status,
      questionerId: conversation.questioner_id.to_s,
      questionerUsername: conversation.questioner.username,
      assignedExpertId: conversation.assigned_expert_id&.to_s,
      assignedExpertUsername: conversation.assigned_expert&.username,
      createdAt: conversation.created_at.iso8601,
      updatedAt: conversation.updated_at.iso8601,
      lastMessageAt: conversation.last_message_at&.iso8601,
      unreadCount: conversation.unread_count_for(current_user_from_token)
    }
  end
end
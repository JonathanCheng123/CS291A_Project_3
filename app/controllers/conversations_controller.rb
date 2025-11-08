class ConversationsController < ApplicationController
  include JwtAuthenticable

  before_action :authenticate_with_jwt!
  before_action :set_conversation, only: [:show]

  # GET /conversations
  def index
    conversations = Conversation.where(initiator_id: current_user_from_token.id)
                                .or(Conversation.where(assigned_expert_id: current_user_from_token.id))
                                .order(updated_at: :desc)

    render json: conversations.map { |c| conversation_response(c) }
  end

  # GET /conversations/:id
  def show
    render json: conversation_response(@conversation)
  end

  # POST /conversations
  def create
    conversation = Conversation.new(conversation_params)
    conversation.initiator = current_user_from_token

    if conversation.save
      render json: conversation_response(conversation), status: :created
    else
      render json: { errors: conversation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Set conversation for show
  def set_conversation
    @conversation = Conversation.find(params[:id])
    unless @conversation.initiator_id == current_user_from_token.id || 
           @conversation.assigned_expert_id == current_user_from_token.id
      render json: { error: 'Unauthorized' }, status: :forbidden
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Conversation not found' }, status: :not_found
  end

  # Strong parameters
  def conversation_params
    params.require(:conversation).permit(:title)
  end

  # JSON response for a conversation
  def conversation_response(conversation)
    {
      id: conversation.id.to_s,
      title: conversation.title,
      status: conversation.status,
      questionerId: conversation.initiator_id.to_s,
      questionerUsername: conversation.initiator.username,
      assignedExpertId: conversation.assigned_expert_id&.to_s,
      assignedExpertUsername: conversation.assigned_expert&.username,
      createdAt: conversation.created_at.iso8601,
      updatedAt: conversation.updated_at.iso8601,
      lastMessageAt: conversation.last_message_at&.iso8601,
      unreadCount: 0 # Placeholder for unread count logic
    }
  end
end
